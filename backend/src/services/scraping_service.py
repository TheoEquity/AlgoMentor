from __future__ import annotations

import asyncio
import json
from datetime import UTC, datetime

from playwright.async_api import async_playwright


SITE_SCRAPERS: dict[str, str] = {
    '中国电信': 'chinatelecom',
    '阿里巴巴': 'alibaba',
    '字节跳动': 'bytedance',
}


async def _scrape_chinatelecom(url: str, browser_settings: dict) -> list[dict]:
    """Scan all units and pages, collecting only title + location from list view (no click-into-detail)."""
    positions: list[dict] = []
    headless = browser_settings.get('headless', True)
    timeout = browser_settings.get('timeout_seconds', 30) * 1000

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=headless)
        context = await browser.new_context(
            viewport={'width': browser_settings.get('viewport_width', 1280), 'height': browser_settings.get('viewport_height', 720)},
        )
        page = await context.new_page()
        await page.goto(url, wait_until='networkidle', timeout=timeout)
        await asyncio.sleep(5)

        unit_items = await page.query_selector_all('div.list li')
        total_units = len(unit_items)
        print(f'[ChinaTelecom] Found {total_units} recruiting units')

        for unit_idx in range(total_units):
            lis = await page.query_selector_all('div.list li')
            if unit_idx >= len(lis):
                break
            unit_name = (await lis[unit_idx].inner_text()).strip()
            print(f'[ChinaTelecom] Unit {unit_idx+1}/{total_units}: {unit_name}')
            await lis[unit_idx].click()
            await asyncio.sleep(3)

            page_num = 1
            while True:
                job_items = await page.query_selector_all('div.post ul li')
                if len(job_items) == 0:
                    break

                for item in job_items:
                    try:
                        title_el = await item.query_selector('div.title')
                        labels = await item.query_selector_all('label')
                        title = (await title_el.inner_text()).strip() if title_el else ''
                        location = (await labels[1].inner_text()).strip() if len(labels) > 1 else ''
                        if title:
                            positions.append({
                                'title': title,
                                'company': unit_name,
                                'location': location,
                                'degree_requirement': '',
                                'description': '',
                                'apply_url': url,
                            })
                    except Exception:
                        continue

                next_btn = await page.query_selector('button:has-text(">"), li.next:not(.disabled) button, .paging-main-bo button:last-child')
                if next_btn and page_num <= 10:
                    try:
                        await next_btn.click()
                        await asyncio.sleep(2)
                        page_num += 1
                    except Exception:
                        break
                else:
                    break

            back_btn = await page.query_selector('span.btn:has-text("返回")')
            if back_btn:
                await back_btn.click()
                await asyncio.sleep(3)

        await browser.close()

    seen = set()
    unique = []
    for p in positions:
        key = p['title'] + (p.get('company') or '')
        if key not in seen:
            seen.add(key)
            unique.append(p)
    print(f'[ChinaTelecom] Total unique positions: {len(unique)}')
    return unique


async def _scrape_alibaba(url: str, browser_settings: dict) -> list[dict]:
    positions: list[dict] = []
    headless = browser_settings.get('headless', True)
    timeout = browser_settings.get('timeout_seconds', 30) * 1000

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=headless)
        context = await browser.new_context(
            viewport={'width': browser_settings.get('viewport_width', 1280), 'height': browser_settings.get('viewport_height', 720)},
        )
        page = await context.new_page()
        await page.goto(url, wait_until='networkidle', timeout=timeout)
        await asyncio.sleep(5)

        items = await page.query_selector_all('a[href*="position"], a[href*="job"], .position-item, .job-item, [class*="card"], li a')
        for item in items:
            try:
                href = await item.get_attribute('href')
                title = (await item.inner_text()).strip()
                if not title or len(title) < 2:
                    continue
                if href and not href.startswith('http'):
                    from urllib.parse import urlparse
                    parsed = urlparse(url)
                    href = f'{parsed.scheme}://{parsed.netloc}{href}'
                positions.append({
                    'title': title,
                    'company': '',
                    'location': '',
                    'degree_requirement': '',
                    'description': '',
                    'apply_url': href or '',
                })
            except Exception:
                continue

        await browser.close()
    # deduplicate by title
    seen = set()
    unique = []
    for p in positions:
        if p['title'] not in seen:
            seen.add(p['title'])
            unique.append(p)
    return unique


async def _scrape_bytedance(url: str, browser_settings: dict) -> list[dict]:
    positions: list[dict] = []
    headless = browser_settings.get('headless', True)
    timeout = browser_settings.get('timeout_seconds', 30) * 1000

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=headless)
        context = await browser.new_context(
            viewport={'width': browser_settings.get('viewport_width', 1280), 'height': browser_settings.get('viewport_height', 720)},
        )
        page = await context.new_page()
        await page.goto(url, wait_until='networkidle', timeout=timeout)
        await asyncio.sleep(5)

        items = await page.query_selector_all('a[href*="job"], a[href*="position"], .position-card, .job-card, [class*="card"], li a')
        for item in items:
            try:
                href = await item.get_attribute('href')
                title = (await item.inner_text()).strip()
                if not title or len(title) < 2:
                    continue
                if href and not href.startswith('http'):
                    if href.startswith('/'):
                        from urllib.parse import urlparse
                        parsed = urlparse(url)
                        href = f'{parsed.scheme}://{parsed.netloc}{href}'
                positions.append({
                    'title': title,
                    'company': '',
                    'location': '',
                    'degree_requirement': '',
                    'description': '',
                    'apply_url': href or '',
                })
            except Exception:
                continue

        await browser.close()
    seen = set()
    unique = []
    for p in positions:
        if p['title'] not in seen:
            seen.add(p['title'])
            unique.append(p)
    return unique


SCRAPERS = {
    'chinatelecom': _scrape_chinatelecom,
    'alibaba': _scrape_alibaba,
    'bytedance': _scrape_bytedance,
}


async def scrape_site(company_name: str, url: str, browser_settings: dict | None = None) -> list[dict]:
    if browser_settings is None:
        browser_settings = {'headless': True, 'timeout_seconds': 30, 'viewport_width': 1280, 'viewport_height': 720}

    scraper_key = SITE_SCRAPERS.get(company_name, 'generic')
    scraper = SCRAPERS.get(scraper_key, _scrape_generic)
    return await scraper(url, browser_settings)


async def _scrape_generic(url: str, browser_settings: dict) -> list[dict]:
    """Generic fallback scraper that tries common patterns."""
    positions: list[dict] = []
    headless = browser_settings.get('headless', True)
    timeout = browser_settings.get('timeout_seconds', 30) * 1000

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=headless)
        context = await browser.new_context(
            viewport={'width': browser_settings.get('viewport_width', 1280), 'height': browser_settings.get('viewport_height', 720)},
        )
        page = await context.new_page()
        await page.goto(url, wait_until='networkidle', timeout=timeout)
        await asyncio.sleep(5)

        selectors = [
            'table tbody tr',
            'a[href*="job"]', 'a[href*="position"]', 'a[href*="recruit"]', 'a[href*="detail"]',
            '.job-item', '.position-item', '.recruit-item',
            '[class*="job-card"]', '[class*="position-card"]',
            'ul.job-list li', 'ul.position-list li',
            'div.job-list > a', 'div.position-list > a',
            'a[class*="job"]', 'a[class*="position"]',
        ]
        items = []
        for sel in selectors:
            found = await page.query_selector_all(sel)
            if found:
                items = found
                break

        for item in items:
            try:
                href = await item.get_attribute('href') if await item.evaluate('el => el.tagName') == 'A' else None
                title = (await item.inner_text()).strip()[:200]
                if not title or len(title) < 3:
                    continue
                if href and not href.startswith('http') and href.startswith('/'):
                    from urllib.parse import urlparse
                    parsed = urlparse(url)
                    href = f'{parsed.scheme}://{parsed.netloc}{href}'
                positions.append({
                    'title': title,
                    'company': '',
                    'location': '',
                    'degree_requirement': '',
                    'description': '',
                    'apply_url': href or '',
                })
            except Exception:
                continue

        await browser.close()
    seen = set()
    unique = []
    for p in positions:
        key = p['title'][:50]
        if key not in seen:
            seen.add(key)
            unique.append(p)
    return unique


async def fetch_position_detail(
    company_name: str, url: str, job_title: str, unit_name: str, browser_settings: dict
) -> dict:
    """Navigate to a specific job posting and extract structured details.
    Scans all units on the page to find the job (unit_name is used as fallback hint)."""
    headless = browser_settings.get('headless', True)
    timeout = browser_settings.get('timeout_seconds', 30) * 1000
    result = {
        'title': job_title,
        'company': unit_name,
        'location': '',
        'description': '',
        'requirements': '',
        'priority': '',
        'other': '',
        'deadline': '',
        'degree_requirement': '',
        'apply_url': url,
    }

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=headless)
        context = await browser.new_context(
            viewport={'width': browser_settings.get('viewport_width', 1280), 'height': browser_settings.get('viewport_height', 720)},
        )
        page = await context.new_page()
        await page.goto(url, wait_until='networkidle', timeout=timeout)
        await asyncio.sleep(5)

        unit_items = await page.query_selector_all('div.list li')
        unit_names = []
        for item in unit_items:
            try:
                unit_names.append((await item.inner_text()).strip())
            except Exception:
                unit_names.append('')
        print(f'[Detail] Scanning {len(unit_names)} units for "{job_title}"')

        found_unit_name = unit_name
        external_break = False

        for unit_idx in range(len(unit_names)):
            if external_break:
                break
            name = unit_names[unit_idx]
            if not name:
                continue
            print(f'[Detail] Unit [{unit_idx}]: "{name}"')

            if unit_idx > 0:
                await page.goto(url, wait_until='networkidle', timeout=timeout)
                await asyncio.sleep(3)

            lis = await page.query_selector_all('div.list li')
            if unit_idx >= len(lis):
                break
            await lis[unit_idx].click()
            await asyncio.sleep(3)

            page_num = 1
            while page_num <= 10:
                job_items = await page.query_selector_all('div.post ul li')
                for item in job_items:
                    title_el = await item.query_selector('div.title')
                    title_text = (await title_el.inner_text()).strip() if title_el else ''
                    if job_title in title_text or title_text in job_title:
                        found_unit_name = name
                        result['company'] = name
                        await item.click()
                        await asyncio.sleep(1.5)
                        external_break = True
                        break

                if external_break:
                    break

                next_btn = await page.query_selector('.paging-main-bo button:last-child, li.next:not(.disabled) button, button:has-text(">"), a:has-text("下一页")')
                if next_btn:
                    await next_btn.click()
                    await asyncio.sleep(2)
                    page_num += 1
                else:
                    break

        if external_break:
            loc_el = await page.query_selector('span.post-workplace')
            if loc_el:
                result['location'] = (await loc_el.inner_text()).strip()

            content_el = await page.query_selector('div.content')
            if content_el:
                h2s = await content_el.query_selector_all('h2')
                for h2 in h2s:
                    h2_text = (await h2.inner_text()).strip().rstrip('：')
                    p_text = await h2.evaluate('el => { const next = el.nextElementSibling; return next ? next.innerText.trim() : ""; }')
                    if not p_text:
                        continue
                    if h2_text == '学历要求' and not result['degree_requirement']:
                        result['degree_requirement'] = p_text
                    elif h2_text == '岗位职责':
                        result['description'] = p_text
                    elif h2_text == '任职资格':
                        sub_parts = _split_sub_sections(p_text)
                        result['requirements'] = sub_parts.get('requirements', p_text)
                        result['priority'] = sub_parts.get('priority', '')
                    elif h2_text == '招聘人数':
                        pass

            if not result['degree_requirement']:
                degree_el = await page.query_selector('h2:has-text("学历要求") + p')
                if degree_el:
                    result['degree_requirement'] = (await degree_el.inner_text()).strip()

        await browser.close()

    return result


def _split_sub_sections(text: str) -> dict[str, str]:
    """Split a text block into requirements/priority/other sub-sections."""
    result: dict[str, str] = {'requirements': '', 'priority': '', 'other': ''}
    lines = text.split('\n')
    current = 'requirements'
    parts: dict[str, list[str]] = {'requirements': [], 'priority': [], 'other': []}
    for line in lines:
        stripped = line.strip()
        if stripped == '必备条件':
            current = 'requirements'
            continue
        elif stripped == '优先条件':
            current = 'priority'
            continue
        elif stripped in ('其他', '加分项'):
            current = 'other'
            continue
        parts[current].append(stripped)
    for k in parts:
        result[k] = '\n'.join(parts[k]).strip()
    return result


def _parse_sections(text: str) -> dict[str, str]:
    sections: dict[str, str] = {}
    current_key = ''
    current_value: list[str] = []
    section_headers = ['岗位职责', '任职资格', '必备条件', '优先条件', '其他', '截止时间',
                       '岗位职责：', '任职资格：', '必备条件：', '优先条件：', '其他：', '截止时间：',
                       '学历要求', '学历要求：']
    for line in text.split('\n'):
        stripped = line.strip()
        if not stripped:
            current_value.append('')
            continue
        is_header = False
        for h in section_headers:
            if stripped == h or stripped.startswith(h):
                if current_key:
                    sections[current_key] = '\n'.join(current_value).strip()
                current_key = h.rstrip('：')
                current_value = []
                is_header = True
                break
        if not is_header:
            current_value.append(stripped)
    if current_key:
        sections[current_key] = '\n'.join(current_value).strip()
    if '必备条件' in sections and '任职资格' not in sections:
        sections['任职资格'] = sections.pop('必备条件')
    elif '必备条件' in sections:
        sections['任职资格'] = sections['任职资格'] + '\n' + sections.pop('必备条件')
    return sections
