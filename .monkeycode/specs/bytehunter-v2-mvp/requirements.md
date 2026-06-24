# Requirements Document

## Introduction

ByteHunter v2 MVP 是一个面向国内大厂算法笔试与实习招聘场景的 AI 驱动型 ACM 训练平台。MVP 版本聚焦于手工录题、ACM 模式在线判题 IDE、AI 解题分析、AI 错误归因和错题复盘闭环，优先验证训练效率与复盘效率。

## Glossary

- **ByteHunter**: 本项目的训练平台。
- **Problem**: 平台中的单道算法题，包含题面、标签、样例、测试集和来源信息。
- **Manual Problem Entry**: 由运营者或管理员手工录入题目的方式。
- **Verdict**: 判题结果，包含 AC、WA、TLE、RE、CE 等状态。
- **Submission**: 用户提交的一次代码运行记录。
- **Error Attribution**: AI 对错误原因的归类结果。
- **Variation Practice**: 基于原题生成或组织相似训练题目的练习方式。

## Requirements

### Requirement 1

**User Story:** AS 求职训练用户, I want 浏览按公司和部门组织的题库, so that 我可以围绕目标岗位集中训练。

#### Acceptance Criteria

1. The system SHALL support manual problem entry for MVP problem creation.
2. WHEN an operator creates a problem, the system SHALL store company, department, title, statement, examples, constraints, difficulty, tags, and source metadata.
3. WHEN a user views the problem library, the system SHALL provide filters for company, department, difficulty, tag, and language support.
4. WHILE a problem is available for practice, the system SHALL display the problem statement, examples, constraints, and supported languages in a single problem detail view.
5. IF source metadata is provided, the system SHALL store `source_type`, `source_ref`, and `external_id` for future import compatibility.

### Requirement 2

**User Story:** AS 求职训练用户, I want 使用 ACM 模式在线判题 IDE 写代码, so that 我可以模拟真实笔试环境。

#### Acceptance Criteria

1. The system SHALL provide an ACM style online judge IDE for Python, C++, and Java.
2. WHEN a user opens a problem, the system SHALL load a language-specific starter template for the selected language.
3. WHEN a user edits code, the system SHALL preserve the draft automatically for the current session.
4. WHEN a user submits code, the system SHALL accept ACM style standard input and standard output execution.
5. WHILE a submission is running, the system SHALL show the execution status in the ACM style online judge IDE panel.
6. The system SHALL provide a `Run` action for self-test execution before formal submission.
7. WHEN a user clicks `Run`, the system SHALL execute the code against multiple visible test cases and return per-case results.

### Requirement 3

**User Story:** AS 求职训练用户, I want 获得真实的判题反馈, so that 我可以快速定位代码是否通过测试。

#### Acceptance Criteria

1. The system SHALL execute submissions in an isolated judge environment.
2. WHEN a submission finishes, the system SHALL return a normalized verdict with runtime and memory usage.
3. IF a submission result is WA, the system SHALL show the expected output and the actual output for at least one failed case in MVP.
4. IF a submission result is CE, the system SHALL show compiler diagnostics.
5. IF a submission result is TLE or RE, the system SHALL show the judge status and available runtime context.
6. IF a self-test or submission result is WA, the system SHALL provide a diff view between actual output and expected output.
7. IF a self-test or submission result is RE, the system SHALL show the stderr or stack trace fragment returned by the judge.

### Requirement 4

**User Story:** AS 求职训练用户, I want 获取 AI 解题分析, so that 我可以理解正确思路与关键知识点。

#### Acceptance Criteria

1. The system SHALL provide an AI analysis entry on each problem detail page.
2. WHEN a user requests solution analysis, the system SHALL generate an explanation that includes problem understanding, core idea, algorithm steps, complexity, and key edge cases.
3. WHEN reference materials are available, the system SHALL use the stored knowledge context to ground the analysis response.
4. WHILE AI analysis is streaming, the system SHALL present partial output to the user in the chat or analysis panel.
5. WHEN runtime stderr is available, the system SHALL allow AI analysis to incorporate the stderr context into the explanation.

### Requirement 5

**User Story:** AS 求职训练用户, I want 获取 AI 错误归因, so that 我可以知道代码错在什么层面并针对性改进。

#### Acceptance Criteria

1. The system SHALL provide an AI error attribution entry after each judged submission.
2. WHEN a user requests error attribution, the system SHALL analyze the submitted code, verdict, judge feedback, and available problem context.
3. WHEN the system returns an attribution result, the system SHALL include at least one primary error category and one concrete correction suggestion.
4. The system SHALL support an initial error taxonomy that includes boundary handling, state transition, greedy strategy, complexity, input parsing, integer overflow, initialization, and loop condition categories.
5. IF the AI can identify a probable code location, the system SHALL return line references that the frontend can highlight.
6. IF the verdict is RE and stderr or stack trace is available, the system SHALL allow AI attribution to infer the probable failing line and likely root cause.
7. WHEN line references are returned, the frontend SHALL support gutter markers and hover explanations on the related code lines.

### Requirement 6

**User Story:** AS 求职训练用户, I want 复盘历史提交和错题, so that 我可以形成稳定的训练闭环。

#### Acceptance Criteria

1. The system SHALL store each submission with user identity, problem identity, language, code snapshot, verdict, runtime, memory, and timestamp.
2. WHEN a user revisits a problem, the system SHALL show recent submission history and the latest verdict.
3. WHEN AI error attribution has been generated, the system SHALL attach the attribution result to the related submission record.
4. WHEN a user opens the review view, the system SHALL provide filters for wrong problems, company, tag, and error category.

### Requirement 7

**User Story:** AS 求职训练用户, I want 进行题目变形或重复训练, so that 我可以巩固同类题型。

#### Acceptance Criteria

1. The system SHALL support repeated practice from the same problem detail page.
2. The system SHALL support variation generation in later MVP iterations through structured variation types.
3. WHEN variation generation is enabled, the system SHALL constrain generated variations to one of these categories: data range change, constraint change, target change, input structure change, or same-knowledge-point scenario replacement.
4. WHILE variation generation is unavailable in the first MVP release, the system SHALL expose repeated practice and similar problem recommendations as the training continuation path.

### Requirement 8

**User Story:** AS 平台运营者, I want 平滑扩展到后续数据接入和 Agent 能力, so that 平台可以持续演进。

#### Acceptance Criteria

1. The system SHALL keep the problem ingestion model compatible with future batch import.
2. The system SHALL expose backend service boundaries for judge, AI analysis, problem management, and retrieval.
3. WHEN future Agent workflows are introduced, the system SHALL allow orchestration of judge, retrieval, and generation steps through backend services.
4. The system SHALL keep frontend and backend communication compatible with REST for request-response flows and WebSocket for streaming flows.
