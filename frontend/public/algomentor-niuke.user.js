// ==UserScript==
// @name         AlgoMentor - 牛客题面导入
// @namespace    https://algomentor.local
// @version      0.1.0
// @description  把当前牛客题目页一键导入 AlgoMentor
// @match        https://www.nowcoder.com/exam/question/*
// @match        https://www.nowcoder.com/exam/test/*/detail*
// @match        https://www.nowcoder.com/practice/*
// @grant        GM_xmlhttpRequest
// @connect      127.0.0.1
// ==/UserScript==

(function () {
  'use strict';

  const API_URL = 'http://127.0.0.1:8000/api/v1/problems/import';
  const BUTTON_ID = 'algomentor-niuke-import-button';

  function queryFirst(selectors) {
    for (const selector of selectors) {
      const element = document.querySelector(selector);
      if (element) {
        return element;
      }
    }
    return null;
  }

  function queryBest(selectors) {
    const candidates = [];
    for (const selector of selectors) {
      const elements = Array.from(document.querySelectorAll(selector));
      for (const element of elements) {
        const text = (element.innerText || '').trim();
        if (!text) {
          continue;
        }
        candidates.push({ element, score: text.length });
      }
    }

    candidates.sort((left, right) => right.score - left.score);
    return candidates.length > 0 ? candidates[0].element : null;
  }

  function collectSamples() {
    const titleNodes = Array.from(document.querySelectorAll('.item-title'));
    const structuredSamples = [];

    for (const titleNode of titleNodes) {
      const label = (titleNode.textContent || '').trim();
      if (!/^示例\s*\d+$/.test(label)) {
        continue;
      }

      let current = titleNode.nextElementSibling;
      const sample = { input: '', output: '', explanation: '' };
      while (current && !current.classList.contains('item-title')) {
        const text = (current.textContent || '').trim();
        if (/输入例子：/.test(text)) {
          const pre = current.querySelector('pre');
          sample.input = pre ? pre.innerText.trim() : text.replace(/^输入例子：\s*/, '').trim();
        } else if (/输出例子：/.test(text)) {
          const pre = current.querySelector('pre');
          sample.output = pre ? pre.innerText.trim() : text.replace(/^输出例子：\s*/, '').trim();
        } else if (/例子说明：/.test(text)) {
          const pre = current.querySelector('pre');
          sample.explanation = pre ? pre.innerText.trim() : text.replace(/^例子说明：\s*/, '').trim();
        }
        current = current.nextElementSibling;
      }

      if (sample.input || sample.output || sample.explanation) {
        structuredSamples.push(sample);
      }
    }

    if (structuredSamples.length > 0) {
      return structuredSamples;
    }

    const inputs = Array.from(document.querySelectorAll('.sample-input pre, .question-sample-input pre, .input pre, [data-role="sample-input"] pre, [class*="sample"] pre'));
    const outputs = Array.from(document.querySelectorAll('.sample-output pre, .question-sample-output pre, .output pre, [data-role="sample-output"] pre, [class*="sample"] pre'));
    const explanations = Array.from(document.querySelectorAll('.sample-explain, .question-sample-explain, .sample-desc, [data-role="sample-explain"], [class*="explain"]'));
    const total = Math.max(inputs.length, outputs.length, explanations.length);
    const samples = [];

    for (let index = 0; index < total; index += 1) {
      const input = inputs[index] ? inputs[index].innerText.trim() : '';
      const output = outputs[index] ? outputs[index].innerText.trim() : '';
      const explanation = explanations[index] ? explanations[index].innerText.trim() : '';
      if (!input && !output && !explanation) {
        continue;
      }
      samples.push({ input, output, explanation });
    }

    return samples;
  }

  function collectPayload() {
    const titleElement = queryFirst(['.subject-title', '.problem-title', 'h1']);
    const descriptionElement = queryBest([
      '.subject-des',
      '.question-detail',
      '.question-content',
      '.question-box',
      '.test-question-content',
      '.test-content',
      '.detail-content',
      '.question-wrapper',
      '.questionPanel',
      '.content-box',
      '.problem-wrapper',
      '.mark-down-box',
      '.mark-down-style',
      '.question-main',
      '.problem-content',
      '.describe-main',
      '.qc-post',
      'main',
      'article',
    ]);

    const fallbackElement = descriptionElement || queryBest(['body']);
    const descriptionHtml = fallbackElement ? fallbackElement.innerHTML : '';
    const descriptionText = fallbackElement ? fallbackElement.innerText : '';

    return {
      source: 'niuke',
      title: titleElement ? titleElement.innerText.trim() : document.title.replace(/\s*-\s*牛客网.*$/, '').trim(),
      description_html: descriptionHtml,
      description_text: descriptionText,
      samples: collectSamples(),
      source_url: window.location.href,
    };
  }

  function setButtonState(button, label, disabled) {
    button.textContent = label;
    button.disabled = disabled;
    button.style.opacity = disabled ? '0.75' : '1';
    button.style.cursor = disabled ? 'wait' : 'pointer';
  }

  function importProblem(button) {
    const payload = collectPayload();
    if (!payload.title || (!payload.description_text && !payload.description_html)) {
      window.alert('未找到题面内容，请确认当前页面已加载完成。');
      return;
    }

    setButtonState(button, '导入中...', true);
    GM_xmlhttpRequest({
      method: 'POST',
      url: API_URL,
      headers: {
        'Content-Type': 'application/json',
      },
      data: JSON.stringify(payload),
      onload(response) {
        if (response.status < 200 || response.status >= 300) {
          setButtonState(button, '导入失败', false);
          window.alert(`AlgoMentor 导入失败，状态码 ${response.status}`);
          return;
        }

        let result = null;
        try {
          result = JSON.parse(response.responseText);
        } catch (error) {
          setButtonState(button, '导入失败', false);
          window.alert('AlgoMentor 返回了无法解析的响应。');
          return;
        }

        setButtonState(button, '导入成功', false);
        window.alert(`已导入题目：${result.title || payload.title}，题目 ID：${result.id || '未知'}`);
        window.setTimeout(() => setButtonState(button, '导入 AlgoMentor', false), 1200);
      },
      onerror() {
        setButtonState(button, '导入失败', false);
        window.alert('无法连接 AlgoMentor 后端，请确认 http://127.0.0.1:8000 已启动。');
      },
    });
  }

  function mountButton() {
    if (document.getElementById(BUTTON_ID)) {
      return;
    }

    const button = document.createElement('button');
    button.id = BUTTON_ID;
    button.textContent = '导入 AlgoMentor';
    button.type = 'button';
    button.style.cssText = [
      'position: fixed',
      'top: 120px',
      'right: 20px',
      'z-index: 9999',
      'background: #2563eb',
      'color: #ffffff',
      'border: none',
      'padding: 10px 16px',
      'border-radius: 10px',
      'cursor: pointer',
      'font-size: 14px',
      'font-weight: 600',
      'box-shadow: 0 10px 24px rgba(37, 99, 235, 0.28)',
    ].join(';');
    button.addEventListener('click', () => importProblem(button));
    document.body.appendChild(button);
  }

  const observer = new MutationObserver(() => mountButton());
  observer.observe(document.documentElement, { childList: true, subtree: true });
  mountButton();
})();
