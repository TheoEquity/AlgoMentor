#!/usr/bin/env python3
"""端到端测试：上传简历 → 解析填充 → 验证提取结果"""
from __future__ import annotations

import json
import os
import sys
import tempfile
import urllib.request
import urllib.error

BASE_URL = 'http://localhost:8000/api/v1'

def api(method, path, data=None, files=None):
    url = f'{BASE_URL}{path}'
    if method == 'DELETE':
        req = urllib.request.Request(url, method='DELETE')
        try:
            urllib.request.urlopen(req)
            return True
        except urllib.error.HTTPError:
            return False

    if files:
        boundary = '----FormBoundary7MA4YWxkTrZu0gW'
        body = b''
        for key, value in data.items():
            body += f'--{boundary}\r\n'.encode()
            body += f'Content-Disposition: form-data; name="{key}"\r\n\r\n'.encode()
            body += str(value).encode() + b'\r\n'
        filename, filebytes = files
        body += f'--{boundary}\r\n'.encode()
        body += f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'.encode()
        body += b'Content-Type: application/octet-stream\r\n\r\n'
        body += filebytes + b'\r\n'
        body += f'--{boundary}--\r\n'.encode()

        req = urllib.request.Request(url, data=body, method=method)
        req.add_header('Content-Type', f'multipart/form-data; boundary={boundary}')
    else:
        body = json.dumps(data).encode() if data else None
        req = urllib.request.Request(url, data=body, method=method)
        if body:
            req.add_header('Content-Type', 'application/json')

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f'  HTTP {e.code}: {body[:200]}')
        return None


def main():
    print('=== 简历解析端到端测试 ===\n')

    # Step 1: Clean up existing resumes
    print('[1/5] 清理已有简历...')
    list_resp = api('GET', '/resumes')
    if isinstance(list_resp, list):
        for r in list_resp:
            api('DELETE', f'/resumes/{r["id"]}')
        print(f'  已删除 {len(list_resp)} 条')

    # Step 2: Upload a test resume
    print('\n[2/5] 上传测试简历...')
    resume_text = '''
张三
zhangsan@example.com | 13800138000 | 期望城市：北京

教育经历
北京大学 | 计算机科学与技术 | 硕士 | 2023.09 - 2026.06 | GPA 3.9/4.0
课程：算法设计、机器学习、分布式系统
荣誉：国家奖学金、ACM金牌

清华大学 | 软件工程 | 本科 | 2019.09 - 2023.06 | GPA 3.8/4.0
课程：数据结构、操作系统、计算机网络
荣誉：优秀毕业生

技能
Python, Java, Go, React, TypeScript, PostgreSQL, Docker, Kubernetes

工作经历
字节跳动 | 后端开发实习生 | 2024.06 - 2024.09
- 参与用户增长系统开发，使用 Go 和 Kafka 处理日均 1000 万条事件
- 优化数据管道延迟从 500ms 降低到 50ms
- 编写 200+ 单元测试提升代码覆盖率至 85%

项目经历
分布式任务调度平台 | 技术负责人 | 2024.01 - 2024.05
技术栈：Go, Redis, PostgreSQL, Docker
- 设计并实现支持万级并发任务的调度引擎
- 引入优先级队列和负载均衡算法，任务响应时间降低 40%

证书
CET-6, 高级软件工程师

语言能力
英语 - 流利
中文 - 母语
'''

    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False, encoding='utf-8') as f:
        f.write(resume_text)
        tmp_path = f.name

    with open(tmp_path, 'rb') as f:
        file_data = f.read()

    result = api('POST', '/resumes',
                 data={'name': '测试简历', 'target_keywords': '["后端开发","Go","分布式"]', 'position_type': '2027秋招'},
                 files=(os.path.basename(tmp_path), file_data))

    os.unlink(tmp_path)

    if not result:
        print('  FAIL: 上传失败')
        sys.exit(1)

    resume_id = result.get('id')
    print(f'  创建成功，ID={resume_id}')
    print(f'  解析状态: {result.get("extract_status")}')
    if result.get('extract_error'):
        print(f'  解析错误: {result["extract_error"]}')

    # Step 3: Verify extracted info
    print('\n[3/5] 验证解析结果...')
    info = result.get('extracted_info')
    if not info:
        print('  FAIL: extracted_info 为空！')
        sys.exit(1)

    checks = [
        ('姓名', 'name', '张三'),
        ('邮箱', 'email', 'zhangsan@example.com'),
        ('电话', 'phone', '13800138000'),
        ('学校', lambda i: len(i.get('education', [])) > 0, True),
        ('技能', lambda i: len(i.get('skills', [])) > 0, True),
        ('经历', lambda i: len(i.get('experiences', [])) > 0, True),
        ('项目', lambda i: len(i.get('projects', [])) > 0, True),
        ('证书', lambda i: len(i.get('certifications', [])) > 0, True),
        ('语言', lambda i: len(i.get('languages', [])) > 0, True),
    ]

    all_pass = True
    for label, key, expected in checks:
        if callable(key):
            actual = key(info)
            if actual != expected:
                print(f'  FAIL: {label} → {actual}')
                all_pass = False
            else:
                print(f'  PASS: {label}')
        else:
            actual = info.get(key, '')
            if expected not in str(actual):
                print(f'  FAIL: {label} → 期望包含 "{expected}", 实际: "{actual}"')
                all_pass = False
            else:
                print(f'  PASS: {label} = {actual}')

    if all_pass:
        print('\n  >>> 所有核心字段解析正确')
    else:
        print('\n  >>> 部分字段未通过')

    # Step 4: Verify re-fetch
    print('\n[4/5] 重新获取验证持久化...')
    fetched = api('GET', f'/resumes/{resume_id}')
    if not fetched or not fetched.get('extracted_info'):
        print('  FAIL: 重新获取后 extracted_info 为空')
        sys.exit(1)
    print(f'  重新获取成功，extracted_info 存在')

    # Step 5: PUT info update
    print('\n[5/5] 测试 PUT /resumes/{id}/info...')
    new_info = dict(info)
    new_info['name'] = '张三李四'
    put_result = api('PUT', f'/resumes/{resume_id}/info', data=new_info)
    if put_result and put_result.get('extracted_info', {}).get('name') == '张三李四':
        print('  PASS: PUT info 更新成功')
    else:
        print(f'  FAIL: PUT info 更新失败, 实际: {put_result.get("extracted_info", {}).get("name") if put_result else None}')

    # Summary
    print(f'\n=== 测试结果: {"全部通过" if all_pass else "部分通过"} ===')


if __name__ == '__main__':
    main()
