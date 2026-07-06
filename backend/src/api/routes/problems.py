from email import policy
from email.parser import BytesParser
from html import unescape
from html.parser import HTMLParser
import re
import urllib.parse
import quopri

from fastapi import APIRouter, Depends, HTTPException, Query, status

from config import Settings
from repositories.problem_repository import ProblemRepository
from repositories.llm_settings_repository import LLMSettingsRepository
from schemas.analysis import ParsedExample, ParsedProblemResult
from schemas.llm_settings import LLMSettings
from schemas.problems import ExampleItem, OfflineProblemCandidate, OfflineProblemExtractRequest, PaginatedProblemsResponse, ProblemBatchImportRequest, ProblemCreate, ProblemDetail, ProblemImportRequest, ProblemListItem, ProblemTestCase
from services.analysis_service import AnalysisService


router = APIRouter(prefix='/problems', tags=['problems'])


class _HTMLTextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self._skip_plain_depth = 0
        self._skip_katex_html_depth = 0
        self._mathml_depth = 0
        self._annotation_depth = 0
        self._span_mode_stack: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attributes = {key: value or '' for key, value in attrs}
        class_names = set(attributes.get('class', '').split())

        if tag == 'span':
            if 'katex-html' in class_names:
                self._span_mode_stack.append('katex-html')
                self._skip_katex_html_depth += 1
                return
            if 'katex-mathml' in class_names:
                self._span_mode_stack.append('katex-mathml')
                self._mathml_depth += 1
                return
            self._span_mode_stack.append('plain')

        if tag in {'script', 'style'}:
            self._skip_plain_depth += 1
            return

        if self._should_skip():
            return

        if tag == 'annotation' and self._mathml_depth > 0:
            self._annotation_depth += 1
            return

        if tag == 'img':
            alt = attributes.get('alt', '').strip()
            if alt:
                self.parts.append(f' {alt} ')
            return

        if tag == 'br':
            self.parts.append('\n')

    def handle_endtag(self, tag: str) -> None:
        if tag in {'script', 'style'} and self._skip_plain_depth > 0:
            self._skip_plain_depth -= 1
            return

        if tag == 'span':
            mode = self._span_mode_stack.pop() if self._span_mode_stack else 'plain'
            if mode == 'katex-html' and self._skip_katex_html_depth > 0:
                self._skip_katex_html_depth -= 1
                return
            if mode == 'katex-mathml' and self._mathml_depth > 0:
                self._mathml_depth -= 1
                return

        if tag == 'annotation' and self._annotation_depth > 0:
            self._annotation_depth -= 1
            return

        if self._should_skip():
            return

        if tag in {'p', 'div', 'section', 'article', 'li', 'ul', 'ol', 'tr', 'table', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'pre'}:
            self.parts.append('\n')

    def handle_data(self, data: str) -> None:
        if self._should_skip():
            return
        if self._mathml_depth > 0 and self._annotation_depth == 0:
            return
        if data:
            cleaned = data.strip()
            if self._annotation_depth > 0:
                if cleaned == '\\bullet':
                    self.parts.append('•')
                    return
            self.parts.append(data)

    def get_text(self) -> str:
        text = ''.join(self.parts)
        text = text.replace('\xa0', ' ')
        text = text.replace('\r\n', '\n').replace('\r', '\n')
        text = re.sub(r'\n{3,}', '\n\n', text)
        text = re.sub(r'[ \t]{2,}', ' ', text)
        return text.strip()

    def _should_skip(self) -> bool:
        return self._skip_plain_depth > 0 or self._skip_katex_html_depth > 0


class _HTMLMarkdownExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self._skip_plain_depth = 0
        self._skip_katex_html_depth = 0
        self._mathml_depth = 0
        self._annotation_depth = 0
        self._annotation_buffer: list[str] = []
        self._span_mode_stack: list[str] = []
        self._list_depth = 0
        self._pending_list_item = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attributes = {key: value or '' for key, value in attrs}
        class_names = set(attributes.get('class', '').split())

        if tag == 'span':
            if 'katex-html' in class_names:
                self._span_mode_stack.append('katex-html')
                self._skip_katex_html_depth += 1
                return
            if 'katex-mathml' in class_names:
                self._span_mode_stack.append('katex-mathml')
                self._mathml_depth += 1
                return
            self._span_mode_stack.append('plain')

        if tag in {'script', 'style'}:
            self._skip_plain_depth += 1
            return

        if self._should_skip():
            return

        if tag == 'annotation' and self._mathml_depth > 0:
            self._annotation_depth += 1
            self._annotation_buffer = []
            return

        if tag in {'ul', 'ol'}:
            self._list_depth += 1
            self.parts.append('\n')
            return

        if tag == 'li':
            self._pending_list_item = True
            return

        if tag == 'img':
            src = attributes.get('src', '').strip()
            alt = attributes.get('alt', '').strip()
            if 'equation?tex=' in src:
                tex = _parse_equation_tex_src(src) or alt
                if tex:
                    _append_math_delimited(tex, self.parts)
                return
            if alt and not src:
                self.parts.append(alt)
                return
            if src:
                label = alt or '题面配图'
                self.parts.append(f'\n![{label}]({src})\n')
            return

        if tag == 'br':
            self.parts.append('\n')

    def handle_endtag(self, tag: str) -> None:
        if tag in {'script', 'style'} and self._skip_plain_depth > 0:
            self._skip_plain_depth -= 1
            return

        if tag == 'span':
            mode = self._span_mode_stack.pop() if self._span_mode_stack else 'plain'
            if mode == 'katex-html' and self._skip_katex_html_depth > 0:
                self._skip_katex_html_depth -= 1
                return
            if mode == 'katex-mathml' and self._mathml_depth > 0:
                self._mathml_depth -= 1
                return

        if tag == 'annotation' and self._annotation_depth > 0:
            self._annotation_depth -= 1
            if self._annotation_depth == 0:
                self._flush_annotation()
            return

        if self._should_skip():
            return

        if tag in {'ul', 'ol'} and self._list_depth > 0:
            self._list_depth -= 1

        if tag in {'p', 'div', 'section', 'article', 'tr', 'table', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'pre', 'center'}:
            self.parts.append('\n')

        if tag == 'li':
            self.parts.append('\n')

    def handle_data(self, data: str) -> None:
        if self._should_skip():
            return
        if self._mathml_depth > 0 and self._annotation_depth == 0:
            return
        if not data:
            return

        if self._annotation_depth > 0:
            self._annotation_buffer.append(data)
            return

        if self._pending_list_item:
            self.parts.append('- ')
            self._pending_list_item = False
        self.parts.append(data)

    def get_markdown(self) -> str:
        text = ''.join(self.parts)
        text = text.replace('\xa0', ' ')
        text = text.replace('\r\n', '\n').replace('\r', '\n')
        text = re.sub(r'\n{3,}', '\n\n', text)
        text = re.sub(r'[ \t]{2,}', ' ', text)
        return text.strip()

    def _should_skip(self) -> bool:
        return self._skip_plain_depth > 0 or self._skip_katex_html_depth > 0

    def _flush_annotation(self) -> None:
        tex = ''.join(self._annotation_buffer).strip()
        if not tex:
            return
        cleaned = tex.strip()
        cleaned = re.sub(r'\\hspace\{[^}]+\}', '', cleaned)
        cleaned = cleaned.replace('\\bullet\\,', '').replace('\\bullet', '')
        cleaned = cleaned.strip()
        if not cleaned:
            return
        _append_math_delimited(cleaned, self.parts)


def _parse_equation_tex_src(src: str) -> str:
    parsed = urllib.parse.urlparse(src)
    params = urllib.parse.parse_qs(parsed.query)
    return params.get('tex', [''])[0]


def _append_math_delimited(tex: str, parts: list[str]) -> None:
    cleaned = tex.strip()
    if not cleaned:
        return
    cleaned = re.sub(r'\\hspace\{[^}]+\}', '', cleaned)
    cleaned = cleaned.replace('\\bullet\\,', '').replace('\\bullet', '')
    cleaned = cleaned.strip()
    if not cleaned:
        return
    if cleaned.startswith('\\begin{'):
        parts.append(f'\n$$\n{cleaned}\n$$\n')
    else:
        parts.append(f'${cleaned}$')


def get_repository() -> ProblemRepository:
    settings = Settings()
    return ProblemRepository(settings.database_url)


def get_settings_repository() -> LLMSettingsRepository:
    settings = Settings()
    return LLMSettingsRepository(settings.database_url)


def get_analysis_service() -> AnalysisService:
    return AnalysisService()


def _default_llm_settings() -> LLMSettings:
    return LLMSettings(
        id=0,
        provider='OpenAI Compatible',
        endpoint_url='https://api.openai.com/v1',
        solution_model='gpt-4.1-mini',
        vision_model='gpt-4.1-mini',
        attribution_model='gpt-4.1-mini',
        review_model='gpt-4.1-mini',
        solution_temperature=0.2,
        attribution_temperature=0.1,
        review_temperature=0.3,
        api_key_configured=False,
        api_key_masked='',
        enabled=True,
        updated_at='',
    )


def _parse_import_problem(
    analysis_service: AnalysisService,
    settings_repository: LLMSettingsRepository,
    raw_text: str,
):
    try:
        settings = settings_repository.get_settings()
        api_key = settings_repository.get_api_key()
    except Exception:
        settings = _default_llm_settings()
        api_key = ''

    try:
        return analysis_service.parse_problem_text(settings, api_key, raw_text, mode='text_only')
    except Exception:
        return analysis_service.parse_problem_text(_default_llm_settings(), '', raw_text, mode='text_only')


def _strip_html_to_text(value: str) -> str:
    if not value.strip():
        return ''

    parser = _HTMLTextExtractor()
    parser.feed(value)
    parser.close()
    return unescape(parser.get_text())


def _convert_html_to_markdown(value: str) -> str:
    if not value.strip():
        return ''

    parser = _HTMLMarkdownExtractor()
    parser.feed(value)
    parser.close()
    return unescape(parser.get_markdown())


def _extract_snapshot_source_url(raw_content: str) -> str:
    match = re.search(r'^Snapshot-Content-Location:\s*(.+)$', raw_content, flags=re.MULTILINE)
    if match:
        return match.group(1).strip()
    return ''


def _extract_html_document(raw_content: str) -> str:
    content = raw_content.strip()
    header_preview = content[:4096].lower()
    is_mhtml = 'content-transfer-encoding: quoted-printable' in header_preview or 'snapshot-content-location:' in header_preview
    if not is_mhtml:
        if '<html' in header_preview or '<!doctype html' in header_preview:
            return raw_content

    try:
        message = BytesParser(policy=policy.default).parsebytes(raw_content.encode('utf-8', errors='ignore'))
        if message.is_multipart():
            for part in message.walk():
                if part.get_content_type() != 'text/html':
                    continue
                payload = part.get_payload(decode=True)
                if payload is None:
                    continue
                charset = part.get_content_charset() or 'utf-8'
                decoded_html = payload.decode(charset, errors='ignore')
                if '<html' in decoded_html.lower():
                    return decoded_html
    except Exception:
        pass

    part_match = re.search(
        r'Content-Type:\s*text/html.*?Content-Transfer-Encoding:\s*quoted-printable.*?(?:\r?\n){2}',
        raw_content,
        flags=re.IGNORECASE | re.DOTALL,
    )
    if not part_match:
        raise ValueError('离线文件中未找到 HTML 正文')

    body_start = part_match.end()
    next_boundary = re.search(r'\r?\n------MultipartBoundary', raw_content[body_start:])
    encoded_html = raw_content[body_start: body_start + next_boundary.start()] if next_boundary else raw_content[body_start:]
    decoded_html = quopri.decodestring(encoded_html.encode('utf-8', errors='ignore')).decode('utf-8', errors='ignore')
    if '<html' not in decoded_html.lower():
        raise ValueError('离线文件中的 HTML 正文解码失败')
    return decoded_html


def _extract_coding_blocks(document_html: str) -> list[str]:
    block_matches = list(re.finditer(r'<div[^>]*class="paper-question"[^>]*data-question-index="\d+"[^>]*>', document_html, flags=re.IGNORECASE))
    if not block_matches:
        return []

    blocks: list[str] = []
    for index, match in enumerate(block_matches):
        end = block_matches[index + 1].start() if index + 1 < len(block_matches) else len(document_html)
        block = document_html[match.start():end]
        if 'codingClass commonClass">编程题' in block or 'coding-question' in block:
            blocks.append(block)
    return blocks


def _extract_title(block_html: str) -> str:
    match = re.search(
        r'class="codingTitleClass tw-flex"[\s\S]*?<div[^>]*class="commonPaperHtml tw-flex-1 tw-w-0"[^>]*>(.*?)</div>',
        block_html,
        flags=re.IGNORECASE,
    )
    if not match:
        return ''
    title = _strip_html_to_text(match.group(1))
    if len(title) >= 3:
        return title
    body = _extract_body_html(block_html)
    if body:
        body_text = _strip_html_to_text(body).strip()
        body_text = re.sub(r'\\+[a-zA-Z]+\{[^}]*\}', '', body_text)
        first_sentence = body_text.split('\n')[0].strip()
        if first_sentence and len(first_sentence) > len(title):
            combined = f'{title} - {first_sentence}' if title else first_sentence
            if len(combined) > 80:
                return combined[:80]
            return combined
    return title


def _extract_body_html(block_html: str) -> str:
    match = re.search(
        r'class="commonPaperHtml codingContentClass"[^>]*>([\s\S]*?)</div>\s*</div>\s*</div>\s*<div[^>]*class="description-wrap',
        block_html,
        flags=re.IGNORECASE,
    )
    return match.group(1).strip() if match else ''


def _extract_preceding_section(block_html: str, label: str) -> str:
    pattern = rf'class="item-title">{re.escape(label)}</div>\s*<pre[^>]*>([\s\S]*?)</pre>'
    match = re.search(pattern, block_html, flags=re.IGNORECASE)
    return match.group(1).strip() if match else ''


def _extract_samples(block_html: str) -> list[dict[str, str]]:
    pattern = re.compile(
        r'class="item-title">示例\s*(\d+)</div>[\s\S]*?输入例子：</span>\s*<pre[^>]*>([\s\S]*?)</pre>[\s\S]*?输出例子：</span>\s*<pre[^>]*>([\s\S]*?)</pre>(?:[\s\S]*?例子说明：</span>\s*<pre[^>]*>([\s\S]*?)</pre>)?',
        flags=re.IGNORECASE,
    )

    samples: list[dict[str, str]] = []
    for match in pattern.finditer(block_html):
        samples.append(
            {
                'input': _strip_html_to_text(match.group(2)),
                'output': _strip_html_to_text(match.group(3)),
                'explanation': _convert_html_to_markdown(match.group(4) or ''),
            }
        )
    return samples


def _build_offline_description_html(body_html: str, input_html: str, output_html: str) -> str:
    sections = [body_html.strip()]
    if input_html.strip():
        sections.append(f'<div class="item-title">输入描述：</div><pre>{input_html.strip()}</pre>')
    if output_html.strip():
        sections.append(f'<div class="item-title">输出描述：</div><pre>{output_html.strip()}</pre>')
    return '\n'.join(section for section in sections if section).strip()


def _extract_offline_problem_candidates(raw_content: str, source_url: str) -> list[OfflineProblemCandidate]:
    document_html = _extract_html_document(raw_content)
    resolved_source_url = source_url.strip() or _extract_snapshot_source_url(raw_content)

    # Try old format first (paper-question blocks with data-question-index)
    coding_blocks = _extract_coding_blocks(document_html)
    if coding_blocks:
        candidates: list[OfflineProblemCandidate] = []
        for block in coding_blocks:
            title = _extract_title(block)
            body_html = _extract_body_html(block)
            input_html = _extract_preceding_section(block, '输入描述：')
            output_html = _extract_preceding_section(block, '输出描述：')
            description_html = _build_offline_description_html(body_html, input_html, output_html)
            description_text = _strip_html_to_text(description_html)
            samples = _extract_samples(block)

            if not title or not description_html:
                continue

            candidates.append(
                OfflineProblemCandidate(
                    title=title,
                    description_html=description_html,
                    description_text=description_text,
                    source_url=resolved_source_url,
                    samples=samples,
                )
            )
        return candidates

    # Try new format (single problem, left-right layout, .question-oi class)
    candidate = _extract_v2_candidate(document_html, resolved_source_url)
    if candidate:
        return [candidate]

    # Try SSPoffer/neituiya format (Next.js, .ssp-oj-question-box)
    candidate = _extract_ssp_candidate(document_html, resolved_source_url)
    if candidate:
        return [candidate]

    return []


def _extract_v2_candidate(document_html: str, source_url: str) -> OfflineProblemCandidate | None:
    import re as _re
    try:
        from bs4 import BeautifulSoup
    except ImportError:
        return None

    soup = BeautifulSoup(document_html, 'html.parser')

    body_text = soup.get_text()

    title = ''
    title_match = _re.search(r'BM\d+\s+(\S+)', body_text)
    if title_match:
        title = title_match.group(1)
    if not title:
        title_tag = soup.select_one('title')
        if title_tag:
            title = title_tag.get_text(strip=True).split('_')[0].strip()

    # Use .describe-table for rich description (has images, KaTeX, proper structure)
    desc_el = soup.select_one('.describe-table') or soup.select_one('.section-content.describe-table')
    description_html = ''
    if desc_el:
        description_html = desc_el.decode_contents().strip()
    else:
        # Fallback: hidden div
        hidden_div = None
        for div in soup.select('div'):
            style = div.get('style', '')
            if 'top:-1000000px' in style:
                hidden_div = div
                break
        if hidden_div:
            parts = []
            for child in hidden_div.children:
                if isinstance(child, Tag) and 'question-oi' in child.get('class', []):
                    break
                txt = str(child).strip()
                if txt:
                    parts.append(txt)
            description_html = '\n'.join(parts)

    description_text = _strip_html_to_text(description_html) if description_html else ''

    # Extract samples from hidden div (.question-oi blocks)
    samples: list[dict[str, str]] = []
    for sample in soup.select('.question-oi'):
        inp = ''
        out = ''
        explain = ''
        for mod in sample.select('.question-oi-mod'):
            h2 = mod.select_one('h2')
            cont = mod.select_one('.question-oi-cont')
            if h2 and cont:
                label = h2.get_text(strip=True)
                val = cont.get_text(strip=True)
                if '输入' in label:
                    inp = val
                elif '输出' in label:
                    out = val
                elif '说明' in label or '解释' in label:
                    explain = val

        pres = sample.select('pre')
        if not inp and not out and len(pres) >= 2:
            inp = pres[0].get_text(strip=True)
            out = pres[1].get_text(strip=True)
            if len(pres) >= 3:
                explain = pres[2].get_text(strip=True)

        if inp or out:
            samples.append({'input': inp, 'output': out, 'explanation': explain})

    if not title or not description_html:
        return None

    # Carry difficulty hint from page into description so detect_metadata can use it
    diff_hint = ''
    diff_match = _re.search(r'(简单|中等|困难)\s+通过率', body_text)
    if diff_match:
        diff_hint = f'\n\n难度提示：{diff_match.group(1)}\n'

    full_html = f'{description_html}{diff_hint}'
    return OfflineProblemCandidate(
        title=title,
        description_html=full_html,
        description_text=_strip_html_to_text(full_html),
        source_url=source_url,
        samples=samples,
    )


def _extract_ssp_candidate(document_html: str, source_url: str) -> OfflineProblemCandidate | None:
    import re as _re
    try:
        from bs4 import BeautifulSoup, Tag
    except ImportError:
        return None

    if 'ssp-oj-question-box' not in document_html.lower():
        return None

    soup = BeautifulSoup(document_html, 'html.parser')

    title = ''
    title_tag = soup.select_one('title')
    if title_tag:
        title = title_tag.get_text(strip=True).removesuffix('-sspoffer').strip()
    if not title:
        return None

    difficulty = 'Medium'
    time_limit_ms = 2000
    memory_limit_kb = 262144
    for item in soup.select('.info-item'):
        text = item.get_text(strip=True)
        if text in ('EASY', 'MIDDLE', 'HARD'):
            difficulty_map = {'EASY': 'Easy', 'MIDDLE': 'Medium', 'HARD': 'Hard'}
            difficulty = difficulty_map.get(text, 'Medium')
        elif 'ms' in text:
            t = _re.search(r'(\d+)', text)
            if t:
                time_limit_ms = int(t.group(1))
        elif 'M' in text:
            m = _re.search(r'(\d+)', text)
            if m:
                memory_limit_kb = int(m.group(1)) * 1024

    cd = soup.select_one('.code-detail')
    if not cd:
        return None

    # The inner div wraps all h2/p content
    content_div = cd.find('div') or cd

    section_map: dict[str, str] = {}
    current_key = '_prelude'
    section_map[current_key] = ''

    for child in content_div.children:
        if not isinstance(child, Tag):
            continue
        if child.name == 'h2':
            current_key = child.get_text(strip=True)
            section_map[current_key] = ''
        elif current_key:
            section_map[current_key] += str(child)

    description_html = section_map.get('题目描述', '')
    if not description_html.strip():
        description_html = section_map.get('_prelude', '').strip()
    if not description_html.strip():
        return None

    input_html = section_map.get('输入描述', '')
    output_html = section_map.get('输出描述', '')

    if input_html.strip():
        description_html += f'<h2>输入描述</h2>{input_html}'
    if output_html.strip():
        description_html += f'<h2>输出描述</h2>{output_html}'

    # Carry difficulty info for detect_metadata
    diff_cn = {'Easy': '简单', 'Medium': '中等', 'Hard': '困难'}
    description_html += f'\n\n难度提示：{diff_cn.get(difficulty, "中等")}\n'

    description_html = _re.sub(r'[\u200b-\u200f\u2028-\u202f\u00ad\u2060\ufeff]+', '', description_html)
    description_text = _strip_html_to_text(description_html)

    samples: list[dict[str, str]] = []
    for key in section_map:
        if key.startswith('样例') and '解释' not in key:
            sample_id = key
            sample_html = section_map[key]
            sample_text = _strip_html_to_text(sample_html)
            inp = ''
            out = ''
            explain = ''
            explanation_key = f'{key}解释' if key.startswith('样例') else f'{key}解释'
            # Try to extract input/output from structured HTML
            sample_soup = BeautifulSoup(sample_html, 'html.parser')
            for strong in sample_soup.find_all('strong'):
                label = strong.get_text(strip=True)
                if '输入' in label:
                    next_pre = strong.find_next('pre')
                    if next_pre:
                        code = next_pre.find('code') or next_pre
                        inp = code.get_text(strip=True)
                elif '输出' in label:
                    next_pre = strong.find_next('pre')
                    if next_pre:
                        code = next_pre.find('code') or next_pre
                        out = code.get_text(strip=True)
                elif '解释' in label or '说明' in label:
                    explain_texts = []
                    nxt = strong.parent.find_next_sibling('p')
                    while nxt and not nxt.find('strong'):
                        explain_texts.append(_strip_html_to_text(str(nxt)))
                        nxt = nxt.find_next_sibling('p')
                    explain = '\n'.join(t for t in explain_texts if t)

            # Fallback: extract plain text before/after "输入"/"输出" markers
            if not inp and not out:
                inp_match = _re.search(r'输入\s*\n*([\s\S]*?)(?=输出|样例解释|$)', sample_text, re.I)
                if inp_match:
                    inp = inp_match.group(1).strip()
                out_match = _re.search(r'输出\s*\n*([\s\S]*?)(?=样例解释|$)', sample_text, re.I)
                if out_match:
                    out = out_match.group(1).strip()

            if inp or out:
                samples.append({'input': inp, 'output': out, 'explanation': explain})

    if not samples:
        return None

    # Detect company from title: "【公司 岗位】日期-题号-标题"
    company = '未知'
    company_match = _re.search(r'【(.+?)】', title)
    if company_match:
        company = company_match.group(1).strip()
    # Strip the prefix from title
    title = _re.sub(r'^【.+?】\s*', '', title).strip()
    title = _re.sub(r'\d{4}-\d{1,2}-\d{1,2}-第[一二三四五六七八九十\d]+题-', '', title).strip()

    return OfflineProblemCandidate(
        title=title,
        description_html=description_html,
        description_text=description_text,
        source_url=source_url,
        samples=samples,
        difficulty=difficulty,
        time_limit_ms=time_limit_ms,
        memory_limit_kb=memory_limit_kb,
    )


def _build_import_raw_text(title: str, description_text: str, samples: list[dict[str, str]]) -> str:
    parts = [title.strip(), description_text.strip()]
    for index, sample in enumerate(samples, start=1):
        input_text = sample.get('input', '').strip()
        output_text = sample.get('output', '').strip()
        explanation = sample.get('explanation', '').strip()
        if not input_text and not output_text and not explanation:
            continue
        block = [f'示例 {index}']
        if input_text:
            block.extend(['输入例子：', input_text])
        if output_text:
            block.extend(['输出例子：', output_text])
        if explanation:
            block.extend(['例子说明：', explanation])
        parts.append('\n'.join(block))
    return '\n\n'.join(part for part in parts if part).strip()


def _normalize_import_text_block(text: str) -> str:
    normalized = text.replace('\r\n', '\n').replace('\r', '\n').replace('\t', '    ')
    normalized = re.sub(r'\\hspace\{[^}]+\}', '', normalized)
    normalized = normalized.replace('\\bullet\\,', '- ')
    normalized = normalized.replace('\\bullet', '- ')
    normalized = normalized.replace('\u2022', '- ')
    normalized = re.sub(r'(?m)^\s*•\s*', '- ', normalized)
    normalized = re.sub(r'(?m)^\s*【提示】\s*$', '## 提示', normalized)
    normalized = _normalize_nonmath_whitespace(normalized)
    return normalized.strip()


def _normalize_nonmath_whitespace(text: str) -> str:
    blocks = re.split(r'(\$\$[\s\S]*?\$\$)', text)
    result: list[str] = []
    for block in blocks:
        if block.startswith('$$') and block.endswith('$$'):
            result.append(block)
        else:
            trimmed = re.sub(r'(?m)^[ \t]+(?=\S)', '', block)
            trimmed = re.sub(r'(?m)^\s+$', '', trimmed)
            trimmed = re.sub(r'\n[ \t]+\n', '\n\n', trimmed)
            result.append(trimmed)
    text = ''.join(result)
    return re.sub(r'\n{3,}', '\n\n', text)


def _split_import_description_sections(description_text: str) -> tuple[str, str, str]:
    normalized = _normalize_import_text_block(description_text)
    input_match = re.search(r'(?m)^输入描述：\s*$', normalized)
    output_match = re.search(r'(?m)^输出描述：\s*$', normalized)

    if not input_match or not output_match or output_match.start() <= input_match.end():
        return normalized, '', ''

    body = normalized[:input_match.start()].strip()
    input_text = normalized[input_match.end():output_match.start()].strip()
    output_text = normalized[output_match.end():].strip()
    return body, input_text, output_text


def _build_import_markdown_from_text(description_text: str, examples: list[ParsedExample]) -> str:
    body, input_text, output_text = _split_import_description_sections(description_text)
    sections: list[str] = []

    if body:
        sections.append(body)
    if input_text:
        sections.append(f'## 输入格式\n\n{input_text}')
    if output_text:
        sections.append(f'## 输出格式\n\n{output_text}')

    markdown = '\n\n'.join(section for section in sections if section).strip()
    return _append_examples_section(markdown, examples)


def _build_import_markdown_from_html(description_html: str, examples: list[ParsedExample]) -> str:
    return _build_import_markdown_from_text(_convert_html_to_markdown(description_html), examples)


def _append_examples_section(statement_markdown: str, examples: list[ParsedExample]) -> str:
    text = statement_markdown.strip()
    if not examples or '## 样例' in text:
        return text

    blocks: list[str] = []
    for index, example in enumerate(examples, start=1):
        block = [f'### 样例 {index}', '', '**输入：**', '```', example.input.strip(), '```', '', '**输出：**', '```', example.output.strip(), '```']
        if example.explanation.strip():
            block.extend(['', '**说明：**', example.explanation.strip()])
        blocks.append('\n'.join(block))

    return f'{text}\n\n## 样例\n\n' + '\n\n'.join(blocks)


def _normalize_import_example_text(text: str) -> str:
    return _normalize_import_text_block(text)


def _build_offline_import_result(payload: ProblemImportRequest, analysis_service: AnalysisService | None = None) -> ParsedProblemResult:
    examples = [
        ParsedExample(
            input=item.input.strip(),
            output=item.output.strip(),
            explanation=_normalize_import_example_text(item.explanation),
        )
        for item in payload.samples
        if item.input.strip() or item.output.strip() or item.explanation.strip()
    ]
    statement_markdown = _build_import_markdown_from_html(payload.description_html, examples)
    if not statement_markdown.strip():
        statement_markdown = _build_import_markdown_from_text(payload.description_text, examples)

    title = payload.title.strip() or '未命名题目'
    source_url = payload.source_url.strip()

    difficulty = payload.difficulty or 'Medium'
    category_slug = 'simulation'
    time_limit_ms = payload.time_limit_ms or 2000
    memory_limit_kb = payload.memory_limit_kb or 262144
    company = payload.company.strip() or '未知'
    if analysis_service is not None:
        raw_text = _strip_html_to_text(payload.description_html)
        if not raw_text.strip():
            raw_text = payload.description_text
        if raw_text.strip():
            try:
                metadata = analysis_service.detect_metadata(raw_text)
                category_slug = metadata.get('category_slug', 'simulation')
                if not payload.difficulty:
                    difficulty = metadata.get('difficulty', 'Medium')
            except Exception:
                pass

    is_ssp = payload.source.strip() == 'ssp_offline'

    return ParsedProblemResult(
        slug=title,
        title=title,
        company=company,
        difficulty=difficulty,
        category_slug=category_slug,
        statement_markdown=statement_markdown,
        tags=['未分类'],
        time_limit_ms=time_limit_ms,
        memory_limit_kb=memory_limit_kb,
        source='SSPoffer' if is_ssp else '牛客',
        source_type='SSPoffer' if is_ssp else '牛客',
        frequency='中',
        year=None,
        source_ref=source_url,
        external_id=source_url,
        examples=examples,
        analysis='',
    )


def _build_import_payload(parsed, source_url: str) -> ProblemCreate:
    title = parsed.title.strip() or '未命名题目'
    slug = (parsed.slug.strip() or title).strip()
    if len(slug) < 3:
        slug = f'{slug}{"-" * (3 - len(slug))}'
    company = parsed.company.strip() or '未知'
    category_slug = parsed.category_slug.strip() or 'simulation'
    examples = parsed.examples
    example_items = [
        ExampleItem(
            input=item.input,
            output=item.output,
            explanation=item.explanation,
        )
        for item in examples
    ]
    statement_markdown = _append_examples_section(parsed.statement_markdown, examples)
    test_cases = examples[:]
    if test_cases:
        problem_test_cases = [
            ProblemTestCase(
                case_type='sample' if index == 0 else 'hidden',
                stdin_text=item.input,
                expected_output_text=item.output,
                sort_order=index + 1,
            )
            for index, item in enumerate(test_cases)
        ]
    else:
        problem_test_cases = [
            ProblemTestCase(
                case_type='hidden',
                stdin_text='hidden\n1',
                expected_output_text='0',
                sort_order=1,
            )
        ]

    return ProblemCreate(
        slug=slug,
        title=title,
        company=company,
        position='',
        difficulty=parsed.difficulty if parsed.difficulty in {'Easy', 'Medium', 'Hard'} else 'Medium',
        category_slug=category_slug,
        statement_markdown=statement_markdown if len(statement_markdown) >= 10 else statement_markdown.ljust(10),
        constraints_text='',
        time_limit_ms=parsed.time_limit_ms or 2000,
        memory_limit_kb=parsed.memory_limit_kb or 262144,
        tags=parsed.tags or ['未分类'],
        examples=example_items,
        supported_languages=['Python', 'C++', 'Java'],
        starter_templates={
            'Python': 'def solve() -> None:\n    pass\n',
            'C++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}\n',
            'Java': 'public class Main {\n    public static void main(String[] args) {\n    }\n}\n',
        },
        source_type=parsed.source_type or '牛客',
        source=parsed.source or '牛客',
        frequency=parsed.frequency or '中',
        year=parsed.year,
        source_ref=source_url.strip() or parsed.source_ref,
        external_id=source_url.strip() or parsed.external_id,
        status='未开始',
        test_cases=problem_test_cases,
    )


@router.get('', response_model=PaginatedProblemsResponse)
async def list_problems(
    company: str | None = Query(default=None),
    difficulty: str | None = Query(default=None),
    category_slug: str | None = Query(default=None),
    tag: str | None = Query(default=None),
    search: str | None = Query(default=None),
    position: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=50, ge=1, le=200),
    repository: ProblemRepository = Depends(get_repository),
) -> PaginatedProblemsResponse:
    items, total = repository.list_problems(
        company=company,
        department=None,
        difficulty=difficulty,
        category_slug=category_slug,
        tag=tag,
        search=search,
        position=position,
        page=page,
        page_size=page_size,
    )
    return PaginatedProblemsResponse(items=items, total=total, page=page, page_size=page_size)


@router.get('/distinct-companies', response_model=list[str])
async def distinct_companies(
    repository: ProblemRepository = Depends(get_repository),
) -> list[str]:
    return repository.distinct_companies()


@router.get('/distinct-positions', response_model=list[str])
async def distinct_positions(
    repository: ProblemRepository = Depends(get_repository),
) -> list[str]:
    return repository.distinct_positions()


@router.post('/import', response_model=ProblemDetail, status_code=status.HTTP_201_CREATED)
async def import_problem(
    payload: ProblemImportRequest,
    repository: ProblemRepository = Depends(get_repository),
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> ProblemDetail:
    return _import_single_problem(payload, repository, analysis_service, settings_repository)


def _import_single_problem(
    payload: ProblemImportRequest,
    repository: ProblemRepository,
    analysis_service: AnalysisService,
    settings_repository: LLMSettingsRepository,
) -> ProblemDetail:
    html_text = _strip_html_to_text(payload.description_html)
    description_text = payload.description_text.strip() or html_text
    samples = [item.model_dump() for item in payload.samples]
    raw_text = _build_import_raw_text(payload.title, description_text, samples)

    if payload.source.strip() in ('niuke_offline', 'ssp_offline'):
        parsed = _build_offline_import_result(payload, analysis_service)
    else:
        if not raw_text:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='导入内容为空')
        parsed = _parse_import_problem(analysis_service, settings_repository, raw_text)
        if payload.title.strip():
            parsed.title = payload.title.strip()
        parsed.source = '牛客'
        parsed.source_type = '牛客'
        parsed.source_ref = payload.source_url.strip() or parsed.source_ref
        parsed.external_id = payload.source_url.strip() or parsed.external_id

        if payload.samples:
            parsed.examples = [
                ParsedExample(
                    input=item.input.strip(),
                    output=item.output.strip(),
                    explanation=_normalize_import_example_text(item.explanation),
                )
                for item in payload.samples
                if item.input.strip() or item.output.strip() or item.explanation.strip()
            ]

    problem_payload = _build_import_payload(parsed, payload.source_url)
    return repository.create_problem(problem_payload)


@router.post('/import/batch', response_model=list[ProblemDetail], status_code=status.HTTP_201_CREATED)
async def batch_import_problems(
    payload: ProblemBatchImportRequest,
    repository: ProblemRepository = Depends(get_repository),
    settings_repository: LLMSettingsRepository = Depends(get_settings_repository),
    analysis_service: AnalysisService = Depends(get_analysis_service),
) -> list[ProblemDetail]:
    return [
        _import_single_problem(problem, repository, analysis_service, settings_repository)
        for problem in payload.problems
    ]


@router.post('/import-offline/extract', response_model=list[OfflineProblemCandidate])
async def extract_offline_problems(payload: OfflineProblemExtractRequest) -> list[OfflineProblemCandidate]:
    try:
        candidates = _extract_offline_problem_candidates(payload.file_content, payload.source_url)
    except ValueError as error:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(error)) from error

    if not candidates:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='离线文件中未识别到可导入的编程题')

    return candidates


@router.get('/{problem_id}', response_model=ProblemDetail)
async def get_problem(
    problem_id: int,
    repository: ProblemRepository = Depends(get_repository),
) -> ProblemDetail:
    problem = repository.get_problem(problem_id)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return problem


@router.post('', response_model=ProblemDetail, status_code=status.HTTP_201_CREATED)
async def create_problem(
    payload: ProblemCreate,
    repository: ProblemRepository = Depends(get_repository),
) -> ProblemDetail:
    return repository.create_problem(payload)


@router.put('/{problem_id}', response_model=ProblemDetail)
async def update_problem(
    problem_id: int,
    payload: ProblemCreate,
    repository: ProblemRepository = Depends(get_repository),
) -> ProblemDetail:
    problem = repository.update_problem(problem_id, payload)
    if problem is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')

    return problem


@router.delete('/{problem_id}', status_code=status.HTTP_204_NO_CONTENT)
async def delete_problem(
    problem_id: int,
    repository: ProblemRepository = Depends(get_repository),
) -> None:
    deleted = repository.delete_problem(problem_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Problem not found')
