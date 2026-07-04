--
-- PostgreSQL database dump
--

\restrict COn5shxpzFn4If9hhKfzitB6z6ywY6GZtmsBP4SIgqsDKkO4p7pqbAJmVKB0YyO

-- Dumped from database version 15.18 (Debian 15.18-0+deb12u1)
-- Dumped by pg_dump version 15.18 (Debian 15.18-0+deb12u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: problems; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.problems VALUES
	(41, '设备故障预测程序', '设备故障预测程序', '华为', 'Medium', 'binary-search', '在一套对象存储集群中，运维同学希望根据设备运行日志，提前判断设备是否有故障风险，从而把数据在故障前迁移到其他节点。每条日志包含以下字段：设备ID、写入次数、读取次数、平均写入延迟(ms)、平均读取延迟(ms)、使用年限(年)、设备状态(0 正常/1 故障)。

请你实现一个设备故障预测程序，基于训练数据学习一个逻辑回归模型，并对给定的待预测设备输出是否故障的判定结果。

数据清洗规则

- 缺失值填充：数值字段出现字符串 NaN 时，用该字段在训练集中“有效数值”的均值进行填充。有效数值的含义见“异常值处理”。

- 异常值处理：若出现以下越界值，则视为异常，用该字段在训练集“有效数值”的中位数替换。

1.写入/读取次数：小于 0

2.平均写入/读取延迟：小于 0 或 大于 1000

3.使用年限：小于 0 或 大于 20

- 说明：计算均值/中位数时，只统计训练集中“有效数值”（即不含 NaN，且不越界）。若某字段在训练集没有任何有效数值，则该字段的均值与中位数都按 0 处理。

- 标签缺失：训练样本若无状态字段或无法解析为 0/1，丢弃该行，不参与训练，也不参与统计均值/中位数。

模型与训练

- 模型：二分类逻辑回归，带偏置项 w0。

- 训练方法：批量梯度下降（Batch GD），每次迭代用全部训练样本，学习率 0.01，迭代 100 次，初始权重全 0。

- 概率：

P(y=1) =$\frac{1}{1+e^{-z}}$ 其中 z = w0 + $\sum_{i=1}^{5}{w_ix_i}$

- 判定阈值：若 P(y=1) ≥ 0.5 则输出 1，否则输出 0。

## 输入格式

第一行：N（2 ≤ N ≤ 100）
接下来 N 行：每行一个训练样本
device_id,writes,reads,avg_write_ms,avg_read_ms,years,status
第 N+1 行：M（1 ≤ M ≤ 10）
接下来 M 行：每行一个待预测样本（无状态）
device_id,writes,reads,avg_write_ms,avg_read_ms,years

## 输出格式

共 M 行，每行输出一个整数 0 或 1，对应各待预测设备是否判定为故障。

## 样例

### 样例 1

**输入：**
```
12
n1,50,25,5,2,1,0
n2,55,27,5.5,2.5,1.2,0
n3,60,30,6,3,1.5,0
n4,65,32,6.5,3.2,1.8,0
n5,70,35,7,3.5,2,0
n6,75,37,7.5,3.8,2.2,0
n7,80,40,8,4,2.5,0
n8,85,42,8.5,4.2,2.7,0
n9,90,45,9,4.5,3,0
n10,95,47,9.5,4.8,3.2,0
p1,400,200,20,10,6,1
p2,500,250,22,11,8,1
2
q1,88,44,8.8,4.3,2.9
q2,480,240,21.5,10.8,7.5
```

**输出：**
```
0
1
```

**说明：**
训练集中负类远多于正类，模型学到明显负偏置；但正类样本特征显著更大，使对应权重为正。
q1落在负类量级附近，P<0.5 → 0；q2与正类量级接近，P≥0.5 → 1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678186/detail?pid=63699094&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678186/detail?pid=63699094&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:04:14.799875+00:00', '2026-07-02T12:06:45.921780+00:00', 2000, 262144, 'Ai'),
	(43, '找出相似度最高的文档', '找出相似度最高的文档', '华为', 'Medium', 'sliding-window', '为了更快追踪突发热点，我们仅在“查询时刻 t 之前的最近 K 篇文档”内计算 TF‑IDF，并以加权余弦相似度挑选最相关的文档。

窗口内越新的文档权重越高（从旧到新第 j 篇的权重为 (K−j+1)/K）。

给定按时间递增的文档序列和若干查询（每条查询含时间点 t 与查询短语 q），请在窗口中找出与 q 的加权余弦相似度最高且相似度≥0.6 的文档编号；若存在并列最高，返回窗口中最早的那一篇；若无满足阈值的文档，输出 -1。

- 
词向量用 TF‑IDF：TF 为词频；IDF 采用平滑公式 IDF(x)=log((N+1)/(df(x)+1))+1，其中 N 为窗口文档数，df(x) 为窗口内包含词 x 的文档数。

- 
余弦相似度采用 q 与每个文档向量的点积除以范数乘积；文档向量还需乘以其时间权重。

- 
文档与查询均以空格分词、统一小写，不做额外清洗。为避免早期窗口不足的问题，测试均保证 t ≥ K−1。

## 输入格式

第一行：文档总数 N 
接下来 N 行：按时间从 0 到 N−1 的文档内容（小写，空格分词） 
下一行：窗口大小 K 
下一行：查询总数 P 
接下来 P 行：每行“t 空格 q”表示在时间点 t 的查询 q

## 输出格式

输出 P 个数字，空格分隔；每个数字是对应查询的文档编号或 -1

## 样例

### 样例 1

**输入：**
```
5
breaking news finance market
sports football world cup
finance stock market rises
tech ai model training
finance market crash report
3
3
4 finance market
5 ai model
3 travel guide
```

**输出：**
```
4 3 -1
```

**说明：**
对 t=4，窗口为文档[2,3,4]。q="finance market" 与 2、4 的原始余弦相似度相同且约为 0.605≥0.6；时间权重越新越大（2:1/3, 3:2/3, 4:1），加权后 4 更高，返回 4。
对 t=5，窗口为[2,3,4]。q="ai model" 仅与文档3匹配（含 ai、model），原始余弦≈0.707≥0.6，返回 3。
对 t=3，窗口为[1,2,3]。q="travel guide" 窗口内均无重合词，余弦=0<0.6，返回 -1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678252/detail?pid=63881245&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678252/detail?pid=63881245&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:07:54.620955+00:00', '2026-07-02T12:08:36.876709+00:00', 2000, 262144, 'Ai'),
	(52, '模型量化最小误差', '模型量化最小误差', '华为', 'Medium', 'matrix-grid', '在一台边缘设备上部署一个已缩放到合适范围的神经网络权重矩阵。网络共有 N 层，每层有 H 个实数权重。每一层必须统一选择一个量化位宽 q，且 q 只能取 2、4、8 三种之一。所有层选择的位宽之和不超过 Qmax。

若某层选择位宽 q，则对该层每个权重 w 执行：

1) 放大并取整：wq = int(w * 2^q)

2) 还原：wr = wq / 2^q

该层的量化误差定义为该层所有权重的 |w - wr| 之和。全网误差为各层误差之和。目标是在总位宽预算不超过 Qmax 的前提下，使全网误差最小。输出最小总误差乘以 100 后向下取整的结果。

## 输入格式

- 第一行：N H Qmax
- 接下来 N 行：每行 H 个实数，表示对应层的权重

## 输出格式

- 一行，一个整数，为最小总误差乘以 100 后向下取整

## 样例

### 样例 1

**输入：**
```
2 3 8
0.1 0.5 0.9
0.3 0.75 0.2
```

**输出：**
```
12
```

**说明：**
若两层都选 4 比特，误差之和为 0.0625 + 0.0625 = 0.125
预算 4 + 4 = 8，满足约束
输出 floor(0.125 * 100) = 12
其他组合（如 2+4 或 2+2）误差更大', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678426/detail?pid=65575558&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678426/detail?pid=65575558&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:13:13.580305+00:00', '2026-07-02T12:13:26.388429+00:00', 2000, 262144, 'Ai'),
	(55, '小红的语言模型推理耗时预测', '小红的语言模型推理耗时预测', '华为', 'Easy', 'simulation', '小红正在开发一款大型语言模型的推理优化工具。为了能够准确预估模型在不同硬件任务下的耗时情况，她打算构建一个简单的线性回归模型。该模型通过三个关键特征：协议连接数、包转发率和内存占用百分比，来预测最终的资源消耗指标值。

为了提高模型的训练效率和稳定性，小红决定采用带有数据归一化处理的批量梯度下降法（Batch Gradient Descent, BGD）来优化模型参数。具体流程如下：

1. 特征归一化：对每一列特征分别进行 Min-Max 归一化。假设某列特征为 x，其最小值为 min，最大值为 max，则归一化后的值 $x'' = (x - min) / (max - min)$。若该列的最大值与最小值相等，则该列所有归一化后的值直接设为 0。

2. 权重训练：初始化偏置项 w0 以及三个特征对应的权重 w1、w2、w3 为 0。随后进行 N 轮迭代，每轮迭代中小红会根据当前的权重计算所有样本的预测值，并以此计算梯度。梯度的计算方式为：第 k 个权重的梯度等于所有样本的“预测值与真实值之差”乘以“该样本第 k 个归一化特征”后的平均值（对于 w0，其对应的特征值恒为 1）。所有权重在每一轮结束时同时进行更新：$w_k \leftarrow w_k - \alpha \cdot g_k$，其中 $\alpha$ 为学习率，g_k 为梯度。

3. 权重还原：训练完成后，需要将归一化空间下的权重还原回原始数据的量纲。特征权重还原公式为 $w''_j = w_j / (max_j - min_j)$（若 max = min，则还原权重为 0）。还原后的偏置项公式为：$w''_0 = w_0 - \sum_{j=1}^3 (w''_j \cdot min_j)$。

请你帮助小红完成这个训练过程，并输出还原后的最终参数。

## 输入格式

第一行输入一个整数 m（1 ≤ m ≤ 10000），表示训练样本的数量。
第二行输入一个整数 N（1 ≤ N ≤ 1000），表示梯度下降的迭代次数。
第三行输入一个浮点数 $\alpha$（0.00 ≤ $\alpha$ ≤ 1.00），表示学习率。
接下来的 m 行，每行包含 4 个整数 x1, x2, x3, y。其中 x1、x2、x3 分别为三个特征值（0 ≤ x1 ≤ 1000, 0 ≤ x2 ≤ 10000, 0 ≤ x3 ≤ 100），y 为资源消耗的真实观测值（0 ≤ y ≤ 10000）。

## 输出格式

输出一行，包含 4 个浮点数，分别代表还原后的 w0, w1, w2, w3。结果需使用银行家舍入法（即四舍六入五成双：保留位后一位小于 5 则舍去，大于 5 则进位，等于 5 且后面无其他非零数时看前一位，前一位为偶数则舍去，奇数则进位）保留 2 位小数，数值之间用空格隔开。

## 样例

### 样例 1

**输入：**
```
2
1
0.10
10 100 5 50
20 300 15 100
```

**输出：**
```
-2.50 0.50 0.02 0.50
```

**说明：**
在本样例中，第一列特征的范围是 [10, 20]，第二列是 [100, 300]，第三列是 [5, 15]。

归一化后，第一个样本的特征为 (0, 0, 0)，真实值为 50；第二个样本特征为 (1, 1, 1)，真实值为 100。

初始权重均为 0，经过 1 轮迭代更新后，归一化权重 w0 为 7.5，w1, w2, w3 均为 5.0。

最后进行量纲还原，得到 w''1 = 0.5, w''2 = 0.025, w''3 = 0.5, w''0 = -2.5。

按照银行家舍入法，0.025 舍入两位小数为 0.02（因为 2 是偶数），故输出结果如上。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97678284/detail?pid=66845060&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678284/detail?pid=66845060&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:15:45.994810+00:00', '2026-07-02T12:16:09.819709+00:00', 2000, 262144, 'Ai'),
	(195, '反转链表', '反转链表', '牛客', 'Easy', 'linked-list', '给定一个单链表的头结点pHead(该头节点是有值的，比如在下图，它的val是1)，长度为n，反转该链表后，返回新链表的表头。 

数据范围： $0\leq n\leq1000$ 
要求：空间复杂度 $O(1)$ ，时间复杂度 $O(n)$ 。 

如当输入链表{1,2,3}时， 
经反转后，原链表变为{3,2,1}，所以对应的输出为{3,2,1}。 
以上转换过程如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211014/423483716_1634206291971/4A47A0DB6E60853DEDFCFDF08A5CA249)

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,2,3}
```

**输出：**
```
{3,2,1}
```

### 样例 2

**输入：**
```
{}
```

**输出：**
```
{}
```

**说明：**
空链表则输出空', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/75e878df47f24fdc9dc3e400ec6058ca?tpId=295&tqId=23286&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/75e878df47f24fdc9dc3e400ec6058ca?tpId=295&tqId=23286&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.025147+00:00', '2026-07-03T12:14:03.114838+00:00', 2000, 262144, '常见101'),
	(234, '重建二叉树', '重建二叉树', '牛客', 'Medium', 'tree', '给定节点数为 n 的二叉树的前序遍历和中序遍历结果，请重建出该二叉树并返回它的头结点。 
例如输入前序遍历序列{1,2,4,7,3,5,6,8}和中序遍历序列{4,7,2,1,5,3,8,6}，则重建出如下图所示。 

![题面配图](https://uploadfiles.nowcoder.com/images/20210717/557336_1626504921458/776B0E5E0FAD11A6F15004B29DA5E628)

提示: 
1.vin.length == pre.length 
2.pre 和 vin 均无重复元素 
3.vin出现的元素均出现在 pre里 
4.只需要返回根结点，系统会自动输出整颗树做答案对比 
数据范围：$n \le 2000$，节点的值 $-10000 \le val \le 10000$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,2,4,7,3,5,6,8],[4,7,2,1,5,3,8,6]
```

**输出：**
```
{1,2,3,4,#,5,6,#,7,#,#,8}
```

**说明：**
返回根节点，系统会输出整颗二叉树对比结果，重建结果如题面图示

### 样例 2

**输入：**
```
[1],[1]
```

**输出：**
```
{1}
```

### 样例 3

**输入：**
```
[1,2,3,4,5,6,7],[3,2,4,1,6,5,7]
```

**输出：**
```
{1,2,5,3,4,6,7}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/8a19cbe657394eeaac2f6ea9b0f6fcf6?tpId=295&tqId=23282&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/8a19cbe657394eeaac2f6ea9b0f6fcf6?tpId=295&tqId=23282&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:34.138913+00:00', '2026-07-03T16:39:28.930399+00:00', 2000, 262144, '常见101'),
	(56, '小红的 AI 配送聚类优化', '小红的 AI 配送聚类优化', '华为', 'Medium', 'graphs', '小红正在为自研的无人驾驶配送机器人开发一套路径规划系统。为了提高效率，配送系统需要先将分散的包裹坐标通过无监督学习算法进行聚类，确定 $K$ 个核心服务点，然后再由机器人按顺序前往这些点。

小红选用了经典的 K-Means 算法。具体聚类与路径规划逻辑如下：

1. 初始化：
- 如果服务中心数量 $K$ 大于或等于包裹总数 $N$，则每个包裹坐标直接作为最终的服务点坐标。
- 否则，先计算所有包裹到坐标原点 (0,0) 的欧几里得距离，并按距离从小到大排序。若距离相同，保持原始输入顺序。选取排序后的前 $K$ 个包裹坐标作为初始聚类中心，并赋予编号 0 到 $K-1$。

2. 聚类迭代（最多迭代 50 次）：
- 分配阶段：将每个包裹分配给距离其最近的聚类中心。若某包裹到多个中心的距离相等，则分配给编号最小的中心。
- 更新阶段：将每个中心的位置更新为其所分配的所有包裹坐标的平均值。如果某个中心没有分配到任何包裹，则其坐标保持不变。
- 终止条件：计算所有中心在本次更新中移动的欧几里得距离之和。若该距离之和小于 $10^{-4}$，或者已完成 50 次迭代，则停止。

3. 路径规划与耗时计算：
- 聚类完成后，将最终得到的 $K$ 个服务点坐标按其到原点 (0,0) 的欧几里得距离进行升序排列。
- 机器人从原点 (0,0) 出发，依次访问这 $K$ 个点，最后返回原点 (0,0)。
- 计算机器人走完这段闭环路径的总长度，并根据平均时速计算总耗时。

请帮小红计算完成配送任务所需的总秒数。

## 输入格式

第一行包含三个空格分隔的整数，分别是服务中心数量 $K$、包裹总数 $N$（$1 \leq K \leq 10,\ 1 \leq N \leq 100$），以及配送机器人的平均速度 speed（$1 \leq speed \leq 100$，单位 km/h）。

接下来的 $N$ 行，每行包含两个实数 $x_i$ 和 $y_i$（$-100.0 \leq x_i, y_i \leq 100.0$），表示每个包裹在地图上的公里坐标。

## 输出格式

输出一个整数，表示完成任务所需的总时间（秒）。结果请向下取整。

## 样例

### 样例 1

**输入：**
```
2 3 36
3.0 4.0
6.0 8.0
0.0 5.0
```

**输出：**
```
1710
```

**说明：**
在本样例中，$K=2, N=3$，机器速速度为 36 km/h。
1. 包裹到原点的距离分别为 5.0, 10.0, 5.0。排序后选择坐标 (3,4) 为中心 0，(0,5) 为中心 1。
2. 经过聚类迭代，中心 0 最终更新为 (4.5, 6.0)，中心 1 为 (0.0, 5.0)。
3. 两个服务点到原点距离分别为 7.5 和 5.0。访问顺序为 (0,0) -> (0,5) -> (4.5, 6) -> (0,0)。
4. 总路径长度约为 5 + 4.6098 + 7.5 = 17.1098 km。
5. 总耗时约为 $17.1098 / 36 \times 3600 = 1710.98$ 秒，向下取整得 1710。

### 样例 2

**输入：**
```
3 10 30
1.2 1.5
1.8 1.2
5.0 5.2
5.5 4.8
4.9 5.5
-2.0 3.0
-2.5 3.5
-1.8 2.8
1.5 1.8
5.2 5.0
```

**输出：**
```
2502
```

**说明：**
For 3 communities, 10 packages, and speed 30 km/h, the 10 packages are clustered into 3 centers. Sorted by distance to the origin, the centers are approximately (1.5, 1.5), (-2.1, 3.1), and (5.15, 5.125). The total distance traversed visiting them in order and returning to the origin takes approximately 2502 seconds (floor applied). Note: if K >= N, all N points become their own cluster centers.', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97678284/detail?pid=66845060&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678284/detail?pid=66845060&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:15:46.045227+00:00', '2026-07-02T12:15:59.280517+00:00', 2000, 262144, 'Ai'),
	(61, '基因序列相似度分析', '基因序列相似度分析', '华为', 'Medium', 'hashing', '在基因工程研究中，科学家们经常需要将一个新发现的基因片段与一个庞大的已知基因序列数据库进行比对，以寻找功能或来源上最相似的序列。这种相似度通常通过所谓的“突变距离”来衡量。

突变距离（即莱文斯坦距离）被定义为：将一个基因序列转换为另一个序列所需的最少“点突变”操作次数。允许的点突变操作有三种：

1. 替换 (Substitution)：将一个碱基替换成另一个碱基。

2. 插入 (Insertion)：在一个序列的任意位置插入一个碱基。

3. 删除 (Deletion)：从一个序列中删除任意一个碱基。

你的任务是编写一个程序，对于一个给定的待测基因片段，从数据库中找出所有与之足够相似的基因序列。

## 输入格式

第一行是一个整数 $D$，代表可接受的最大突变容忍度。
第二行是一个整数 $N$，代表基因数据库中序列的总数。
接下来 $N$ 行，每行是一个已知的基因序列。
最后一行是待测的基因片段。

约束条件：
* $1 \le D \le 5$
* $1 \le N \le 30000$
* 单个基因序列的长度 $L$ 满足 $2 \le L \le 25$。
* 为简化模型，所有基因序列只包含小写英文字母。

## 输出格式

根据比对结果，分三种情况输出：

1. 精确匹配：如果待测基因片段与数据库中的某个序列完全相同，直接输出该序列。
2. 模糊匹配：如果不存在精确匹配，则找出所有与待测片段的突变距离小于或等于 $D$ 的序列。将这些序列首先按突变距离从小到大排序，若距离相同，则按字典序从小到大排序。最后将排序后的结果用空格隔开，在一行内输出。
3. 无匹配：如果不存在精确匹配，且数据库中没有任何序列满足突变距离小于或等于 $D$ 的条件，则输出 None 。

## 样例

### 样例 1

**输入：**
```
2
10
xomputer
compter
yomputerz
comput
aomputer
pmrphtow
qgktdywi
hsgysjll
sepmotrz
cibmmdie
computer
```

**输出：**
```
aomputer compter xomputer comput yomputerz
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678396/detail?pid=63554020&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678396/detail?pid=63554020&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:18:05.230531+00:00', '2026-07-02T12:18:29.936096+00:00', 2000, 262144, '开发'),
	(63, '量子门', '量子门', '华为', 'Medium', 'bit-manipulation', '在一个前沿的量子计算实验中，一组 $n$ 个量子比特（qubit）被初始化到一个特定的纠缠态。

然而，为了进行下一步的计算，必须将所有量子比特精确地重置到基态，即 $|0\rangle$ 态。

由于量子纠缠的复杂性，对单个量子比特施加操作门（quantum gate）不仅会改变其自身的状态，还可能同时翻转其他与之纠缠的量子比特的状态。

系统的状态可以用一个 $n$ 维的二进制向量 $S = (s_1, s_2, \dots, s_n)$ 来描述，其中 $s_i \in \{0, 1\}$。$s_i = 1$ 表示第 $i$ 个量子比特处于激发态 $|1\rangle$，$s_i = 0$ 表示处于基态 $|0\rangle$。

我们有 $n$ 种量子门操作，记为 $G_1, G_2, \dots, G_n$。施加操作 $G_i$ 的效果如下：

1. 必定会翻转第 $i$ 个量子比特的状态，即 $s_i \to 1 - s_i$。

2. 由于纠缠效应，施加 $G_i$ 还会翻转一系列其他量子比特 $s_j, s_k, \dots$ 的状态。

每次操作都是一个翻转操作（异或 $1$）。同一个操作施加两次会抵消其效果。我们的目标是找到一个操作序列，使得系统从初始状态 $S_{initial}$ 演化到全零向量 $S_{final} = (0, 0, \dots, 0)$。

给定系统的初始状态和所有 $n$ 种操作的纠缠影响关系，请找出一个解决方案。如果不存在任何解决方案，则输出 $-1$。若存在多种解决方案，您需要输出满足以下条件的最优解：

1. 施加的操作门数量最少。

2. 在数量最少的基础上，选择操作序列的字典序最小的方案（即操作的量子比特编号组成的序列）。

## 输入格式

第一行包含两个整数 $n$ 和 $m$，分别代表量子比特的数量和额外的纠缠关系数量。数据范围为 $1 \le n \le 20$，$0 \le m \le n \cdot (n - 1)$。

第二行包含 $n$ 个整数，表示初始状态向量 $S_{initial}$。第 $i$ 个整数 $s_i \in \{0, 1\}$ 代表第 $i$ 个量子比特的初始状态。

接下来的 $m$ 行，每行包含两个整数 $x, y$ ($1 \le x, y \le n, x \neq y$)，表示施加量子门 $G_x$ 会额外翻转量子比特 $y$ 的状态。

## 输出格式

如果无解，输出一行 $-1$。

如果有解，输出一行升序排列的整数，代表最优操作序列中需要施加的量子门的编号。整数之间用单个空格分隔。

## 样例

### 样例 1

**输入：**
```
3 5
1 1 1
1 2
2 1
2 3
3 1
3 2
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
4 6
1 0 0 0
1 4
2 1
2 4
3 1
4 2
4 3
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678649/detail?pid=64321083&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678649/detail?pid=64321083&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:20:00.713987+00:00', '2026-07-02T12:20:27.971153+00:00', 2000, 262144, '开发'),
	(216, '比较版本号', '比较版本号', '牛客', 'Medium', 'binary-search', '牛客项目发布项目版本时会有版本号，比如1.02.11，2.14.4等等 
现在给你2个版本号version1和version2，请你比较他们的大小 
版本号是由修订号组成，修订号与修订号之间由一个"."连接。1个修订号可能有多位数字组成，修订号可能包含前导0，且是合法的。例如，1.02.11，0.1，0.2都是合法的版本号 
每个版本号至少包含1个修订号。 
修订号从左到右编号，下标从0开始，最左边的修订号下标为0，下一个修订号下标为1，以此类推。 

比较规则： 
一. 比较版本号时，请按从左到右的顺序依次比较它们的修订号。比较修订号时，只需比较忽略任何前导零后的整数值。比如"0.1"和"0.01"的版本号是相等的 
二. 如果版本号没有指定某个下标处的修订号，则该修订号视为0。例如，"1.1"的版本号小于"1.1.1"。因为"1.1"的版本号相当于"1.1.0"，第3位修订号的下标为0，小于1 
三. version1 > version2 返回1，如果 version1 < version2 返回-1，不然返回0. 

数据范围： 
$1 <= version1.length, version2.length <= 1000$ 
version1 和 version2 的修订号不会超过int的表达范围，即不超过 32 位整数 的范围 

进阶： 空间复杂度 $O(1)$ ， 时间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"1.1","2.1"
```

**输出：**
```
-1
```

**说明：**
version1 中下标为 0 的修订号是 "1"，version2 中下标为 0 的修订号是 "2" 。1 < 2，所以 version1 < version2，返回-1

### 样例 2

**输入：**
```
"1.1","1.01"
```

**输出：**
```
0
```

**说明：**
version2忽略前导0，为"1.1"，和version相同，返回0

### 样例 3

**输入：**
```
"1.1","1.1.1"
```

**输出：**
```
-1
```

**说明：**
"1.1"的版本号小于"1.1.1"。因为"1.1"的版本号相当于"1.1.0"，第3位修订号的下标为0，小于1，所以version1 < version2，返回-1

### 样例 4

**输入：**
```
"2.0.1","2"
```

**输出：**
```
1
```

**说明：**
version1的下标2>version2的下标2，返回1

### 样例 5

**输入：**
```
"0.226","0.36"
```

**输出：**
```
1
```

**说明：**
226>36，version1的下标2>version2的下标2，返回1', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/2b317e02f14247a49ffdbdba315459e7?tpId=295&tqId=1024572&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/2b317e02f14247a49ffdbdba315459e7?tpId=295&tqId=1024572&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:24:52.258281+00:00', '2026-07-03T12:25:53.829797+00:00', 2000, 262144, '常见101'),
	(46, '最优分词器', '最优分词器', '华为', 'Medium', 'simulation', '你在为一门极少见的语言做专用分词。语言学家给出了一个“小词典”，每个条目都有一个分值，表示该词单独成词的合理性强弱。

同时，还收集了“相邻词对”的转移加分：当上一个词与下一个词按某种搭配出现时，整体会多（或少）一些分数。

你的目标是在给定的连续小写字母串中，切分出一条完整的词序列，使“词典分+转移加分”的总和最大。如果无法用词典完全覆盖整串，则输出0。

## 输入格式

第一行：文本串 text，仅含小写英文字母。
第二行：整数 n，表示词典条目数。
接下来 n 行：每行一个词与其分值，中间用空格分隔。
接下来一行：整数 m，表示转移加分条目数。
接下来 m 行：每行包含“前词 后词 加分”，三者以空格分隔，加分可为负。

## 输出格式

一行，一个整数：最大可获得的总分。如果不存在任何完整切分，输出0。

## 样例

### 样例 1

**输入：**
```
aababa
4
a 1
aa 3
ab 2
ba 2
3
aa ba 2
ba ba -1
ab a 1
```

**输出：**
```
8
```

**说明：**
- 最优切分：aa | ba | ba
- 词典分：3 + 2 + 2 = 7
- 转移分：aa→ba = +2，ba→ba = -1
- 总分：7 + 2 - 1 = 8

- 其他可行切分（例如：a | ab | a | ba）
- 词典分：1 + 2 + 1 + 2 = 6
- 转移分：ab→a = +1（其余未命中）
- 总分：6 + 1 = 7
因此最优答案为 8。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678130/detail?pid=64093122&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678130/detail?pid=64093122&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:09:34.677641+00:00', '2026-07-02T12:09:50.050195+00:00', 2000, 262144, 'Ai'),
	(51, '三项评分线性定价', '三项评分线性定价', '华为', 'Medium', 'simulation', '给定若干已上市手机的三项评分与售价，请用线性模型估计参数，再据此预测新的机型价格。三项评分分别表示硬件能力、系统流畅度和智能能力。设价格由四个系数决定：一个常数项和对应三项评分的权重。你需要用最小二乘的闭式解（即正规方程）拟合参数，然后对新机型输出四舍五入后的价格（单位同输入）。

## 输入格式

- 第1行：整数 K，表示已知样本数量。
- 第2行：共 4K 个整数，按样本顺序依次给出：x1 x2 x3 price，重复 K 次。
- 第3行：整数 N，表示需要预测的机型数量。
- 第4行：共 3N 个整数，按机型顺序依次给出：x1 x2 x3，重复 N 次。

## 输出格式

- 输出 N 个整数，分别为每个待预测机型的价格，空格分隔。

## 样例

### 样例 1

**输入：**
```
4
10 20 30 2400 5 0 10 1350 0 10 5 1350 20 15 0 1500
3
7 3 1 12 10 8 0 0 0
```

**输出：**
```
1160 1560 1000
```

**说明：**
- 真实模型：price = 1000 + 10*x1 + 20*x2 + 30*x3
- 预测：
- (7,3,1) → 1000+70+60+30=1160
- (12,10,8) → 1000+120+200+240=1560
- (0,0,0) → 1000', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678426/detail?pid=65575558&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678426/detail?pid=65575558&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:13:13.529662+00:00', '2026-07-02T12:13:36.566648+00:00', 2000, 262144, 'Ai'),
	(39, '标签在前K个近邻中的出现次数', '标签在前K个近邻中的出现次数', '华为', 'Easy', 'simulation', '- 
你需要为一个简单的多分类识别器补上“K 近邻”判别模块。做法是：先度量待测样本与训练样本的距离，挑选出距离最近的 K 个样本，再用多数票决定最终类别。

- 
操作要点（按流程执行）：

- 
先计算待测点到每个样本点的距离（为了效率，可直接用“平方欧氏距离”参与排序，结果等价）。

- 
将样本按距离升序排列，截取前 K 个作为近邻。

- 
统计这 K 个近邻的标签出现次数，频数最高的标签即为预测值。

- 
如出现“最高频数并列”，只在并列标签对应的近邻里，按由近到远的顺序挑第一个的标签。

- 
约束与假设：

- 
数据集已做归一化处理（不同维度量纲一致），特征保留两位小数。

- 
每个类别在数据集中都至少有一个样本。

- 
距离采用欧氏距离：$d(q,x)=\sqrt{\sum_{i=1}^{n}(q_i-x_i)^2}$

## 输入格式

- 第 1 行：k m n s
k 为最近邻个数（≤20），m 为样本数（≤200），n 为特征维度（不含标签，≤5），s 为类别个数（≤5）。
- 第 2 行：待分类样本的 n 维特征。
- 第 3 行至第 m+2 行：每行 n+1 列，前 n 列为特征，最后 1 列为类别标签（整数，以浮点给出）。

## 输出格式

输出两项：预测标签 与 该标签在前 K 个近邻中的出现次数 
格式：label count

## 样例

### 样例 1

**输入：**
```
3 6 2 2
0.00 0.00
0.20 0.10 0.0
0.30 0.00 0.0
0.00 0.40 1.0
0.60 0.60 1.0
0.05 0.02 0.0
0.90 0.90 1.0
```

**输出：**
```
0 3
```

**说明：**
距离最近的 3 个样本依次为 (0.05,0.02,0), (0.20,0.10,0), (0.30,0.00,0)。 
多数票为标签 0，且在前 K=3 个邻居中出现 3 次，故输出“0 3”。

### 样例 2

**输入：**
```
4 6 2 3
1.00 1.00
0.95 0.95 2.0
1.10 1.00 2.0
0.90 1.10 1.0
0.80 0.90 1.0
2.00 2.00 3.0
1.30 1.40 1.0
```

**输出：**
```
2 2
```

**说明：**
最近的 4 个邻居按距离为：(0.95,0.95,2)、(1.10,1.00,2)、(0.90,1.10,1)、(0.80,0.90,1)。 
标签 1 与 2 在前 K=4 中均出现 2 次，构成并列；比较并列集合中“最近”的样本，其最近者为 (0.95,0.95,2)，因此最终返回标签 2；同时输出该标签在前 K 中出现的次数 2。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678205/detail?pid=63554070&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678205/detail?pid=63554070&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T09:03:05.597136+00:00', '2026-07-02T12:02:28.151649+00:00', 2000, 262144, 'Ai'),
	(45, '简化Attention输出的元素总和', '简化Attention输出的元素总和', '华为', 'Medium', 'matrix-grid', '- 
给定三个正整数 n、m、h（均小于 100），构造如下数据并计算结果。

- 
数据构造规则：

- 
输入特征矩阵 X 为 n×m 的全 1 矩阵。

- 
三个权重矩阵 W1、W2、W3 均为 m×h 的“上三角全 1”矩阵（按行列索引在主对角线及其上方位置为 1，其余为 0；当 m≠h 时视为按行列索引的上三角扩展）。

- 
令 Q=X·W1，K=X·W2，V=X·W3；计算 S=(Q·K^T)/sqrt(h)。

- 
softmax 按行做“归一化”：对任意行向量 r，softmax(r) 的每个元素等于该元素除以本行所有元素之和。

- 
Y=softmax(S)·V。

- 
输出要求：求矩阵 Y 所有元素的和，四舍五入到整数后输出。

## 输入格式

一行，三个正整数 n m h（均小于 100，且均>0）

## 输出格式

一行，一个整数：矩阵 Y 的元素和（四舍五入后）

## 样例

### 样例 1

**输入：**
```
5 4 3
```

**输出：**
```
30
```

**说明：**
h≤m，单行和为 1+2+3=6；总和= n×6 = 5×6=30。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678130/detail?pid=64093122&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678130/detail?pid=64093122&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:09:34.616531+00:00', '2026-07-02T12:10:04.184092+00:00', 2000, 262144, 'Ai'),
	(57, '小红的云服务器带宽预测模型', '小红的云服务器带宽预测模型', '华为', 'Easy', 'simulation', '小红目前是某云服务平台的 AI 工程师。为了更精准地分配机房带宽资源，她打算训练一个简单的线性神经元模型，用于实时预测每台服务器的出口带宽需求。

该模型接受两个输入特征：当前活跃连接数 $x_1$ 和历史平均延迟指标 $x_2$。模型的预测输出 $y_{pred}$ 的计算方式如下：
$y_{pred} = w_1 x_1 + w_2 x_2 + b$
其中 $w_1, w_2$ 为特征权重，$b$ 为偏置项。

为了让模型能够处理大规模的实时数据流，小红决定采用 AdamW 优化器进行参数更新。具体算法流程如下：

1. 初始化：初始参数 $w_1 = 0, w_2 = 0, b = 0$。对应的动量估计（一阶矩）$m$ 和平方梯度估计（二阶矩）$v$ 也均初始化为 0。
2. 梯度计算：对于每个样本，给定真实带宽值 $y_{true}$，各参数的梯度定义为：
- $g_{w_1} = 2(y_{pred} - y_{true})x_1$
- $g_{w_2} = 2(y_{pred} - y_{true})x_2$
- $g_b = 2(y_{pred} - y_{true})$
3. 参数迭代：设当前正在处理第 $t$ 个样本（$t$ 从 1 开始），对于每一个参数 $\theta \in \{w_1, w_2, b\}$，执行以下更新：
- $m_t = \beta_1 m_{t-1} + (1 - \beta_1) g_t$
- $v_t = \beta_2 v_{t-1} + (1 - \beta_2) g_t^2$
- $\hat{m}_t = m_t / (1 - \beta_1^t)$
- $\hat{v}_t = v_t / (1 - \beta_2^t)$
- $\theta_t = \theta_{t-1} - \alpha (\frac{\hat{m}_t}{\sqrt{\hat{v}_t} + \epsilon} + \lambda \theta_{t-1})$
4. 超参数设置：
小红使用了以下固定的实验参数：
$\beta_1 = 0.9, \beta_2 = 0.999, \lambda = 0.01, \alpha = 0.001, \epsilon = 10^{-8}$

请根据给定的 $N$ 个样本，计算最终的模型参数。

提示：
- 银行家舍入法（Round half to even）：舍入到最接近的数值；若与两个数值的距离相等（即需要舍弃的部分恰好为 0.5），则舍入到最近的偶数。

## 输入格式

第一行包含一个整数 $N$（1 ≤ $N$ ≤ 10^5），代表样本总数。
接下来的 $N$ 行，每行包含三个浮点数 $x_1, x_2, y_{true}$（-1000.0 ≤ $x_1, x_2, y_{true}$ ≤ 1000.0），含义见题目描述。

## 输出格式

输出一行三个浮点数，分别表示经过 $N$ 次更新后的 $w_1, w_2, b$。
结果必须精确到 6 位小数，且使用银行家舍入法（四舍六入五成双）。数值之间用一个空格分隔，末尾不要有多余空格。

## 样例

### 样例 1

**输入：**
```
2
2.0 0.0 4.0
0.0 2.0 -2.0
```

**输出：**
```
0.001670 -0.000744 0.001266
```

**说明：**
在样例中，处理第一个样本后，$w_1$ 约更新为 0.001，$w_2$ 保持为 0，$b$ 约更新为 0.001。接着在此基础上处理第二个样本。

### 样例 2

**输入：**
```
3
1.0 1.0 2.0
2.0 2.0 4.0
3.0 3.0 6.0
```

**输出：**
```
0.002750 0.002750 0.002923
```

**说明：**
For sample 1 ($t=1$): $x_1=1.0, x_2=1.0, y_{true}=2.0$. The parameters are updated from 0 to $w_1=0.001, w_2=0.001, b=0.001$.

For sample 2 ($t=2$): $x_1=2.0, x_2=2.0, y_{true}=4.0$. The parameters are updated to $w_1 \approx 0.001884, w_2 \approx 0.001884, b \approx 0.001965$.

For sample 3 ($t=3$): $x_1=3.0, x_2=3.0, y_{true}=6.0$. The parameters are updated to the final values.', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97678628/detail?pid=66965010&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678628/detail?pid=66965010&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:16:52.001447+00:00', '2026-07-02T12:17:25.306880+00:00', 2000, 262144, 'Ai'),
	(64, '虫洞网络', '虫洞网络', '华为', 'Medium', 'graphs', '在遥远的未来，人类文明已经步入深空时代。广袤的宇宙中散布着数不尽的星系，而连接这些星系的，是由一个古老文明遗留下来的神秘“虫洞网络”（Wormhole Networks）。每个独立的虫洞网络都连接着一系列的星系。要进入任何一个虫洞网络，飞船都需要消耗特定的能量来激活跃迁引擎。一旦进入某个网络，飞船便可以在该网络所覆盖的所有星系之间进行无消耗的瞬时跳跃。

作为一名星际领航员，您的任务是规划一条从起点星系到目标星系的最优航线。

整个已知宇宙可以被看作一个图，其中的节点是星系，编号从 $0$ 到 $500$。总共有 $M$ 个独立的虫洞网络。

虫洞网络 $i$：这是一个由 $n_i$ 个星系组成的集合，记作 $W_i = \{s_{i,1}, s_{i,2}, \dots, s_{i,n_i}\}$。

跃迁成本 $C_i$：要使用虫洞网络 $i$ 进行旅行，必须首先支付 $C_i$ 的能量。支付后，您可以在 $W_i$ 集合内的任意两个星系之间自由、无限次地移动，无需额外花费。

您的飞船初始位于星系 $S_{start}$，目标是抵达星系 $S_{dest}$，并且飞船的总备用能量为 $E_{total}$。您需要计算出从 $S_{start}$ 到 $S_{dest}$ 所需的最小总能量消耗。一次旅行可能需要穿越多个虫洞网络，当您从一个网络 $W_i$ 前往另一个网络 $W_j$ 时，您必须先通过一个共同的“中转星系” $s_{transfer}$（即 $s_{transfer} \in W_i \cap W_j$），然后支付网络 $W_j$ 的跃迁成本 $C_j$。

如果无法抵达目标星系，或者最低能量消耗超出了您的总备用能量 $E_{total}$，则视为任务失败。

## 输入格式

第一行包含四个整数：$M, S_{start}, S_{dest}, E_{total}$。

$M$：虫洞网络的总数量。($1 \le M \le 50$)
$S_{start}$：起始星系的编号。($0 \le S_{start} \le 500$)
$S_{dest}$：目标星系的编号。($0 \le S_{dest} \le 500$, $S_{start} \neq S_{dest}$)
$E_{total}$：飞船的总备用能量。($1 \le E_{total} \le 500$)

接下来的 $M$ 行，每行描述一个虫洞网络，格式如下：
$C_i \ \ n_i \ \ s_{i,1} \ \ s_{i,2} \ \ \dots \ \ s_{i,n_i}$

$C_i$：进入该网络的跃迁成本。($1 \le C_i \le 10$)
$n_i$：该网络连接的星系数量。($1 \le n_i \le 10$)
$s_{i,j}$：该网络中的星系编号。($0 \le s_{i,j} \le 500$)

## 输出格式

输出一个整数，代表从 $S_{start}$ 到 $S_{dest}$ 的最小能量消耗。

如果无法抵达或能量不足，则输出 $-1$。

## 样例

### 样例 1

**输入：**
```
1 45 103 383
1 9 45 103 182 198 244 306 416 460 490
```

**输出：**
```
1
```

### 样例 2

**输入：**
```
4 14 19 99
8 5 11 13 22 24 44
1 1 18
3 1 22
6 7 2 12 14 17 30 36 39
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678649/detail?pid=64321083&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678649/detail?pid=64321083&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:20:00.785345+00:00', '2026-07-02T12:20:16.688301+00:00', 2000, 262144, '开发'),
	(79, '聚类识别', '聚类识别', '华为', 'Medium', 'simulation', '给出 m 个终端的四维数值特征，需将它们用 KMeans 聚成 k 类，并输出各簇的样本数，从小到大排序后以空格分隔打印。实现规则如下：

初始质心：直接取数据中的前 k 个样本。

距离：使用四维欧氏距离的平方（少一次开方，比较大小结果不变）。

更新：每轮按最近质心分配样本，再用簇内四维特征的平均值更新该簇质心。

收敛判定：若所有质心的新旧位置变化量（平方距离）最大值小于 1e-8，或已达到最多迭代次数 n，则停止。

空簇处理：若某簇本轮没有样本，保持该簇质心不变，避免除零错误。

## 输入格式

第一行：k m n
接下来 m 行：每行 4 个浮点数，表示一个终端的四维特征

## 输出格式

一行：k 个整数（各簇样本数），升序排列，用空格分隔

## 样例

### 样例 1

**输入：**
```
2 4 100
0.00 0.00 0.00 0.00
10.00 10.00 10.00 10.00
0.20 0.00 0.00 0.00
9.80 10.00 10.00 10.00
```

**输出：**
```
2 2
```

**说明：**
前两行即初始两个质心，后两点分别更接近对应质心；每簇各 2 个样本，升序输出为 2 2。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683618/detail?pid=65254756&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683618/detail?pid=65254756&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:59:04.761854+00:00', '2026-07-02T15:02:38.034907+00:00', 2000, 262144, 'Ai'),
	(72, '二分类逻辑回归', '二分类逻辑回归', '华为', 'Medium', 'binary-search', '你需要基于用户的三个数值特征（年龄、月收入、浏览时长）训练一个二分类模型，判断其是否会购买某商品。每条训练数据包含三个特征与一个标签（0/1）。模型使用逻辑回归：以 Sigmoid 作为激活函数，损失为平均交叉熵，并加入 L2 正则。优化方式为批量梯度下降；达到最大迭代次数或相邻两次损失变化小于阈值即停止。随后对给定的测试样本输出预测标签与对应概率（四舍五入保留四位小数）。预测时，概率≥0.5 视为正类，否则为负类。

## 输入格式

- 第1行：n max_iter alpha lam tol
- n：训练样本条数
- max_iter：最大迭代次数
- alpha：学习率（浮点数）
- lam：L2 正则系数（浮点数）
- tol：损失收敛阈值（浮点数）

- 接下来 n 行：每行 a inc dur label
- a 为年龄（数值），inc 为月收入（数值），dur 为浏览时长（数值），label 为 0 或 1

- 第 n+2 行：m（测试样本数）
- 接下来 m 行：每行 a inc dur（仅特征，无标签）

## 输出格式

- 共 m 行。每行输出：pred prob
- pred 为预测标签（0 或 1）
- prob 为对应正类概率，保留四位小数

## 样例

### 样例 1

**输入：**
```
3 0 0.10 0.00 0.0001
20 3 2 0
30 10 8 1
40 15 12 1
2
25 5 4
35 12 9
```

**输出：**
```
1 0.5000
1 0.5000
```

**说明：**
max_iter=0，训练不进行，参数保持 w=b=0。
预测概率均为 0.5，阈值规则下均判为 1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686016/detail?pid=64953001&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686016/detail?pid=64953001&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:57:48.358988+00:00', '2026-07-02T15:04:15.944589+00:00', 2000, 262144, 'Ai'),
	(65, 'K-Means聚类下的Anchor优化输出', 'K-Means聚类下的Anchor优化输出', '华为', 'Medium', 'simulation', '在目标检测任务中，常需为候选框选择一组代表性的 Anchor 尺寸。现给定 N 个矩形框的宽和高，使用基于 IOU 距离的 k-means 聚类得到 K 个 Anchor。初始化时直接取前 K 个框作为初始中心；每轮迭代将每个样本分配给距离最近的中心；随后将每个簇内样本的宽、高分别取均值并向下取整作为新中心。若达到最大迭代次数 T，或新旧中心之间的总“位移”小于 1e-4（用 d=1−IOU 作为中心间距离，并对 K 个中心求和），则停止。最终按 Anchor 面积（宽×高）从大到小输出 K 个中心。

说明与约束

1.距离度量：d = 1 − IOU，其中 IOU = 交集面积 / 并集面积，交集面积 = min(w1,w2) × min(h1,h2)，并集面积 = w1×h1 + w2×h2 − 交集面积。

2.所有距离与 IOU 的计算均用浮点；每轮更新后的中心宽、高先取均值再向下取整为整数。

3.若某簇在某轮为空，则该簇中心保持不变。

4.输出前按面积从大到小排序；若面积相同，可按宽、再按高降序作为次序规则。

## 输入格式

第一行：N K T（以空格分隔） 
接下来 N 行：每行两个整数 w h，表示一个检测框的宽与高。

## 输出格式

输出 K 行：每行两个整数，依次为一个 Anchor 的宽与高，按面积从大到小排序。

## 样例

### 样例 1

**输入：**
```
9 3 10
100 50
30 20
10 10
102 49
98 52
29 21
31 19
11 9
9 11
```

**输出：**
```
100 50
30 20
10 10
```

**说明：**
初始中心为 (100,50)、(30,20)、(10,10)。 
分配后每个簇的均值向下取整仍为 (100,50)、(30,20)、(10,10)，迭代收敛。 
按面积排序的结果如上。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683597/detail?pid=64534470&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683597/detail?pid=64534470&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:56:47.594425+00:00', '2026-07-02T15:05:47.025176+00:00', 2000, 262144, 'Ai'),
	(58, '小红的大模型推理 Token 调度', '小红的大模型推理 Token 调度', '华为', 'Medium', 'stack-queue', '小红目前正在负责一家大型 AI 实验室的推理资源调度工作。为了提高大语言模型（LLM）的并行推理效率，她需要为当前任务队列中的一系列请求分配 Token 资源（单位：k）。

队列中的每个推理请求都有一个对应的优先级评分。在分配资源时，小红设定了如下调度规则：

1. 优先级评分小于或等于 0 的请求会被视为无效任务或系统预留任务，不参与本次 Token 分配，即分配到的 Token 数量为 0。

2. 这些无效任务会将整个请求序列切分成若干个由连续有效任务（优先级评分大于 0）构成的子段。

3. 对于每个有效任务子段，段内的每个请求至少要分配 1k 个 Token。

4. 在同一个子段内部，如果某个请求的优先级评分严格高于它左边或右边相邻的任务，那么它分配到的 Token 数量必须严格多于该相邻任务。

小红希望在完全满足上述规则的前提下，计算出分配给所有任务的 Token 总数最小值是多少。

## 输入格式

输入包含一行，为若干个由英文逗号隔开的整数，代表任务队列中每个推理请求的优先级评分。

任务总数 $N$ 满足 $1 \leq N \leq 2 \times 10^5$。

每个优先级评分 $P_i$ 满足 $-10^9 \leq P_i \leq 10^9$。

## 输出格式

输出一个整数，表示小红最少需要分配的 Token 总数（以 k 为单位）。

## 样例

### 样例 1

**输入：**
```
3,5,2,0,8
```

**输出：**
```
5
```

**说明：**
在该样例中，优先级为 0 的任务将序列分割为两个有效子段：[3, 5, 2] 和 [8]。

- 对于子段 [3, 5, 2]，为了满足相邻优先级更高则分配更多的原则，最少分配方案为 [1, 2, 1]，该段总和为 4。

- 对于子段 [8]，只有一个任务，最少分配 1k Token，该段总和为 1。

- 优先级为 0 的任务不分配 Token。

总计最小分配数量为 4 + 1 = 5。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97678628/detail?pid=66965010&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678628/detail?pid=66965010&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:16:52.053929+00:00', '2026-07-02T12:17:12.055317+00:00', 2000, 262144, 'Ai'),
	(85, '统计监控数据', '统计监控数据', '华为', 'Medium', 'simulation', '你拿到了一台存储集群导出的“监控快照”原始行。该行把若干个样本首尾相接在一起，每个样本严格包含19个浮点特征（按固定顺序）。请把整行解析为若干样本，然后对每一列特征分别计算以下统计量，并按指定顺序输出：

- 
对每列特征依次输出：mean max min ptp std var skew kurt

- 
说明

- 
mean: 该列的算术平均

- 
max/min: 该列最大/最小

- 
ptp: 极差=max−min

- 
std/var: 使用总体标准差/总体方差（分母用样本数 n）

- 
skew: 总体偏度=平均[((x−mean)/std)^3]。若该列 std=0，则定义 skew=0

- 
kurt: 总体超峰度=平均[((x−mean)/std)^4]−3。若该列 std=0，则定义 kurt=0

## 输入格式

- 输入保证总浮点数个数是19的整数倍

## 输出格式

- 先输出特征0的8个统计量，再输出特征1的8个统计量，……直到特征18
- 结果用空格分隔；所有数保留两位小数

## 样例

### 样例 1

**输入：**
```
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
```

**输出：**
```
1.00 2.00 0.00 2.00 0.82 0.67 0.00 -1.50 2.00 3.00 1.00 2.00 0.82 0.67 0.00 -1.50 3.00 4.00 2.00 2.00 0.82 0.67 0.00 -1.50 4.00 5.00 3.00 2.00 0.82 0.67 0.00 -1.50 5.00 6.00 4.00 2.00 0.82 0.67 0.00 -1.50 6.00 7.00 5.00 2.00 0.82 0.67 0.00 -1.50 7.00 8.00 6.00 2.00 0.82 0.67 0.00 -1.50 8.00 9.00 7.00 2.00 0.82 0.67 0.00 -1.50 9.00 10.00 8.00 2.00 0.82 0.67 0.00 -1.50 10.00 11.00 9.00 2.00 0.82 0.67 0.00 -1.50 11.00 12.00 10.00 2.00 0.82 0.67 0.00 -1.50 12.00 13.00 11.00 2.00 0.82 0.67 0.00 -1.50 13.00 14.00 12.00 2.00 0.82 0.67 0.00 -1.50 14.00 15.00 13.00 2.00 0.82 0.67 0.00 -1.50 15.00 16.00 14.00 2.00 0.82 0.67 0.00 -1.50 16.00 17.00 15.00 2.00 0.82 0.67 0.00 -1.50 17.00 18.00 16.00 2.00 0.82 0.67 0.00 -1.50 18.00 19.00 17.00 2.00 0.82 0.67 0.00 -1.50 19.00 20.00 18.00 2.00 0.82 0.67 0.00 -1.50
```

**说明：**
共有3个样本，每列是长度为3的等差序列，因此每列 mean 为中间值，ptp=2，std=√(2/3)≈0.82，var=2/3≈0.67，skew=0，kurt=−1.50。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686231/detail?pid=64590230&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686231/detail?pid=64590230&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:00:05.549272+00:00', '2026-07-02T15:01:10.830866+00:00', 2000, 262144, 'Ai'),
	(80, 'Prompt上下文信息精简', 'Prompt上下文信息精简', '华为', 'Medium', 'tree', '在一次 Prompt 工程实践中，我们把一段 token 序列抽象成一棵二叉树。树中每个结点都有一个整数权值（可正可负，也可能为 0）。请在这棵树中选出一棵“价值最大”的子树，并把这棵子树按“完全二叉树的层序数组”形式输出。

子树的价值定义为它所包含的所有结点权值之和。

允许对某个结点“剪掉”对总和贡献为负的整棵子树（即可以只要左子树、或只要右子树、或两者都要；被剪掉的位置在输出中以 null 占位）。

输入是一棵“用层序数组表示的完全二叉树”，缺失位置用 null 占位；输出也使用相同规则表示挑选出的那棵最优子树，并且去除末尾多余的尾部 null。

## 输入格式

一行：用方括号包裹的一维数组，表示树的层序遍历；缺失结点用 `null`。例如：`[5,-1,3,null,null,4,7]`。

约定：
1.数组下标从 0 开始；对下标 i，左孩子为 2i+1，右孩子为 2i+2。
2.仅当该位置不是 `null` 才视为存在结点。

## 输出格式

一行：选择的“最大和子树”的层序数组表示（仍以 `null` 占位），并删除末尾无意义的连续 `null`。

## 样例

### 样例 1

**输入：**
```
[1,-2,3,-4,-5,6,7]
```

**输出：**
```
[1,null,3,null,null,6,7]
```

**说明：**
以 3 为根的子树和为 3+6+7=16；整棵树在剪掉负贡献的左侧后，总和为 1+16=17，为全局最大。按完全二叉树层序输出时，左子树位置及其两个孩子以 null 占位。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683618/detail?pid=65254756&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683618/detail?pid=65254756&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:59:04.846258+00:00', '2026-07-02T15:02:24.515992+00:00', 2000, 262144, 'Ai'),
	(73, '多目标推荐排序模型优化', '多目标推荐排序模型优化', '华为', 'Medium', 'matrix-grid', '在推荐排序的双目标场景中，需要同时预测点击率(CTR)与转化率(CVR)。用一个共享的线性权重向量 w 提取通用特征，同时为两个任务各配置一个偏置 b_ctr、b_cvr。给定特征矩阵 X 与标签矩阵 Y（每行形如[ctr, cvr]），从全零参数出发，按批量梯度下降迭代 N 次，学习率为 lr。训练完成后，用最终参数重新计算一次联合损失：

- 
预测：y_hat_ctr = X·w + b_ctr，y_hat_cvr = X·w + b_cvr

- 
MSE_ctr 与 MSE_cvr 为对应任务的均方误差

- 
联合损失：Loss = MSE_ctr + alpha × MSE_cvr

- 
输出：将 Loss×10^10 按“四舍五入（Half Up）”取整为整数

## 输入格式

输入格式

- 第1行：特征矩阵，形如“a,b;c,d;...”表示按行给出
- 第2行：标签矩阵，每行两个数“ctr,cvr”，整体同样用分号分行
- 第3行：迭代次数 N（可为 0）
- 第4行：学习率 lr（浮点数）
- 第5行：权重系数 alpha（浮点数）

## 输出格式

- 一行，打印整数 round_half_up(Loss×10^10)

## 样例

### 样例 1

**输入：**
```
1,2;3,4
0.1,0.2;0.3,0.4
0
0.01
0.5
```

**输出：**
```
1000000000
```

**说明：**
N=0 时不训练，预测恒为 0
MSE_ctr=((0-0.1)^2+(0-0.3)^2)/2=0.05
MSE_cvr=((0-0.2)^2+(0-0.4)^2)/2=0.10
Loss=0.05+0.5×0.10=0.10，Loss×1e10=1,000,000,000，四舍五入为 1000000000', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683739/detail?pid=65084889&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683739/detail?pid=65084889&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:58:11.159666+00:00', '2026-07-02T15:03:59.243933+00:00', 2000, 262144, 'Ai'),
	(214, '数组中的逆序对', '数组中的逆序对', '牛客', 'Medium', 'binary-search', '在数组中的两个数字，如果前面一个数字大于后面的数字，则这两个数字组成一个逆序对。输入一个数组,求出这个数组中的逆序对的总数P。并将P对1000000007取模的结果输出。 即输出P mod 1000000007

数据范围： 对于 $50\%$ 的数据, $size\leq 10^4$

对于 $100\%$ 的数据, $size\leq 10^5$

数组中所有数字的值满足 $0 \le val \le 10^9$

要求：空间复杂度 $O(n)$，时间复杂度 $O(nlogn)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,2,3,4,5,6,7,0]
```

**输出：**
```
7
```

### 样例 2

**输入：**
```
[1,2,3]
```

**输出：**
```
0
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/96bd6684e04a44eb80e6a68efc0ec6c5?tpId=295&tqId=23260&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/96bd6684e04a44eb80e6a68efc0ec6c5?tpId=295&tqId=23260&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:24:52.152057+00:00', '2026-07-03T12:26:36.768064+00:00', 2000, 262144, '常见101'),
	(87, '多分类加权指标计算', '多分类加权指标计算', '华为', 'Medium', 'simulation', '给定一批样本的预测标签、真实标签，以及各类别在总体评估中的权重（权重非负且和为 1），请计算加权精确率、加权召回率与加权 F1 分数。

- 
对每个类别 c，统计 TP、FP、FN：

- 
TP：预测为 c 且真实为 c 的样本数

- 
FP：预测为 c 但真实不为 c 的样本数

- 
FN：真实为 c 但预测不为 c 的样本数

- 
每类指标：

- 
precision_c = TP / (TP + FP)，若分母为 0 则记为 0

- 
recall_c = TP / (TP + FN)，若分母为 0 则记为 0

- 
f1_c = 0（当 precision_c + recall_c = 0），否则 f1_c = 2 * precision_c * recall_c / (precision_c + recall_c)

- 
加权汇总：

- 
precision = Σ weights[c] * precision_c

- 
recall = Σ weights[c] * recall_c

- 
f1Score = Σ weights[c] * f1_c

- 
输出按四舍五入保留 2 位小数，位数不足补零。

- 
类别编号为从 0 开始的连续整数，类别数等于第三行权重的个数。三行样本数长度一致。

## 输入格式

- 第 1 行：预测结果 pred，空格分隔
- 第 2 行：真实标签 trueY，空格分隔
- 第 3 行：各类别权重 weights，按类别 0,1,2,... 的顺序给出，空格分隔，且加和为 1

## 输出格式

- 一行三个数：precision recall f1Score（空格分隔，均保留 2 位小数）

## 样例

### 样例 1

**输入：**
```
0 1 2 2 1 0 2 0
0 2 2 1 1 0 0 0
0.2 0.3 0.5
```

**输出：**
```
0.52 0.55 0.52
```

**说明：**
类别 0：TP=3, FP=0, FN=1 → precision=1.00, recall=0.75, f1=0.86(约) 
类别 1：TP=1, FP=1, FN=1 → precision=0.50, recall=0.50, f1=0.50 
类别 2：TP=1, FP=2, FN=1 → precision≈0.33, recall=0.50, f1=0.40 
加权：precision=0.52，recall=0.55，f1≈0.52（均四舍五入到 2 位小数）', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686527/detail?pid=65783046&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686527/detail?pid=65783046&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:06:39.155737+00:00', '2026-07-02T15:10:29.063497+00:00', 2000, 262144, 'Ai'),
	(233, '序列化二叉树', '序列化二叉树', '牛客', 'Medium', 'tree', '请实现两个函数，分别用来序列化和反序列化二叉树，不对序列化之后的字符串进行约束，但要求能够根据序列化之后的字符串重新构造出一棵与原二叉树相同的树。

二叉树的序列化(Serialize)是指：把一棵二叉树按照某种遍历方式的结果以某种格式保存为字符串，从而使得内存中建立起来的二叉树可以持久保存。序列化可以基于先序、中序、后序、层序的二叉树等遍历方式来进行修改，序列化的结果是一个字符串，序列化时通过 某种符号表示空节点（#）

二叉树的反序列化(Deserialize)是指：根据某种遍历顺序得到的序列化字符串结果str，重构二叉树。

例如，可以根据层序遍历的方案序列化，如下图:

![题面配图](https://uploadfiles.nowcoder.com/images/20210910/557336_1631245540483/320409CB186FCD18144519959D510D7E)

层序序列化(即用函数Serialize转化)如上的二叉树转为"{1,2,3,#,#,6,7}"，再能够调用反序列化(Deserialize)将"{1,2,3,#,#,6,7}"构造成如上的二叉树。

再举一个例子

![题面配图](https://uploadfiles.nowcoder.com/images/20241118/0_1731923302526/FE7ACD8B8711095B0A5D78E9AA35B68F)

层序序列化(即用函数Serialize转化)如上的二叉树转为"{5,4,#,3,#,2}"，再能够调用反序列化(Deserialize)将"{5,4,#,3,#,2}构造成如上的二叉树。

当然你也可以根据满二叉树结点位置的标号规律来序列化，还可以根据先序遍历和中序遍历的结果来序列化。不对序列化之后的字符串进行约束，所以欢迎各种奇思妙想。

数据范围：节点数 $n \le 100$，树上每个节点的值满足 $0 \le val \le 150$

要求：序列化和反序列化都是空间复杂度 $O(n)$，时间复杂度 $O(n)$

## 样例

### 样例 1

**输入：**
```
{1,2,3,#,#,6,7}
```

**输出：**
```
{1,2,3,#,#,6,7}
```

**说明：**
如题面图

### 样例 2

**输入：**
```
{8,6,10,5,7,9,11}
```

**输出：**
```
{8,6,10,5,7,9,11}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/cf7e25aa97c04cc1a68c8f040e71fb84?tpId=295&tqId=23455&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/cf7e25aa97c04cc1a68c8f040e71fb84?tpId=295&tqId=23455&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:34.089669+00:00', '2026-07-03T16:39:39.002099+00:00', 2000, 262144, '常见101'),
	(48, 'ID3决策树训练', 'ID3决策树训练', '华为', 'Medium', 'binary-search', '在运维中心收集到的一批样本中，每条样本包含 m 个二值特征与一个二分类标签（0=正常，1=劣化）。请基于 ID3 决策树训练一个二叉分类器，并对 q 条查询样本给出预测结果。

规则与细节

- 
划分准则：信息增益（Entropy + Information Gain）。在当前节点，从“尚未使用”的特征中选择信息增益最大的进行二分。

- 
并列处理：若多个特征增益相同，选择“特征下标更小”的那个。

- 
终止与叶子：

- 
若当前样本标签全同，直接返回该标签；

- 
若没有任何特征能带来正的增益（或特征已经用尽），返回“多数标签”；若平票，返回 0。

- 
为保证可预测性，某次划分若一侧样本为空，该子结点直接作为“多数标签叶子”（平票仍为 0）。

- 
预测：从根出发，按节点记录的特征下标读取 0/1 向左/向右，直到叶子。

## 输入格式

第一行：n m
接下来 n 行：每行 m+1 个整数，前 m 个为特征值（0/1），最后 1 个为标签（0/1）
下一行：q
接下来 q 行：每行 m 个整数，表示待预测样本的特征（0/1）

## 输出格式

共 q 行，每行 1 个整数（0 或 1），为对应查询样本的预测值

## 样例

### 样例 1

**输入：**
```
6 2
0 0 0
0 1 0
1 0 1
1 1 1
0 0 0
1 1 1
3
0 1
1 0
1 1
```

**输出：**
```
0
1
1
```

**说明：**
在根节点，按信息增益选择特征1（与特征2并列时，因下标更小而被选中）；左支（特征1=0）标签几乎全为 0，右支（特征1=1）标签几乎全为 1；因此三个查询分别预测为 0、1、1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678234/detail?pid=64321250&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678234/detail?pid=64321250&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:10:45.951726+00:00', '2026-07-02T12:11:08.237976+00:00', 2000, 262144, 'Ai'),
	(59, '火星探测器稳定性分析', '火星探测器稳定性分析', '华为', 'Medium', 'intervals', '“祝融号”火星探测器在火星表面执行一项精密科学探测任务。其搭载的科学仪器对工作环境的稳定性有非常严苛的要求。为了保证仪器的正常运行和数据的准确性，必须满足以下两个条件：

1. 仪器的“环境稳定性指数” $S$ 必须维持在 $[18, 24]$ 的区间内，即 $18 \le S \le 24$。

2. 在任何一次连续的工作期间内，环境稳定性指数的最大波动范围（即该期间的 $S_{max} - S_{min}$）不得超过 $4$，即 $S_{max} - S_{min} \le 4$。

现在，探测器沿一条预定路线行进，并按固定时间间隔连续采集了 $N$ 次环境稳定性指数。这些数据按采集顺序（索引从 $0$ 开始）记录下来。

为了最大化单次有效工作时长，请你找出满足上述两个稳定条件的、持续时间最长的一个或多个时间段。请输出这些时间段的起始和结束索引。如果存在多个长度相同的最长时间段，请按照起始索引从小到大的顺序，逐行输出。

## 输入格式

第一行为连续采集的次数 $N$，其中 $N$ 的取值范围为 $[1, 10^5]$。
第二行为 $N$ 个按顺序采集的环境稳定性指数，均为整数，数值范围为 $[0, 30]$。数值之间以空格分隔。

## 输出格式

输出持续时间最长且满足稳定条件的时间段的起始索引和结束索引，两者以空格分隔。如果存在多个这样的时间段，按起始索引升序逐行输出。

## 样例

### 样例 1

**输入：**
```
20
27 2 19 16 24 9 29 21 28 10 5 27 6 4 27 11 14 1 4 27
```

**输出：**
```
2 2
4 4
7 7
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678396/detail?pid=63554020&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678396/detail?pid=63554020&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:18:05.121673+00:00', '2026-07-02T12:18:56.522275+00:00', 2000, 262144, '开发'),
	(66, '实现Masked Multi-Head Self-Attention', '实现Masked Multi-Head Self-Attention', '华为', 'Medium', 'matrix-grid', '给定批量序列表示 X（形状：[batch, seq, d_model]）与权重矩阵 W_Q、W_K、W_V、W_O（均为 d_model×d_model），实现 Masked Multi-Head Self-Attention。 

将最后一维按头数 num_heads 均分，每头维度 d_k = d_model / num_heads。 

计算步骤： 

1) Q = X @ W_Q，K = X @ W_K，V = X @ W_V。 

2) 将 Q、K、V reshape 为 [batch, num_heads, seq, d_k]。 

3) 计算注意力分数 scores = (Q @ K^T) / sqrt(d_k)，其中 K^T 表示每头在最后两维做转置得到 [batch, num_heads, seq, seq]。 

4) 使用下三角因果掩码（只能看见当前及更早位置）：掩掉上三角元素（置为一个很小的负数）。 

5) 在最后一维做 softmax 得到权重，注意数值稳定性（减去每行最大值再做 exp）。 

6) attention = softmax @ V（形状 [batch, num_heads, seq, d_k]）。 

7) 拼回 [batch, seq, d_model] 后，再右乘 W_O。 

输出保留两位小数，结果需转换为 Python List。

## 输入格式

以分号分隔的 6 个参数：num_heads; X; W_Q; W_K; W_V; W_O 
其中 X、W_Q、W_K、W_V、W_O 用 Python 风格的嵌套列表表示。

## 输出格式

最终输出张量（形状 [batch, seq, d_model]），四舍五入到小数点后两位，类型为 List。

## 样例

### 样例 1

**输入：**
```
2; [[[1, 1], [1, 1], [1, 1]]]; [[1, 0], [0, 1]]; [[1, 0], [0, 1]]; [[1, 0], [0, 1]]; [[1, 0], [0, 1]]
```

**输出：**
```
[[[1.00, 1.00], [1.00, 1.00], [1.00, 1.00]]]
```

**说明：**
权重为单位矩阵，Q=K=V=X。因果掩码使第 i 个位置只看见前 i+1 个位置；由于各位置完全相同，softmax 权重在可见范围内均匀分布，输出与输入一致；乘 W_O（单位）后不变。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683597/detail?pid=64534470&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683597/detail?pid=64534470&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:56:47.675907+00:00', '2026-07-02T15:05:33.792877+00:00', 2000, 262144, 'Ai'),
	(94, '多项式岭回归', '多项式岭回归', '华为', 'Medium', 'intervals', '某智慧城市运营平台持续监测全市供水管网在连续 N=200 天内各区域的日总供水量(单位万吨，数值通常分布在 100.00 至 500.00 之间)，数据已按日期先后排列。

因传感器故障，共有 M 处(M 的范围是 20 到 30)记录丢失，依次编号为 Gap_1, Gap_2, ..., Gap_M。 

已知首日和末日的监测数据一定完整(即第 1 天和第 N 天不会出现丢失)。 你的目标是：对每一处丢失记录，利用其前后最近的连续真实数据段，构建二阶多项式岭回归模型来估算缺失值。 

区间确定规则
假设某个丢失记录位于全局第 pos 天：
前方区间 [left_start, pos-1]：从 pos-1 向前(朝第 1 天方向)逐天检查，碰到的第一个丢失记录(Gap_1 到 Gap_M 中任何一个)所在天数的下一天即为 left_start。若一路到第 1 天都没有碰到其他丢失记录，则 left_start 为第 1 天。 

后方区间 [pos+1, right_end]：从 pos+1 向后(朝第 N 天方向)逐天检查，碰到的第一个丢失记录所在天数的前一天即为 right_end。若一路到第 N 天都没有碰到其他丢失记录，则 right_end 为第 N 天。

模型构建
将上述前方区间与后方区间中所有真实记录汇总作为训练样本 (x, y)，其中 x 为天序号(1, 2, ..., N)，y 为对应供水量。 

使用二阶多项式岭回归拟合模型： $\hat{y} = \beta_2 x^2 + \beta_1 x + \beta_0$ 

回归系数通过以下矩阵公式求解： $\beta = (X^T X + \lambda I)^{-1} X^T y$ 

各符号含义如下：
beta 是 3*1 列向量，包含待求系数 [beta_2, beta_1, beta_0]。
X 是 n*3 的设计矩阵(n 为训练样本数)。

对训练集中每个天序号 x_i，矩阵 X 的对应行为 [x_i^2, x_i, 1]。
y 是 n*1 列向量，存储训练集中各样本点的供水量。
X^T 为 X 的转置。 

lambda 为正则化系数，本题统一取 lambda=0.1。
I 为 3*3 单位矩阵。
(.)^{-1} 表示矩阵求逆运算。

## 输入格式

第 1 行：两个整数 M 和 N，以空格分隔。M 表示丢失记录总数(范围 20 到 30)，N 表示后续数据行数(固定为 200)。

第 2 行到第 N+1 行：每行一个值，可能是：
一个浮点数，代表当天实际供水量。
一个字符串 Gap_i(i 从 1 到 M），表示该天数据丢失。

## 输出格式

共 M 行，严格按 Gap_1, Gap_2, ..., Gap_M 的顺序输出。
每行格式为 Gap_i: xxx.xx，即标签、冒号、空格、预测值(保留两位小数)。

## 样例

### 样例 1

**输入：**
```
22 200
205.58
Gap_1
195.99
196.40
219.39
219.44
230.46
200.62
216.35
202.94
212.72
226.35
209.29
218.21
238.21
235.88
Gap_2
241.13
251.54
220.93
254.31
251.30
238.17
231.86
Gap_3
240.91
231.89
232.65
263.17
253.78
262.16
259.18
251.43
268.77
244.72
251.28
261.87
252.80
261.78
249.54
253.65
226.20
232.28
Gap_4
223.62
228.22
221.33
226.69
239.20
226.48
224.73
216.26
216.45
241.07
227.29
Gap_5
203.59
223.54
198.50
204.70
226.64
Gap_6
204.36
206.96
210.80
205.63
181.27
170.94
Gap_7
175.53
170.90
197.86
192.93
168.25
Gap_8
167.25
185.99
165.82
156.21
153.71
164.61
151.08
162.47
173.61
152.40
144.02
174.09
153.63
136.06
133.60
135.51
155.76
162.00
146.98
132.54
145.30
170.04
151.64
Gap_9
165.84
Gap_10
161.65
160.98
Gap_11
146.50
Gap_12
142.85
157.21
159.51
Gap_13
179.76
157.07
168.46
157.56
188.97
189.41
168.71
Gap_14
185.66
169.76
196.53
190.02
202.04
194.57
Gap_15
Gap_16
181.62
220.50
220.98
221.57
203.06
195.50
230.70
235.81
203.67
221.94
207.47
237.27
239.56
216.06
231.86
236.68
227.05
Gap_17
236.61
229.63
244.09
252.98
232.98
238.44
266.71
253.70
245.92
249.67
234.25
238.72
243.45
253.53
239.15
238.58
232.31
254.29
237.65
264.04
261.42
228.96
234.63
250.73
231.30
226.67
Gap_18
241.21
235.63
246.36
245.45
218.85
213.12
224.42
221.99
Gap_19
229.77
225.24
235.32
197.50
207.25
202.27
220.69
193.68
188.85
196.68
193.12
184.90
181.28
Gap_20
184.14
Gap_21
183.69
Gap_22
197.09
188.37
```

**输出：**
```
Gap_1: 194.99
Gap_2: 235.41
Gap_3: 249.49
Gap_4: 246.24
Gap_5: 220.04
Gap_6: 206.00
Gap_7: 189.12
Gap_8: 171.16
Gap_9: 146.06
Gap_10: 163.92
Gap_11: 153.00
Gap_12: 146.94
Gap_13: 160.31
Gap_14: 181.80
Gap_15: 203.39
Gap_16: 203.64
Gap_17: 230.94
Gap_18: 235.83
Gap_19: 222.33
Gap_20: 179.61
Gap_21: 183.92
Gap_22: 188.19
```

**说明：**
以 Gap_1 为例：Gap_1 位于第 2 天。前方区间为 [1, 1]，即只有第 1 天的数据。后方区间为 [3, 16] 之前，由于第 17 天是 Gap_2，所以后方区间为 [3, 16]，共 14 天数据。将这些点作为训练集，构建二阶多项式岭回归模型，代入 x=2 得到预测值 194.99。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686503/detail?pid=66224898&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686503/detail?pid=66224898&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:07:26.563081+00:00', '2026-07-02T15:09:07.644261+00:00', 2000, 262144, 'Ai'),
	(211, '二分查找-I', '二分查找-I', '牛客', 'Easy', 'binary-search', '请实现无重复数字的升序数组的二分查找 

给定一个 元素升序的、无重复数字的整型数组 nums 和一个目标值 target ，写一个函数搜索 nums 中的 target，如果目标值存在返回下标（下标从 0 开始），否则返回 -1 

数据范围：$0 \le len(nums) \le 2\times10^5$ ， 数组中任意值满足 $|val| \le 10^9$ 
进阶：时间复杂度 $O(\log n)$ ，空间复杂度 $O(1)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[-1,0,3,4,6,10,13,14],13
```

**输出：**
```
6
```

**说明：**
13 出现在nums中并且下标为 6

### 样例 2

**输入：**
```
[],3
```

**输出：**
```
-1
```

**说明：**
nums为空，返回-1

### 样例 3

**输入：**
```
[-1,0,3,4,6,10,13,14],2
```

**输出：**
```
-1
```

**说明：**
2 不存在nums中因此返回 -1', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/d3df40bd23594118b57554129cadf47b?tpId=295&tqId=1499549&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/d3df40bd23594118b57554129cadf47b?tpId=295&tqId=1499549&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:24:51.974775+00:00', '2026-07-03T12:27:28.868343+00:00', 2000, 262144, '常见101'),
	(109, '深海潜艇探险', '深海潜艇探险', '华为', 'Medium', 'simulation', '一艘高科技深海潜艇正在执行一项对未知海沟的探险任务。在它的航线上，分布着 $n$ 个地质活动异常的危险区域。

潜艇的初始能量储备为 $m$。对于第 $i$ 个危险区域，潜艇需要消耗 $a_i$ 的能量才能安全通过；在成功通过后，潜艇可以利用该区域尽头的海底热泉补充 $b_i$ 的能量。

能量的消耗 ($a_i$) 发生在穿越过程中，而能量的补充 ($b_i$) 必须在完全穿越该区域后才能进行。潜艇的驾驶员可以自由规划穿越这 $n$ 个区域的顺序。

任务成功的条件是，在穿越所有区域的整个过程中，潜艇的能量值必须始终大于 0。如果在穿越任何一个区域的过程中，潜艇的能量值 $E$ 满足 $E \le 0$，任务就会因能量耗尽而失败。

请判断，是否存在一个安全的航行顺序，能让潜艇成功完成这次探险任务。

## 输入格式

第一行包含一个整数 $T$ ($1 \le T \le 10$)，代表测试数据的组数。

对于每组测试数据：
- 第一行包含两个整数 $n$ 和 $m$ ($1 \le n, m \le 10^5$)，分别代表危险区域的数量和潜艇的初始能量。
- 接下来 $n$ 行，每行包含两个整数 $a_i$ 和 $b_i$ ($0 \le a_i, b_i \le 10^5$)，分别代表穿越第 $i$ 个区域的能量消耗和补充量。
- 注意：每一对 $(a_i, b_i)$ 是绑定的，但穿越的顺序可以自由安排。

## 输出格式

对于每组测试数据，如果存在一个安全的航行顺序，则输出 Yes ，否则输出 No 。

## 样例

### 样例 1

**输入：**
```
2
2 5
3 2
4 5
2 5
3 2
4 2
```

**输出：**
```
Yes
No
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686254/detail?pid=64590300&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686254/detail?pid=64590300&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.598077+00:00', '2026-07-02T15:25:31.676973+00:00', 2000, 262144, '开发'),
	(60, '任务批处理负载均衡', '任务批处理负载均衡', '华为', 'Medium', 'stack-queue', '一个云计算中心接收到了一系列需要连续处理的微任务。现在有 $n$ 个任务排成一队，每个任务都有一个已知的计算成本。为了高效利用服务器资源，系统需要将这 $n$ 个连续的任务划分成 $m$ 个“批次”进行处理。

划分的规则是：必须按照任务队列的顺序进行划分，不能打乱任务原有的先后次序。例如，第一个批次处理前 $k_1$ 个任务，第二个批次处理接下来的 $k_2$ 个任务，以此类推。

为了使服务器负载尽可能平稳，调控目标是：找到一种划分方案，使得这 $m$ 个批次各自的“总计算成本”（即批次内所有任务的成本之和）的标准差达到最小。

你的任务就是找出这个最优的划分方案。

## 输入格式

第一行输入两个整数，第一个是任务总数 $n$ ($2 < n \le 20$)，第二个是需要划分的批次数目 $m$ ($2 < m < n$)。

第二行输入一个包含 $n$ 个正整数的序列 $C = \{c_0, c_1, \dots, c_{n-1}\}$，其中第 $i$ 个元素 $c_i$ 代表第 $i$ 个任务的计算成本 ($0 < c_i < 100$)。

## 输出格式

输出一行，包含 $m$ 个整数，代表最优划分方案中，每个批次依次包含的任务数量。
例如，输出 `3 3 2 2` 表示：第 1 批包含前 3 个任务，第 2 批包含接下来的 3 个任务，第 3 批包含再接下来的 2 个任务，第 4 批包含最后 2 个任务。

## 样例

### 样例 1

**输入：**
```
8 4
30 42 85 19 65 13 94 57
```

**输出：**
```
2 1 3 2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678396/detail?pid=63554020&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678396/detail?pid=63554020&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:18:05.180494+00:00', '2026-07-02T12:18:43.380981+00:00', 2000, 262144, '开发'),
	(199, '合并k个已排序的链表', '合并k个已排序的链表', '牛客', 'Medium', 'linked-list', '合并 k 个升序的链表并将结果作为一个升序的链表返回其头节点。 

数据范围：节点总数 $0 \le n \le 5000$，每个节点的val满足 $|val| <= 1000$ 
要求：时间复杂度 $O(nlogn)$

## 样例

### 样例 1

**输入：**
```
[{1,2,3},{4,5,6,7}]
```

**输出：**
```
{1,2,3,4,5,6,7}
```

### 样例 2

**输入：**
```
[{1,2},{1,4,5},{6}]
```

**输出：**
```
{1,1,2,4,5,6}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/65cfde9e5b9b4cf2b6bafa5f3ef33fa6?tpId=295&tqId=724&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/65cfde9e5b9b4cf2b6bafa5f3ef33fa6?tpId=295&tqId=724&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.235742+00:00', '2026-07-03T12:13:24.608939+00:00', 2000, 262144, '常见101'),
	(86, '二分类的意图判定', '二分类的意图判定', '华为', 'Medium', 'binary-search', '- 
任务: 用逻辑回归做二分类的意图判定。输入是一串仅由大写字母A～G组成的字符串；输出是标签0或1。

- 
特征: 对每条字符串做7维one-hot存在编码，顺序固定为A B C D E F G；某字母出现过则该维取1，否则取0。

- 
模型: 单层逻辑回归，权重w和偏置b初始为0；激活用sigmoid；损失为二分类交叉熵；优化用学习率0.1、轮数20、batch size=1 的梯度下降；最终预测阈值0.5，大于阈值判1，否则判0。

## 输入格式

- 第一行: N M（N条训练数据，M条测试数据）
- 接下来的N行: 训练样本，“字符串 标签”，字符串仅含A～G，标签为0或1
- 接下来的M行: 测试样本字符串

## 输出格式

- 共M行，每行输出一个0或1

## 样例

### 样例 1

**输入：**
```
5 2
ABC 1
ADG 1
BE 1
CFG 1
ABCFG 1
A
BG
```

**输出：**
```
1
1
```

**说明：**
训练集中所有标注为1，从w=b=0开始，梯度会把z推大，使预测逐步超过0.5，因而对任意测试串都输出1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686231/detail?pid=64590230&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686231/detail?pid=64590230&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:00:05.608425+00:00', '2026-07-02T15:00:58.990034+00:00', 2000, 262144, 'Ai'),
	(74, '规矩出方圆', '规矩出方圆', '华为', 'Medium', 'simulation', '在边长为 1 的正方形画布上，圆心放在 (0.5, 0.5)，半径为 0.5 的圆恰好内切于画布。

![题面配图](https://uploadfiles.nowcoder.com/images/20251107/0_1762484032002/3EB512A6AD49FD2206419F3D2660741E)

我们要在水平方向与竖直方向各放置 M 条切割线（含边界 0 和 1，总共 M 条），把正方形分成 M×M 个小矩形。每个小矩形只要与圆的交集面积大于 1e-10，就视为“被染色”。当 M 为奇数时，期望通过巧妙地安排切割线的位置，使所有被染色的小矩形的总面积尽可能小，并输出这个最小面积，结果四舍五入到小数点后 4 位。

为简化问题，可以利用关于中心对称的性质：最优方案可以令横纵切割线共享同一组坐标。进一步地，若先确定所有横向坐标，那么每条横线与圆的两个交点会给出两条最合适的竖线位置，这样就能把优化变量收缩到一维（只需要优化横向坐标即可）。目标就是最小化由这些条带宽度与对应圆的水平截线宽度共同决定的“被染色面积”。

## 输入格式

一行一个奇数 M，5 ≤ M ≤ 200。

## 输出格式

一行一个小数，为最小染色面积，保留 4 位小数（四舍五入）。

## 样例

### 样例 1

**输入：**
```
9
```

**输出：**
```
0.8457
```

**说明：**
当 M=9 时，采用中心对称、横纵同坐标的非等距切分，并将竖线对齐到每条横线与圆的交点附近，能把被染色矩形尽量“贴”着圆边，从而减少多余覆盖。使用数值优化求得的最小面积约为 0.8457，四舍五入后输出 0.8457。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683739/detail?pid=65084889&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683739/detail?pid=65084889&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:58:11.210753+00:00', '2026-07-02T15:03:45.429044+00:00', 2000, 262144, 'Ai'),
	(232, '在二叉树中找到两个节点的最近公共祖先', '在二叉树中找到两个节点的最近公共祖先', '牛客', 'Medium', 'tree', '给定一棵二叉树(保证非空)以及这棵树上的两个节点对应的val值 o1 和 o2，请找到 o1 和 o2 的最近公共祖先节点。 

数据范围：树上节点数满足 $1 \le n \le 10^5 \$ , 节点值val满足区间 [0,n) 
要求：时间复杂度 $O(n)$ 

注：本题保证二叉树中每个节点的val值均不相同。 

如当输入{3,5,1,6,2,0,8,#,#,7,4},5,1时，二叉树{3,5,1,6,2,0,8,#,#,7,4}如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211014/423483716_1634206667843/D2B5CA33BD970F64A6301FA75AE2EB22)

所以节点值为5和节点值为1的节点的最近公共祖先节点的节点值为3，所以对应的输出为3。

节点本身可以视为自己的祖先 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{3,5,1,6,2,0,8,#,#,7,4},5,1
```

**输出：**
```
3
```

### 样例 2

**输入：**
```
{3,5,1,6,2,0,8,#,#,7,4},2,7
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/e0cc33a83afe4530bcec46eba3325116?tpId=295&tqId=1024325&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/e0cc33a83afe4530bcec46eba3325116?tpId=295&tqId=1024325&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:34.043054+00:00', '2026-07-03T16:39:50.203516+00:00', 2000, 262144, '常见101'),
	(220, '求二叉树的层序遍历', '求二叉树的层序遍历', '牛客', 'Medium', 'tree', '给定一个二叉树，返回该二叉树层序遍历的结果，（从左到右，一层一层地遍历）
例如：
给定的二叉树是{3,9,20,#,#,15,7},

![题面配图](https://uploadfiles.nowcoder.com/images/20210114/999991351_1610616074120/036DC34FF19FB24652AFFEB00A119A76)

该二叉树层序遍历的结果是
[
[3],
[9,20],
[15,7] 
] 

提示: 
0 <= 二叉树的结点数 <= 1500 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2}
```

**输出：**
```
[[1],[2]]
```

### 样例 2

**输入：**
```
{1,2,3,4,#,#,5}
```

**输出：**
```
[[1],[2,3],[4,5]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/04a5560e43e24e9db4595865dc9c63a3?tpId=295&tqId=644&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/04a5560e43e24e9db4595865dc9c63a3?tpId=295&tqId=644&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.414476+00:00', '2026-07-03T16:41:54.461604+00:00', 2000, 262144, '常见101'),
	(200, '判断链表中是否有环', '判断链表中是否有环', '牛客', 'Easy', 'linked-list', '判断给定的链表中是否有环。如果有环则返回true，否则返回false。 

数据范围：链表长度 $0 \le n \le 10000$，链表中任意节点的值满足 $|val| <= 100000$

要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

输入分为两部分，第一部分为链表，第二部分代表是否有环，然后将组成的head头结点传入到函数里面。-1代表无环，其它的数字代表有环，这些参数解释仅仅是为了方便读者自测调试。实际在编程时读入的是链表的头节点。 

例如输入{3,2,0,-4},1时，对应的链表结构如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20220110/423483716_1641800950920/0710DD5D9C4D4B11A8FA0C06189F9E9C)

可以看出环的入口结点为从头结点开始的第1个结点（注：头结点为第0个结点），所以输出true。

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{3,2,0,-4},1
```

**输出：**
```
true
```

**说明：**
第一部分{3,2,0,-4}代表一个链表，第二部分的1表示，-4到位置1（注：头结点为位置0），即-4->2存在一个链接，组成传入的head为一个带环的链表，返回true

### 样例 2

**输入：**
```
{1},-1
```

**输出：**
```
false
```

**说明：**
第一部分{1}代表一个链表，-1代表无环，组成传入head为一个无环的单链表，返回false

### 样例 3

**输入：**
```
{-1,-7,7,-4,19,6,-9,-5,-2,-5},6
```

**输出：**
```
true
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/650474f313294468a4ded3ce0f7898b9?tpId=295&tqId=605&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/650474f313294468a4ded3ce0f7898b9?tpId=295&tqId=605&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.296111+00:00', '2026-07-03T12:12:58.355245+00:00', 2000, 262144, '常见101'),
	(44, '统计量列表', '统计量列表', '华为', 'Medium', 'sliding-window', '给定一个整数序列与一个窗口大小列表。对每一行输入，固定一个公共右边界，对窗口列表中的每个窗口长度各取一个“右对齐”的子数组，分别计算5个统计量，并按窗口列表的顺序依次拼接成一行结果；沿着序列从左到右依次移动右边界，生成多行输出。

统计量与计算约定

- 
每个子数组输出5项（固定顺序）：mean、std、min、max、slope。

- 
std: 样本标准差（ddof=1）。当窗口长度为1时，std=0。

- 
slope: 最小二乘直线斜率，横坐标为 x=0..w−1。若分母为0或 w=1，则 slope=0。

- 
数值格式：若为整数则不带小数点；非整数最多保留3位小数，四舍五入，去掉末尾无意义的0（如 1.0→1，1.10→1.1，1.1116→1.112）。

窗口对齐与行数

- 
窗口对齐方式：右对齐。第 i 行的公共右边界为 R=i+max(window_array)−1。对窗口大小 w，取子数组 arr[R−w+1…R]。

- 
行数 n = len(input_array) − max(window_array) + 1。若 len(input_array) < 任一窗口大小，则输出为空。

## 输入格式

支持多行输入；每行一组数据，格式为：
[整数序列], [窗口大小序列]
例如：[1, 2, 3, 4, 5], [2, 3]

## 输出格式

对每一行输入，按行输出多个结果行；每个结果行是该位置处按窗口列表顺序拼接的统计量列表。
若该行输入不满足条件（如数组过短），仅输出一行“[]”。

## 样例

### 样例 1

**输入：**
```
[2, 4, 6, 8, 10, 12], [2, 4]
```

**输出：**
```
[7, 1.414, 6, 8, 2, 5, 2.582, 2, 8, 2]
[9, 1.414, 8, 10, 2, 7, 2.582, 4, 10, 2]
[11, 1.414, 10, 12, 2, 9, 2.582, 6, 12, 2]
```

**说明：**
最长窗口为4，右对齐到各行的共同右边界 R，因此共有 6-4+1=3 行。
第1行：w=2 用 [6,8]，w=4 用 [2,4,6,8]；依序拼接5个特征后输出。其余行同理。

### 样例 2

**输入：**
```
[10, 20], [3, 4]
```

**输出：**
```
[]
```

**说明：**
输入序列长度为 2，最大窗口为 4，因 2 < 4 无法形成任何右对齐窗口，按规则该行仅输出“[]”。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678252/detail?pid=63881245&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678252/detail?pid=63881245&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:07:54.673335+00:00', '2026-07-02T12:08:21.310811+00:00', 2000, 262144, 'Ai'),
	(49, '最大能量和', '最大能量和', '华为', 'Medium', 'matrix-grid', '在一幅高为 H、宽为 W 的灰度图中，每个像素都有一个实数信号值。给定一个 K×K 的策略矩阵（K 为奇数），我们先依据该矩阵为整幅图计算“能量图” E；随后，从图像的第 1 列任意行作为起点，每一列向右选择一个格子，且列与列之间的移动仅允许三种：右、右上或右下，直到走到第 W 列。请你选择一条合规路径，使路径上对应能量之和最大，并输出该最大值。

- 

能量图计算规则（零填充相关）：记 r = K//2

E[i][j] = Σu=0..K-1 Σv=0..K-1 P[u][v] · I[i+u−r][j+v−r]

若 i+u−r 或 j+v−r 越界，则视为该项贡献为 0。

- 

路径规则：起点为第 1 列任意行；从 (i, j) 到下一列可走到 (i, j+1)、(i−1, j+1) 或 (i+1, j+1)，越界无效。

- 

输出：最大能量和，保留 1 位小数。

## 输入格式

- 第一行：H W K
- 接下来 H 行：每行 W 个浮点数，表示图像 I
- 接下来 K 行：每行 K 个浮点数，表示策略矩阵 P

## 输出格式

一行一个浮点数：最大能量和（四舍五入保留 1 位小数）

## 样例

### 样例 1

**输入：**
```
2 2 1
1 2
3 4
2
```

**输出：**
```
14.0
```

**说明：**
K=1 且 P=[2]，能量图即 E=2·I=[[2,4],[6,8]]。从第 1 列到第 2 列的最优路径为 (2,1)→(2,2)，能量和 6+8=14.0。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678346/detail?pid=64837942&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678346/detail?pid=64837942&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:12:03.720414+00:00', '2026-07-02T12:12:30.055348+00:00', 2000, 262144, 'Ai'),
	(50, '基于空间连续块的稀疏注意力机制', '基于空间连续块的稀疏注意力机制', '华为', 'Medium', 'simulation', '为提升长序列推理效率，现定义一套“分块压缩 + 打分 + 二段划分”的流程。给定长度为 n、维度为 d 的向量序列 X0..X(n-1)（均非零）与块大小 b，将序列按顺序切成相邻的 m=ceil(n/b) 个连续块，每块至多 b 个向量（最后一块可不足 b 个）。

对第 k 个块（1≤k≤m）：

- 
先做按维度的“块内均值”得到向量 h_k（每一维为该块该维的平均值）。

- 
设常数 b1=2、b2=1，并给定长度为 d 的向量 W1、W2。定义

s_k = W1 · h_k + b1，z_k = max(0, s_k)，c_k = W2 * z_k + b2

其中 “W2 * z_k” 表示用标量 z_k 逐分量缩放 W2，c_k 与 W2 同为 d 维。

- 
定义 q 为全 1 的 d 维向量，得到标量打分

a_k = (q · c_k) / sqrt(d) = (c_k 各分量之和) / sqrt(d)。

得到序列 A = (a_1, a_2, ..., a_m) 后，把 A 恰好切成 2 段且两段都非空、彼此连续，记两段元素和分别为 S1、S2，目标最大化 min(S1, S2)。记最优值为 S，输出 round(100*S) 的整数（四舍五入到最近整数）。

## 输入格式

- 第一行：n d b
- 接下来 n 行：每行 d 个实数，依次为 X0..X(n-1)
- 倒数第 2 行：d 个实数，表示 W1
- 最后一行：d 个实数，表示 W2

## 输出格式

一行一个整数：round(100*S)

## 样例

### 样例 1

**输入：**
```
4 1 2
1
3
2
5
1.5
2
```

**输出：**
```
1100
```

**说明：**
- 分块：B1=[1,3]，B2=[2,5]。h1=2.0，h2=3.5。
- b1=2，b2=1，W1=1.5，W2=2。
- s1=1.52+2=5 → z1=5 → c1=25+1=11 → a1=11/√1=11
- s2=1.53.5+2=7.25 → z2=7.25 → c2=27.25+1=15.5 → a2=15.5

- A=[11,15.5]，唯一切分 [11]|[15.5]，min=11，输出 round(1100)=1100。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678346/detail?pid=64837942&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678346/detail?pid=64837942&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:12:03.780913+00:00', '2026-07-02T12:12:17.318052+00:00', 2000, 262144, 'Ai'),
	(75, '医疗诊断模型的训练', '医疗诊断模型的训练', '华为', 'Medium', 'hashing', '某医疗系统要用一次“线性映射 + 线性分类”结构对问卷症状序列做三步计算：前向预测、MSE 损失、一次 SGD 权重更新。设一条问卷包含 L 条症状记录，每条症状是 D 维向量。先用一个 D×D 的权重矩阵把每条症状做线性变换，再用一个 D×K 的权重矩阵得到 K 维分类打分。把所有记录的打分在“症状条目维度”求平均，得到最终的 K 维预测向量（不做 softmax 归一化）。随后与给定的 K 维真实向量做 MSE 损失，并用学习率 η 进行一次 SGD 更新这两个权重矩阵（均无偏置）。

## 输入格式

- 输入第 1 行：L,D,K,η
- 第 2 行：真实向量 y（K 个数）
- 第 3 行：序列矩阵 X（按行展平，共 L×D 个数）
- 第 4 行：映射矩阵 W_mlp（按行展平，共 D×D 个数）
- 第 5 行：分类矩阵 W_cls（按行展平，共 D×K 个数）
计算规则（均为行优先展平与输出，四舍五入保留 2 位小数）：

- H = X @ W_mlp（逐行相乘），h_mean = 每行 H 的平均（1×D）
- y_pred = h_mean @ W_cls（1×K）
- MSE = (1/K) * Σ(y_pred[i] − y[i])^2
- 令 g = (2/K) * (y_pred − y)（1×K）
- grad_W_cls = 外积(h_mean, g)（D×K）
- 令 x_mean = 每行 X 的平均（1×D），u = g @ W_cls^T（1×D）
grad_W_mlp = 外积(x_mean, u)（D×D）
- 参数更新：W_mlp -= η * grad_W_mlp，W_cls -= η * grad_W_cls

## 输出格式

输出共 4 行：
1) y_pred（K 个数） 
2) MSE（1 个数） 
3) 更新后的 W_mlp（D×D 个数，行优先） 
4) 更新后的 W_cls（D×K 个数，行优先）

## 样例

### 样例 1

**输入：**
```
1,2,3,0.3
0.5,1.5,2.0
1.0,2.0
1.0,0.0,0.0,1.0
1.0,0.0,0.0,0.0,1.0,1.0
```

**输出：**
```
1.00,2.00,2.00
0.17
0.90,-0.10,-0.20,0.80
0.90,-0.10,0.00,-0.20,0.80,1.00
```

**说明：**
h_mean = [1,2]；y_pred = [1,2,2]；MSE = 0.17。 
g = (2/3)*([0.5,0.5,0]) = [0.33,0.33,0.00]；据此求两矩阵梯度并以 η=0.3 更新后得到上述权重。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686166/detail?pid=65076752&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686166/detail?pid=65076752&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:58:33.727371+00:00', '2026-07-02T15:03:32.158739+00:00', 2000, 262144, 'Ai'),
	(62, '环形粒子加速器的能量校准', '环形粒子加速器的能量校准', '华为', 'Medium', 'simulation', '在一个先进的环形粒子加速器中，科学家们需要精确控制其中粒子的能量分布以进行高能物理实验。加速器环道上分布着 $n$ 个等距的能量监测点，它们实时记录着经过粒子的能量值。我们设这些能量值构成一个序列 $E = \{e_0, e_1, \dots, e_{n-1}\}$。

为了维持加速器磁场的稳定，该能量序列 $E$ 必须满足一种特殊的“循环单调非递减”性质。该性质具体表现为：序列中至多存在一个“断点”，即一个下标 $i \in \{0, 1, \dots, n-1\}$，使得 $e_i > e_{(i+1) \pmod n}$。在序列的其他所有位置 $j \neq i$，均满足 $e_j \le e_{(j+1) \pmod n}$。这个性质保证了能量从某一点开始单调递增，直到达到峰值，然后跃迁回最低值，形成一个闭环。

例如，能量序列 $\{30, 40, 50, 10, 20\}$ 就是一个满足该性质的序列。能量从 $30$ 开始递增到 $50$，然后在监测点 $2$ 之后，“断点”出现，$e_2 = 50 > e_3 = 10$，能量跃迁回 $10$，并再次开始递增。

现在，实验需要向加速器中注入一个新的粒子，其能量值为 $e_{new}$。您的任务是，找到一个合适的插入位置，将 $e_{new}$ 插入到序列 $E$ 中，形成一个长度为 $n+1$ 的新序列 $E''$，并确保 $E''$ 仍然满足“循环单调非递减”性质。

如果存在多个合法的位置可以插入新的粒子，为了保证系统的快速响应，请选择使得新粒子在新序列 $E''$ 中下标最小的那个位置。

## 输入格式

第一行包含一个整数 $n$，代表初始状态下监测点的数量，其中 $2 < n \le 400$。
第二行包含 $n$ 个整数，代表序列 $E$ 中的各个能量值 $e_i$，其中 $1 \le e_i \le 1000$。
第三行包含一个整数 $e_{new}$，代表待注入粒子的能量值，其中 $1 \le e_{new} \le 1000$。

## 输出格式

输出一行，包含 $n+1$ 个整数，代表插入新粒子后，符合要求的能量序列 $E''$。整数之间用空格隔开。

## 样例

### 样例 1

**输入：**
```
7
23 37 39 49 49 16 22
33
```

**输出：**
```
23 33 37 39 49 49 16 22
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678649/detail?pid=64321083&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678649/detail?pid=64321083&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:20:00.643986+00:00', '2026-07-02T12:20:38.393412+00:00', 2000, 262144, '开发'),
	(83, '结构化剪枝后的分类预测', '结构化剪枝后的分类预测', '华为', 'Medium', 'matrix-grid', '在终端设备上部署模型时，常需要先压缩网络规模。现给定一批样本矩阵 X（n 行 d 列）、一层线性分类器的权重矩阵 W（d 行 c 列），以及剪枝比例 ratio。请对 W 进行“按行剪枝”（即移除整行，对应丢弃一个输入特征），然后用剪枝后的模型对每个样本做预测，输出每行样本的预测类别索引（从 0 开始）。

任务要求

- 
剪枝指标：对 W 的每一行计算 L1 范数（该行各元素绝对值之和）。L1 越小，越不重要。

- 
剪枝行数：k = floor(ratio × d)。若 ratio > 0 且 floor(ratio × d) = 0，则令 k = 1（至少剪 1 行）。

- 
剪枝规则：移除 L1 范数最小的 k 行，得到新权重 W''（形状为 (d−k) × c）。

- 
特征对齐：将 X 中与被移除行同索引的列一并删除，得到 X''（形状为 n × (d−k)）。

- 
线性输出：h = X'' × W''，得到大小为 n × c 的分数矩阵。

- 
稳定 Softmax：对 h 的每一行 i，先减去该行最大值，再做 softmax，得到概率分布 y_i。softmax 仅用于说明稳定做法；最终类别索引与直接对 h 行取最大位置相同。

- 
预测结果：对每行取 argmax（若有并列则取最左的列索引），输出为一行，用空格分隔各样本类别索引。

## 输入格式

- 第一行：三个整数 n d c。
- 接着 n 行：每行 d 个浮点数，构成矩阵 X。
- 接着 d 行：每行 c 个浮点数，构成矩阵 W。
- 最后一行：一个浮点数 ratio（0 <= ratio <= 1.0）。

## 输出格式

- 一行，输出 n 个整数，空格分隔，为每个样本的预测类别索引。

## 样例

### 样例 1

**输入：**
```
3 3 2
1 0 0
0 1 0
0 0 1
2 1
0 -1
-2 3
0.33
```

**输出：**
```
0 0 1
```

**说明：**
d=3，ratio=0.33 → floor(0.33×3)=0，但 ratio>0，因此 k=1；
W 的行 L1：row1=3，row2=1，row3=5 → 移除 row2；
删除 X 的第 2 列，得到 X''；W 删除对应行得到 W''；
计算 h=X''W'' 后逐行取最大位置，得到预测 0 0 1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683632/detail?pid=65420941&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683632/detail?pid=65420941&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:59:34.329719+00:00', '2026-07-02T15:01:35.613417+00:00', 2000, 262144, 'Ai'),
	(82, '无核翻转的卷积计算', '无核翻转的卷积计算', '华为', 'Medium', 'matrix-grid', '给定奇数大小的核矩阵 m×m（m>1）和一张 n×n 的灰度图，先在图像四周用 0 做足量填充，使得输出尺寸与原图一致，然后对每个像素位置 (i,j)，用核与其邻域逐元素相乘后求和，得到输出像素。

注意：这里采用的是无核翻转的相关方式（即核的左上元素对齐到邻域的左上元素）。

## 输入格式

第 1 行：两个整数 m n，表示核大小和图像大小（m 为奇数，m>1，n>1）。
接下来 m 行：核矩阵，每行 m 个整数，范围 [-10, 10]。
接下来 n 行：图像矩阵，每行 n 个整数，范围 [0, 255]。

## 输出格式

输出 n 行，每行 n 个整数，以空格分隔，表示与零填充后做相关运算的结果，尺寸与输入图像一致。

## 样例

### 样例 1

**输入：**
```
3 3
1 0 0
0 0 0
0 0 0
1 2 3
4 5 6
7 8 9
```

**输出：**
```
0 0 0
0 1 2
0 4 5
```

**说明：**
核只有左上角为 1（其余为 0），采用“相关”而非翻转卷积，因此输出像素等于当前位置左上邻居的取值；越界处按零填充，故第一行与第一列大多为 0。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686290/detail?pid=65355595&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686290/detail?pid=65355595&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:59:19.540642+00:00', '2026-07-02T15:01:47.753833+00:00', 2000, 262144, 'Ai'),
	(88, 'RAG系统最大收益', 'RAG系统最大收益', '华为', 'Medium', 'intervals', '我们在搭建一个基于 RAG（Retrieval-Augmented Generation，检索增强生成）的问答系统。系统每天会接收用户问题，并基于“知识库”检索相关材料后再生成答案。为了保证检索质量，知识库需要定期“更新”（例如重抽取文档、重算向量、重建索引等），但更新会消耗计算资源。另一方面，只有当知识库处于“有效”状态时，基于它进行的查询才有实际收益；知识库过期后继续查询几乎没有价值（可以视为收益 0）。 

因此，在接下来的 n 个连续自然日（周期）内，我们需要规划每天是否进行“更新”、是否“查询”，以最大化净利润（总查询收益 − 总更新成本）。

规则说明

- 
初始状态：第 0 天开始时，知识库“过期”。

- 
更新生效：若在第 i 天执行更新，则从第 i 天起连续 d 天“有效”，覆盖区间 [i, i+d-1]。有效当日可以马上用于查询。

- 
每天允许的操作（每天最多选一个）：

- 
更新并查询：当日支付 update_cost[i]，同时获得当日查询收益 query_reward[i]（因为更新后立即有效）。

- 
仅查询：若当日处于有效期，则获得 query_reward[i]；若过期，则收益为 0。

- 
什么也不做：无成本、无收益（若当日处于有效期，仍会消耗有效期一天）。

- 
目标：在 n 天内，使“总查询收益 − 总更新成本”最大。

直观理解：更新能“刷新”后续 d 天的检索质量（可带来查询收益），但更新要花钱；不更新也能查，但只有在还没过期的有效日才有收益。

## 输入格式

- 第 1 行：n d
- 第 2 行：update_cost（长度为 n，空格分隔）
- 第 3 行：query_reward（长度为 n，空格分隔）

## 输出格式

- 一行一个整数：最大净利润

## 样例

### 样例 1

**输入：**
```
4 2
3 2 4 2
5 0 5 0
```

**输出：**
```
5
```

**说明：**
- 第0天：更新并查询，收益5−成本3=+2（有效覆盖第0、1天）

- 第1天：更新并查询，收益0−成本2=−2（有效重置覆盖第1、2天）

- 第2天：仅查询，+5（仍在有效期）

- 第3天：不操作，+0
合计 2−2+5=5。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686527/detail?pid=65783046&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686527/detail?pid=65783046&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:06:39.207328+00:00', '2026-07-02T15:10:17.136480+00:00', 2000, 262144, 'Ai'),
	(76, '卷积操作', '卷积操作', '华为', 'Medium', 'sliding-window', '在图像任务中，卷积层要对多通道输入做滑窗加权求和。现在请你实现“多通道、单输出通道”的二维卷积：同一位置上，各输入通道卷积结果累加得到输出值，不做激活与归一化。

- 
输入张量形状：(C, H_in, W_in)，共 C 个通道，每个通道是H_in × W_in的二维数组。

- 
卷积核形状：(C, K_h, K_w)，每个通道配一张K_h × K_w的核，通道数与输入相同。

- 
步长与填充：步长为stride（整数 ≥ 1），四周以 0 填充padding层。

- 
计算方式：

1) 先在输入四周补 0，得到尺寸(C, H_in + 2*padding, W_in + 2*padding)。

2) 以步长stride滑动大小为K_h × K_w的窗口；若窗口越界（不足以覆盖核），该位置跳过。

3) 对每个窗口：逐通道与对应核做逐元素相乘并求和，再把各通道和相加，得到该格的输出值。

- 
输出张量形状为(H_out, W_out)，其中

H_out = (H_in + 2*padding - K_h) // stride + 1

W_out = (W_in + 2*padding - K_w) // stride + 1

- 
所有输入与输出均为整数。

## 输入格式

- 第1行：C H_in W_in
- 接下来C * H_in行：按“通道 1 的 H_in 行，再通道 2 的 H_in 行，…”的顺序，每行含W_in个整数
- 下一行：C K_h K_w（C 必与第一行一致）
- 接下来C * K_h行：按通道顺序，每个通道给出K_h行、每行K_w个整数
- 最后一行：stride padding

## 输出格式

- 输出H_out行、每行W_out个整数，空格分隔

## 样例

### 样例 1

**输入：**
```
1 3 3
1 2 3
4 5 6
7 8 9
1 2 2
1 0
0 1
1 0
```

**输出：**
```
6 8
12 14
```

**说明：**
- 形状计算：H_out=(3+2*0-2)//1+1=2，W_out 同理为 2，输出为 2×2。
- 位置(0,0)窗口=[[1,2],[4,5]]，与核[[1,0],[0,1]]逐元素相乘并求和：11+20+40+51=6。
- 位置(0,1)窗口=[[2,3],[5,6]] → 21+30+50+61=8。
- 位置(1,0)窗口=[[4,5],[7,8]] → 41+50+70+81=12。
- 位置(1,1)窗口=[[5,6],[8,9]] → 51+60+80+91=14。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686166/detail?pid=65076752&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686166/detail?pid=65076752&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:58:33.780689+00:00', '2026-07-02T15:03:19.555522+00:00', 2000, 262144, 'Ai'),
	(69, '人脸关键点对齐', '人脸关键点对齐', '华为', 'Medium', 'hashing', '在人脸识别等任务中，经常需要把一幅二维灰度图做仿射变换。给定输入图像矩阵 A、仿射矩阵 M 以及目标图像尺寸，采用前向映射方式把原图像像素投到新坐标系中，超出目标范围的像素丢弃，目标中未被覆盖处保持为 0。

- 
仿射矩阵 M 为两行三列：

第一行 [a, b, tx]，第二行 [c, d, ty]。

- 
对原图中列坐标 x、行坐标 y（均从 0 开始计），对应的新坐标计算为：

x'' = ax + by + tx

y'' = cx + dy + ty

- 
采用前向映射（source→target）：对每个源像素计算 (x'', y'')，若 0 ≤ x'' < out_width 且 0 ≤ y'' < out_height，则把该像素值写入目标图像 (y'', x'')；否则忽略。不做插值，按整数坐标落点覆盖。目标图像初始全 0。

- 
输出为按行展开的一行数字（从第 0 行到最后一行，行内自左至右）。

## 输入格式

- 第一行：a m o 三个整数，依次为输入图像 A 的行数 a、仿射矩阵行数 m（固定为 2）、以及后续“输出尺寸行数” o（固定为 1）。
- 接着 a 行：每行若干整数，表示该行像素值（列数由每行给出，行内列数保持一致）。
- 接着 m 行：每行 3 个整数，依次为仿射矩阵的参数 [a, b, tx] 与 [c, d, ty]。
- 最后 o 行：每行两个整数 out_height out_width，表示目标图像尺寸（行数、高度；列数、宽度）。

## 输出格式

一行：将目标图像按行展开输出，元素之间用空格分隔。

## 样例

### 样例 1

**输入：**
```
2 2 1
1 2 3
4 5 6
1 0 1
0 1 1
3 4
```

**输出：**
```
0 0 0 0 0 1 2 3 0 4 5 6
```

**说明：**
图像 2×3；M 表示整体平移 (+1, +1)；目标尺寸 3×4。 
源像素 (x,y) 被移到 (x+1,y+1)。第 0 行与第 0 列无像素落点，因此为 0；其余位置由源像素覆盖。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686110/detail?pid=64837986&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686110/detail?pid=64837986&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:57:27.867020+00:00', '2026-07-02T15:04:56.165523+00:00', 2000, 262144, 'Ai'),
	(219, '二叉树的后序遍历', '二叉树的后序遍历', '牛客', 'Easy', 'tree', '给定一个二叉树，返回他的后序遍历的序列。 

后序遍历是值按照 左节点->右节点->根节点 的顺序的遍历。 

数据范围：二叉树的节点数量满足 $1 \le n \le 100 \$ ，二叉树节点的值满足 $1 \le val \le 100 \$ ，树的各节点的值各不相同

样例图 

![题面配图](https://uploadfiles.nowcoder.com/images/20211111/392807_1636596692486/64547759EAC75079FDBF501CAA589890)

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,#,2,3}
```

**输出：**
```
[3,2,1]
```

**说明：**
如题面图

### 样例 2

**输入：**
```
{1}
```

**输出：**
```
[1]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/1291064f4d5d4bdeaefbf0dd47d78541?tpId=295&tqId=2291301&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/1291064f4d5d4bdeaefbf0dd47d78541?tpId=295&tqId=2291301&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:31:22.131337+00:00', '2026-07-03T16:42:07.051909+00:00', 2000, 262144, '常见101');
INSERT INTO public.problems VALUES
	(42, 'MOE Top‑k 路由', 'MOE Top‑k 路由', '华为', 'Medium', 'simulation', '在一个稀疏 MOE 模型中，有 n 个专家顺序编号为 0…n-1，这些专家被平均分布到 m 张 NPU 卡上，每张卡上一组，且同组专家编号连续。为降低跨卡通信，现将路由目标限制在最多 p 张 NPU 上： 

1) 先对每组求组内概率最大值及其专家编号，作为该组的代表值； 

2) 把所有组按“代表概率”从高到低排序，若概率相同则组号小的在前，取前 p 个组； 

3) 仅在上述 p 个组包含的所有专家里，按“概率降序、编号升序”挑选前 k 位的专家编号作为最终路由目标。 

约束与异常 

- 若 n 不能被 m 整除，则无法平均分组，输出 error。 

- 若 p>m，输出 error。 

- 设每组大小 g=n/m，若可选专家总数 p·g<k，无法选够 k 人，输出 error。

## 输入格式

第一行：四个整数 n m p k（1≤n,m,p,k≤10000） 
第二行：n 个浮点数，依次为专家 0…n-1 的概率，均在 (0,1) 内

## 输出格式

若发生异常，输出 error 
否则输出 k 个专家编号，升序，空格分隔（行尾无空格）

## 样例

### 样例 1

**输入：**
```
6 3 2 2
0.3 0.1 0.05 0.6 0.4 0.2
```

**输出：**
```
3 4
```

**说明：**
分组：g=6/3=2。组0=[0,1]→代表(0.3,idx0)，组1=[2,3]→代表(0.6,idx3)，组2=[4,5]→代表(0.4,idx4)。 
选组：按代表概率降序取前 p=2 个，得到组1与组2。 
选专家：在{2,3,4,5}中按概率降序取前 k=2，依次为 idx3(0.6)、idx4(0.4)；最后升序输出 3 4。

### 样例 2

**输入：**
```
6 4 2 2
0.1 0.2 0.3 0.4 0.5 0.6
```

**输出：**
```
error
```

**说明：**
因为 n=6、m=4，n 必须能被 m 整除才能把专家平均分到每张 NPU 上（组大小 g=n/m 为整数）。这里 6%4≠0，g=1.5 不是整数，无法等分成 4 组，所以按规则直接输出 error。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678186/detail?pid=63699094&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678186/detail?pid=63699094&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:04:14.859936+00:00', '2026-07-02T12:06:55.286459+00:00', 2000, 262144, 'Ai'),
	(77, 'INT8 非对称量化下的全连接与误差评估', 'INT8 非对称量化下的全连接与误差评估', '华为', 'Medium', 'matrix-grid', '在移动端或边缘设备上，浮点运算成本较高。常见做法是将输入向量和全连接层权重做 INT8 非对称量化（按张量整体 per-tensor），用整数在量化域直接做点积，最后用反量化结果评估与原始浮点结果的误差。

【任务】

- 
对输入向量 x 和权重矩阵 W 分别做 INT8 非对称量化（范围 [-128, 127]，不加偏置），输出量化域的 m 个整数点积结果。

- 
将量化后的 x 与 W 分别反量化为 x_dequant、W_dequant，计算二者在浮点域的全连接输出，与原始 x、W 的浮点输出做均方误差 MSE，并输出 round_half_up(MSE × 100000) 的整数。

- 
量化/反量化细节（per-tensor）：

- 
scale = (max(v) - min(v)) / 255

- 
若 max(v) == min(v)，则 scale = 0，量化结果全为 -128；反量化直接取 min(v)

- 
量化：q = clamp(round((v - min(v)) / scale) - 128, -128, 127)，round 为就近取偶

- 
反量化：v_dequant = (q + 128) * scale + min(v)

- 
MSE 四舍五入采用 half-up（即对 MSE×100000 做 “x+0.5 下取整”）

## 输入格式

- 第一行：n（输入向量维度）
- 第二行：n 个浮点数（输入向量 x）
- 第三行：m n（权重矩阵维度）
- 接着 m 行：每行 n 个浮点数（权重矩阵 W）

## 输出格式

- 第一行：m 个整数（使用 x_quant 与 W_quant 计算的量化域全连接输出）
- 第二行：1 个整数（round_half_up(MSE × 100000)）

## 样例

### 样例 1

**输入：**
```
3
0 128 255
2 3
0 0 0
255 255 255
```

**输出：**
```
128 -127
0
```

**说明：**
- 对 x：min=0, max=255, scale=1 → x_quant=[-128, 0, 127]
- 对 W（按张量整体）：min=0, max=255, scale=1 → 第1行量化为[-128,-128,-128]，第2行为[127,127,127]
- 量化域点积：
- y0 = (-128)(-128) + 0(-128) + 127*(-128) = 128
- y1 = (-128)127 + 0127 + 127*127 = -127

- 反量化后与原始浮点结果一致，MSE=0，输出 0', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683676/detail?pid=65176652&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683676/detail?pid=65176652&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:58:49.779268+00:00', '2026-07-02T15:03:04.911992+00:00', 2000, 262144, 'Ai'),
	(40, '验证集可达到的最优F1值', '验证集可达到的最优F1值', '华为', 'Easy', 'binary-search', '- 
决策树若完全按训练集递归生长，往往能把训练样本分得很“细”，但一到未见过的数据就容易出错，即出现过拟合。为缓解这一问题，常用“剪枝”把某些子树整体替换成单个叶子，使模型更简单。

- 
现在有一棵用于二分类的二叉决策树（标签1表示正类，0表示负类）。对非叶节点，按“第 $f_i$ 个特征 ≤ $th_i$ 走左子树，否则走右子树”的规则继续判断；到达叶子时直接输出该节点自带的 $label$。

- 
允许在整棵树上任选若干处进行剪枝（把某个内部节点整体替换为叶节点，其输出为该节点给定的 $label$）。请在给定验证集上寻找使 F1 值最大的剪枝方案，输出最优 F1（四舍五入保留6位小数）。

## 输入格式

第一行：N M K 
N 为节点数(1~100)，M 为验证集条数(1~300)，K 为每条验证样本的特征维数(1~100)。

接下来的 N 行：按节点编号1..N给出每个节点的信息： 
$l_i$ $r_i$ $f_i$ $th_i$ $label_i$ 
其中 $l_i$、$r_i$ 为左右子编号（0表示无子节点，且不存在只有一个子节点的情况）； 
若为非叶节点，$f_i$ 是用于分裂的特征序号(1-based)，$th_i$ 为阈值； 
若为叶节点，$f_i$ 与 $th_i$ 置 0；$label_i$ 表示当该节点作为叶子时的输出标签（0或1）。

接下来的 M 行：每行 K+1 个整数，前 K 个为该条验证样本的特征，最后一个为真实标签（0或1）。

## 输出格式

输出单行浮点数：在验证集上能达到的最大 F1 值，四舍五入到小数点后 6 位。

## 样例

### 样例 1

**输入：**
```
5 5 2
2 3 1 50 0
0 0 0 0 1
4 5 2 70 0
0 0 0 0 0
0 0 0 0 1
40 80 1
55 60 0
55 90 1
55 85 0
20 10 0
```

**输出：**
```
0.666667
```

**说明：**
路由规则：特征1≤50 进左子树，否则进右子树；在右子树中再按特征2≤70 判到左叶（输出0），否则到右叶（输出1）。 
若不剪枝，五条样本的预测与真实标签对比如下：命中两条正类，出现两次“将负类判为正类”，未漏判正类，计算得 F1=2*2/(2*2+2+0)=0.666667。 
尝试将右子树整体剪为叶（输出0）或将根剪为叶（输出0/1）等方案，F1 反而更低。因此最优为 0.666667。

### 样例 2

**输入：**
```
5 6 2
2 3 1 30 1
0 0 0 0 0
4 5 2 50 1
0 0 0 0 1
0 0 0 0 0
35 40 1
35 70 0
35 60 1
25 80 0
28 10 1
50 45 1
```

**输出：**
```
0.800000
```

**说明：**
路由规则：特征1≤30 走左子树（叶，输出0），否则进入右子树；在右子树内，特征2≤50 走左叶（输出1），否则走右叶（输出0）。
不剪枝时：TP=2（命中两条正类），FN=2（漏判两条正类），FP=0，F1=22/(4+0+2)=0.666667。
若把根节点直接剪成叶并输出1，则6条样本预测为1，其中TP=4（四条为正类），FP=2（两条为负类），FN=0，F1=24/(8+2+0)=0.800000。其他剪枝方案（如只剪右子树）得到的F1更低，因此最优为0.800000。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678205/detail?pid=63554070&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678205/detail?pid=63554070&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T09:03:05.683081+00:00', '2026-07-02T12:02:09.813199+00:00', 2000, 262144, 'Ai'),
	(47, 'K-Means算法', 'K-Means算法', '华为', 'Medium', 'simulation', '【场景】为了优化城市基站布局，需要把给定的基站坐标用 K-Means 聚成 k 组，并用轮廓系数评估每个簇的好坏。我们把“平均轮廓系数最低”的簇视为覆盖质量最差的簇，计划在该簇“质心位置”新增一座基站。请你输出这座新基站的坐标（四舍五入到两位小数，采用银行家舍入）。

【任务】

- 
使用前 k 个点作为初始中心执行 K-Means。

- 
轮廓系数定义：对样本 p，a(p) 是其与本簇其他样本的平均距离；b(p) 是其与“其他各簇”样本平均距离中的最小值；s(p)=(b(p)-a(p))/max(a(p), b(p))。若样本所在簇大小≤1，则该样本 s(p)=0。

- 
簇的得分为簇内样本 s(p) 的平均值。得分越低表示越差。

- 
输出平均轮廓系数最低簇的“质心”（各坐标均值）。

## 输入格式

第一行：n k（n 为点数，k 为簇数）
接下来 n 行：每行两个整数 x y，表示一个基站的平面坐标
取值范围：1 ≤ n ≤ 500，1 ≤ k ≤ 120，0 ≤ x ≤ 5000，0 ≤ y ≤ 3000

## 输出格式

一行：新增基站坐标，格式为 x,y（保留两位小数）

## 样例

### 样例 1

**输入：**
```
6 2
0 0
0 1
5 0
10 10
10 11
11 10
```

**输出：**
```
1.67,0.33
```

**说明：**
初始中心为(0,0)、(0,1)。K-Means 收敛后，簇A≈{(0,0),(0,1),(5,0)}，质心≈(1.666...,0.333...)；簇B≈{(10,10),(10,11),(11,10)}，质心≈(10.333...,10.333...)。
簇A分散、与簇B距离也不算远，平均轮廓系数更低，因此选择簇A，其质心四舍五入（银行家舍入）为1.67,0.33。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97678234/detail?pid=64321250&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678234/detail?pid=64321250&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:10:45.889972+00:00', '2026-07-02T12:11:20.030922+00:00', 2000, 262144, 'Ai'),
	(70, '实现多通道二维卷积', '实现多通道二维卷积', '华为', 'Medium', 'simulation', '实现一个多通道二维卷积。给定输入张量形状、数据、卷积核形状与权重，以及卷积参数 bias/stride/padding/dilation，计算输出并按一行打印，数值保留4位小数（不足补0）。

- 
输入张量形状为 c x y，其中 c 为通道数，x 为行数，y 为列数。随后给出 cxy 个实数，按“通道优先，通道内行优先、行内列优先”顺序给出。

- 
卷积核形状为 out in k k，其中 out 为输出通道数，in 为输入通道数（应与 c 相等），k 为核的高与宽。

- 
卷积权重共 outink*k 个实数，顺序为：先按输出通道 0..out-1，再按输入通道 0..in-1，然后核内按行优先、行内列优先。

- 
参数行给出4个整数：bias stride padding dilation。

- 
bias 取 0/1。若为 1，紧随其后再给一行 out 个实数，作为各输出通道的偏置；若为 0，则无该行、偏置默认为 0。

- 
stride、padding、dilation 为各向同性整数（高宽一致）。

- 
计算方式：对每个输出通道 oc、输出位置 (oh, ow)，有

out[oc, oh, ow] = Σ_ic Σ_ki Σ_kj input[ic, ih, iw] * weight[oc, ic, ki, kj] + bias[oc]

其中 ih = ohstride + kidilation - padding，iw = owstride + kjdilation - padding；若 ih/iw 越界，则该项忽略（视为0）。

- 
输出形状为 out × x_out × y_out，其中

x_out = floor((x + 2padding - dilation(k-1) - 1)/stride + 1)

y_out 同理。最终按“输出通道优先，再行优先、再列优先”一行打印，元素间以空格分隔，均保留4位小数。

## 输入格式

- 第1行：c x y
- 第2行：cxy 个实数（通道优先、行优先、列优先）
- 第3行：out in k k
- 第4行：outink*k 个实数（权重，顺序见上）
- 第5行：bias stride padding dilation
- 若 bias=1：第6行再给 out 个实数（各输出通道的偏置）

## 输出格式

- 一行实数，按规定顺序展开，保留4位小数

## 样例

### 样例 1

**输入：**
```
1 3 3
1 2 3 4 5 6 7 8 9
1 1 1 1
2
0 1 0 1
```

**输出：**
```
2.0000 4.0000 6.0000 8.0000 10.0000 12.0000 14.0000 16.0000 18.0000
```

**说明：**
单通道、1×1 卷积核、权重为 2、无偏置，等价于整幅图每个像素乘 2；输出与输入同形状（3×3），按行展开打印。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686110/detail?pid=64837986&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686110/detail?pid=64837986&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:57:27.920591+00:00', '2026-07-02T15:04:43.677767+00:00', 2000, 262144, 'Ai'),
	(68, '实现简化版的 LSTM', '实现简化版的 LSTM', '华为', 'Medium', 'simulation', '- 
任务: 给定一行数据，描述一个长度为 seq_len、每步维度为 x_dim 的输入序列。使用一个固定参数的 LSTM 对序列做前向计算，并输出每个时间步隐藏向量的首元素 h_t[0]。

- 
模型设定:

- 
记忆单元个数 m=5。

- 
初始状态 s0 为全1向量，h0 为全0向量。

- 
四门权重与偏置全为0，因此每步都有 i=f=o=0.5、g=0，递推得到 s_t=0.5^t·s0，h_t=0.5·tanh(s_t)。故 h_t[0]=0.5·tanh(0.5^t)。

- 
说明: 输出与具体输入值无关（由固定参数决定），仅与 seq_len 有关；这样仍符合“按所给 LSTM 前向形式计算并取首元素”的题意。

## 输入格式

- 一行: seq_len x_dim 后接 seq_len·x_dim 个浮点数（按行平铺）。

## 输出格式

- 一行: 依次输出 t=1..seq_len 的 h_t[0]，用空格分隔，四舍五入到小数点后三位，去掉多余尾零；数值为0统一输出0.0。

## 样例

### 样例 1

**输入：**
```
3 4 1 2 3 4 5 6 7 8 9 10 11 12
```

**输出：**
```
0.231 0.122 0.062
```

**说明：**
因 s0≠0，h1[0]=0.5·tanh(0.5)=0.231，h2[0]=0.5·tanh(0.25)=0.122，h3[0]=0.5·tanh(0.125)=0.062（四舍五入到小数点后三位）。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683645/detail?pid=64590239&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683645/detail?pid=64590239&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:57:09.250330+00:00', '2026-07-02T15:05:09.153006+00:00', 2000, 262144, 'Ai'),
	(53, '小红的显存清理挑战', '小红的显存清理挑战', '华为', 'Medium', 'simulation', '小红正在尝试训练一个超大规模的语言模型，但由于显存有限，训练过程中出现了空间不足的问题。为了让程序继续运行，小红必须从当前的 n 个候选项中挑选出一部分张量进行清理，以释放至少 m 单位的显存空间。

对于每一个张量，小红有两种处理方式：第一种是将其临时交换到系统内存中，第二种是直接将其删除并在未来需要时重新计算。这两种方式各自对应一个成本值。小红非常聪明，对于每一个被决定清理的张量，她都会从这两种方式中选择成本更低的一种来执行。

请你帮小红计算一下，在保证释放的空间总量不少于 m 的前提下，清理这些张量所需要的最小总成本是多少？

## 输入格式

第一行包含一个整数 m（0 < m < 10000），表示小红需要释放的最少存储空间。

第二行包含一个整数 n（0 < n < 10000），表示候选张量的数量。

第三行包含 n 个整数，表示每个张量所占据的空间大小，数值均在 $[1, 10^5]$ 范围内。

第四行包含 n 个整数，表示每个张量执行“交换”操作的成本，数值均在 $[1, 10^5]$ 范围内。

第五行包含 n 个整数，表示每个张量执行“重算”操作的成本，数值均在 $[1, 10^5]$ 范围内。

## 输出格式

输出一行，包含一个整数，代表满足要求的最小总成本。如果无论如何挑选都无法腾出至少 m 的空间，请输出字符串 error。

## 样例

### 样例 1

**输入：**
```
6
3
3 3 5
10 2 5
1 8 10
```

**输出：**
```
3
```

**说明：**
在该样例中，小红需要释放至少 6 单位空间：

张量 1：空间为 3，交换成本 10，重算成本 1。小红会选择较低的成本 1。

张量 2：空间为 3，交换成本 2，重算成本 8。小红会选择较低的成本 2。

张量 3：空间为 5，交换成本 5，重算成本 10。小红会选择较低的成本 5。

如果选择清理张量 1 和张量 2，总释放空间为 3+3=6，刚好满足要求，此时总成本为 1+2=3。这是所有方案中成本最低的。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97678455/detail?pid=66800409&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678455/detail?pid=66800409&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:14:26.338606+00:00', '2026-07-02T12:14:55.572864+00:00', 2000, 262144, 'Ai'),
	(54, '小红的智能语音分类器', '小红的智能语音分类器', '华为', 'Medium', 'graphs', '小红正在研发一款部署在智能音箱上的语音意图识别系统。该系统的核心逻辑是将用户输入的语音信号转化为一个三维特征向量，并通过比较该向量与已知样本库中向量的距离来进行分类。

具体而言，小红采用了 K 最近邻（KNN）算法。对于一个待识别的特征向量，系统会在样本库中寻找欧氏距离最近的 K 个已知样本。接着，系统会统计这 K 个样本所属的意图类别标签，并将出现频率最高的标签作为预测结果。如果存在多个类别标签的出现次数相同且均为最高，小红规定输出其中数值最小的那个标签。

题目保证在距离第 K 近的边界上不会出现多个样本距离相等而导致的歧义。

## 输入格式

第一行包含两个正整数 N 和 K，分别表示样本库中已知语音特征向量的数量，以及分类时需要参考的最近邻个数（$1 \leq K \leq N \leq 10^5$）。
接下来的 N 行，每行包含三个浮点数 x1, x2, x3 和一个整数 label。其中 (x1, x2, x3) 是特征向量在三维空间中的坐标（取值范围在 -1000.0 到 1000.0 之间），label 是该样本对应的意图类别标签（取值范围为 0 到 $10^4$ 之间的整数）。
最后一行包含三个浮点数，代表当前需要进行意图识别的目标语音特征向量坐标。

## 输出格式

输出一个整数，代表分类器预测出的意图类别标签。

## 样例

### 样例 1

**输入：**
```
4 3
0.0 0.0 0.0 10
1.0 1.0 1.0 20
0.0 1.0 0.0 10
10.0 10.0 10.0 30
0.1 0.1 0.1
```

**输出：**
```
10
```

**说明：**
目标特征向量为 (0.1, 0.1, 0.1)。计算它到样本库中四个点的欧氏距离，距离最近的三个样本分别是：

1. (0.0, 0.0, 0.0)，标签为 10；

2. (0.0, 1.0, 0.0)，标签为 10；

3. (1.0, 1.0, 1.0)，标签为 20。

在这三个最近邻中，标签 10 出现了 2 次，标签 20 出现了 1 次。因此，出现次数最多的标签是 10。

### 样例 2

**输入：**
```
10 3
0.5 0.3 0.4 0
0.6 0.2 0.5 0
0.4 0.3 0.3 0
0.7 0.4 0.6 0
2.1 2.3 2.2 1
2.3 2.2 2.4 1
2.2 2.4 2.3 1
4.5 4.3 4.4 2
4.4 4.5 4.6 2
4.6 4.4 4.5 2
2.2 2.1 2.3
```

**输出：**
```
1
```

**说明：**
The target feature vector is (2.2, 2.1, 2.3). Its squared Euclidean distances to the known vectors are calculated. The 3 nearest neighbors are (2.1, 2.3, 2.2) of category 1, (2.3, 2.2, 2.4) of category 1, and (2.2, 2.4, 2.3) of category 1. Since all 3 nearest neighbors belong to category 1, the target vector is classified as category 1.', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97678455/detail?pid=66800409&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97678455/detail?pid=66800409&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T12:14:26.389229+00:00', '2026-07-02T12:14:43.462656+00:00', 2000, 262144, 'Ai'),
	(84, '均衡版 KMeans 分群与新用户归类', '均衡版 KMeans 分群与新用户归类', '华为', 'Medium', 'hashing', '某电商平台需要把 N 位老客户按其 M 维非负整数特征划分为 K 个群组（2 ≤ K ≤ min(20, N)）。为避免资源倾斜，要求每个群组的容量严格均衡：每组人数为 N//K 或 N//K+1，多出来的人数依次补给“中心编号较小”的群组。你需要实现一个“按顺序分配 + 均衡容量 + 中心取整”的 KMeans 变体，并用最终的中心点将一个新客户归到最近的中心。

算法规则

1) 初始中心为输入的前 K 位客户的特征。

2) 每一轮分配按客户输入顺序从 1 到 N 顺序处理。对每个客户：

- 
计算其到每个中心的欧氏距离（可用“平方和”比较，无需开方）。

- 
在“尚未满员”的中心里选择距离最小者；若有距离并列，取中心编号更小的。

- 
每个中心的容量固定：前 N%K 个中心容量为 N//K+1，其余为 N//K。

3) 一轮分配完成后，更新每个中心为该组所有成员的逐维均值向下取整（floor）。

4) 若“本轮的分配结果和中心”与上一轮完全一致，则停止。

5) 输出时先将最终中心按字典序（先比第 1 维，再比第 2 维，依此类推）升序排序；随后给定新客户特征，计算他到“已排序中心”的距离，归到最近的中心；若有并列，选择字典序最小的中心。输出该中心在“排序后列表”中的序号（从 1 开始）。

## 输入格式

- 第 1 行：N M K
- 第 2 ~ N+1 行：每行 M 个非负整数，表示一位老客户的特征
- 第 N+2 行：M 个非负整数，表示新客户的特征

## 输出格式

- 先输出 K 行：排序后的 K 个中心（每行 M 个整数）
- 再输出 1 行：新客户所在中心在排序后列表中的序号（从 1 开始）

## 样例

### 样例 1

**输入：**
```
4 1 2
0
10
9
11
8
```

**输出：**
```
5
9
2
```

**说明：**
1.按“容量均衡 + 顺序分配”规则，4 个点分到两组容量各 2：{0,11} 与 {10,9}。 
2.组中心为各组均值下取整：{5,9}，再次分配不变，收敛。 
3.新点 8 到中心 5、9 的距离分别为 9 和 1，选 9，排序后位次为 2。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683632/detail?pid=65420941&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683632/detail?pid=65420941&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:59:34.376734+00:00', '2026-07-02T15:01:23.843939+00:00', 2000, 262144, 'Ai'),
	(78, '基于决策树的QAM调制符合检测', '基于决策树的QAM调制符合检测', '华为', 'Medium', 'binary-search', '用一小段带噪声的复数信号样本来训练一棵 CART 决策树，对16QAM符号进行分类判决。每个样本用两维实数特征表示：实部 x1 与虚部 x2；标签是整型类标（如0～15，对应16QAM的16个星座点）。

- 
划分标准：使用基尼系数（Gini）作为节点不纯度度量，选择加权 Gini 最小且左右子集均非空的划分。

- 
切分方式：只允许在特征 x1 或 x2 上，用固定阈值集合 {-3, -2, -1, 0, 1, 2, 3} 中的某个阈值 t 进行二分；样本按“特征值 < t 进左子集，否则进右子集”分配。

- 
叶子输出：叶子节点输出该节点内样本的多数类；若并列，取数值较小的标签，保证确定性。

- 
树深度：最大深度为 5（根深度计 1）。

- 
训练集整体 Gini：按训练集中各标签频率一次性计算并输出。

请在读入训练样本后，先输出训练集整体 Gini（四舍五入保留 4 位小数），再用训练好的树对给定测试点 (tx1, tx2) 进行预测并输出其标签。

约束与说明

- 
仅使用特征 x1、x2；阈值必须从 {-3, -2, -1, 0, 1, 2, 3} 中选择。

- 
每次划分两侧必须均非空；若所有候选划分都不能降低加权 Gini，或深度到限，则当前节点为叶子。

- 
并列多数类时取数值更小的类标。

## 输入格式

- 第 1 行：整数 M，表示训练样本数。
- 第 2～M+1 行：每行三个数 x1 x2 y（x1、x2 为实数，y 为整型类标）。
- 第 M+2 行：两个实数 tx1 tx2，表示测试样本的特征。

## 输出格式

- 第 1 行：训练集整体 Gini，四舍五入保留 4 位小数。
- 第 2 行：对测试样本的预测标签（整数）。

## 样例

### 样例 1

**输入：**
```
1
2.10 3.00 7
-0.50 1.20
```

**输出：**
```
0.0000
7
```

**说明：**
训练集中只有 1 条样本，其标签分布完全单一，训练集 Gini=0。
无法有效划分，根即叶，预测恒为 7。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683676/detail?pid=65176652&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683676/detail?pid=65176652&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:58:49.827297+00:00', '2026-07-02T15:02:51.786155+00:00', 2000, 262144, 'Ai'),
	(71, '实体匹配结果归并与排序', '实体匹配结果归并与排序', '华为', 'Medium', 'hashing', '在数据治理平台中，不同的实体匹配引擎会各自产出“被认为指向同一真实实体”的编号集合。每一行输入代表某个引擎得到的一组编号（集合），行内的编号可能有重复。若两组集合存在至少一个公共编号，则它们应当被视作同一簇，需合并为一个更大的集合。请你将所有集合按上述规则进行传递式合并与去重，并按指定顺序输出。

编号仅由数字字符构成（如“1”“23”“0005”），每行不超过100个编号，总不同编号数不超过100000，匹配系统行数 N 在 1 到 10000 之间。

排序规则

- 行内排序：将一个合并后的集合中的编号按字典序（字符串比较）升序排列后输出为一行，编号之间用单个空格分隔。

- 行间排序：将所有行作为“编号有序序列”，按字典序（逐个编号从左到右比较，若一行是另一行的前缀，则较短者更小）升序排列后输出。

## 输入格式

第1行：整数 N，表示有 N 行匹配结果。
接下来的 N 行：每行是若干个用空格分隔的数字字符串，表示该系统判定为“同一实体”的编号集合。行内可能出现重复编号。

## 输出格式

输出 M 行（M ≤ N）。每一行是一组经传递式合并与去重后的编号序列，满足“行内字典序、行间字典序”的排序要求。

## 样例

### 样例 1

**输入：**
```
6
10 20
30 40
500
7 7 8 9
1
9 11
```

**输出：**
```
1
10 20
11 7 8 9
30 40
500
```

**说明：**
解释如下（按“字符串字典序”进行排序）：

- 合并关系

- 第4行“7 7 8 9”和第6行“9 11”因共同包含“9”，属于同一簇，合并为集合{7,8,9,11}，并去重。

- 行内排序（字符串字典序）

- 合并后的集合按字符串排序为“11 7 8 9”（因为“11”作为字符串小于“7”“8”“9”）。
- 其余行分别为：“10 20”“30 40”“500”“1”。

- 行间排序（按整行序列的字典序进行比较）

- 比较每行的第一个编号，得到整体顺序：
1
10 20
11 7 8 9
30 40
500', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686016/detail?pid=64953001&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686016/detail?pid=64953001&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:57:48.312029+00:00', '2026-07-02T15:04:31.885629+00:00', 2000, 262144, 'Ai'),
	(81, 'Vit中的patch embedding', 'Vit中的patch embedding', '华为', 'Medium', 'hashing', 'Vision Transformer 中，输入图像被切成等大的小块（patch），每个 patch 线性映射到 embedding，前面再加一个“分类 token”。已知图像边长 img_size、patch 边长 patch_size、通道数 channels、embedding 维度 embedding_dim。计算并输出 patch embedding 的形状：

- 
token_count = (img_size / patch_size)² + 1（含分类 token）

- 
输出两列：token_count 和 embedding_dim

说明：保证 img_size 可以被 patch_size 整除；不得使用任何深度学习框架。

## 输入格式

一行四个整数：img_size patch_size channels embedding_dim

## 输出格式

一行两个整数：token_count embedding_dim

## 样例

### 样例 1

**输入：**
```
384 32 3 512
```

**输出：**
```
145 512
```

**说明：**
384/32=12，每边 12 个 patch，共 12×12=144，加上分类 token 得 145，embedding 维度保持 512。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686290/detail?pid=65355595&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686290/detail?pid=65355595&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:59:19.491498+00:00', '2026-07-02T15:02:11.864138+00:00', 2000, 262144, 'Ai'),
	(202, '链表中倒数最后k个结点', '链表中倒数最后k个结点', '牛客', 'Easy', 'linked-list', '输入一个长度为 n 的链表，设链表中的元素的值为 ai ，返回该链表中倒数第k个节点。 
如果该链表长度小于k，请返回一个长度为 0 的链表。 

数据范围：$0 \leq n \leq 10^5$，$0 \leq a_i \leq 10^9$，$0 \leq k \leq 10^9$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

例如输入{1,2,3,4,5},2时，对应的链表结构如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211105/423483716_1636084313645/5407F55227804F31F5C5D73558596F2C)

其中蓝色部分为该链表的最后2个结点，所以返回倒数第2个结点（也即结点值为4的结点）即可，系统会打印后面所有的节点来比较。

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,2,3,4,5},2
```

**输出：**
```
{4,5}
```

**说明：**
返回倒数第2个节点4，系统会打印后面所有的节点来比较。

### 样例 2

**输入：**
```
{2},8
```

**输出：**
```
{}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/886370fe658f41b498d40fb34ae76ff9?tpId=295&tqId=1377477&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/886370fe658f41b498d40fb34ae76ff9?tpId=295&tqId=1377477&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.394956+00:00', '2026-07-03T12:12:30.707136+00:00', 2000, 262144, '常见101'),
	(67, 'DBSCAN聚类', 'DBSCAN聚类', '华为', 'Medium', 'simulation', '- 
任务: 用DBSCAN在二维或三维实数坐标上做聚类，输出“簇的数量”和“噪声点数量”。

- 
定义: 距离为欧氏距离；某点的邻域半径为eps；若该点邻域内样本数（含自身）≥ min_samples，则为核心点；从未访问核心点出发，按邻域可达关系扩展一个簇；不被任何簇吸收的点视为噪声

## 输入格式

- 第一行: eps min_samples x
- 接下来x行: 每行2个或3个实数（同一测试仅一种维度）

## 输出格式

- 一行: 簇数 噪声点数

## 样例

### 样例 1

**输入：**
```
1.5 2 6
0 0
0.5 0
0 0.5
10 10
10.5 10
10 10.5
```

**输出：**
```
2 0
```

**说明：**
前3个点彼此间距都≤1.5，形成一簇；后3个点同理形成另一簇；无噪声。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683645/detail?pid=64590239&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683645/detail?pid=64590239&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T14:57:09.195821+00:00', '2026-07-02T15:05:20.719830+00:00', 2000, 262144, 'Ai'),
	(91, '加速优化问题', '加速优化问题', '华为', 'Medium', 'simulation', '某物流公司需要为一条运输线路上的多个中转段选择运输方案。整条线路由若干个中转段组成，每个中转段可以选择不同的运输方式（如空运、陆运等），不同方式的运费和延误风险各不相同。

公司的目标是在保证总延误风险不超过给定阈值的前提下，使得整条线路的总运费最低。

具体条件如下：每个中转段在不同运输方式下有各自的延误风险值（浮点数）和运费（浮点数）。每个中转段必须且只能选择一种运输方式。所有中转段的延误风险之和不能超过阈值 T。

请设计算法，为每个中转段选择最优的运输方式，使得总运费最小且满足总延误风险不超过 T。

## 输入格式

第一行：整数 L（中转段数量）和浮点数 T（延误风险阈值）。
接下来 L 行，每行描述一个中转段的可选方案：先是一个整数 K（该中转段可选的运输方式数量），随后是 K 组数据，每组包含：方式名称（字符串）、延误风险（浮点数）、运费（浮点数）。

## 输出格式

输出最优总运费（保留两位小数）。

## 样例

### 样例 1

**输入：**
```
2 0.4
2 express 0.1 300.0 standard 0.25 120.0
2 express 0.05 250.0 standard 0.2 100.0
```

**输出：**
```
370.00
```

**说明：**
2 个中转段，延误风险阈值为 0.4。
枚举所有组合：
(1) express+express：风险 0.1+0.05=0.15，运费 300+250=550
(2) express+standard：风险 0.1+0.2=0.3，运费 300+100=400
(3) standard+express：风险 0.25+0.05=0.3，运费 120+250=370
(4) standard+standard：风险 0.25+0.2=0.45 > 0.4，不可行
满足约束的方案中，最小运费为方案(3)的 370。

### 样例 2

**输入：**
```
3 0.5
1 ground 0.15 80.0
2 air 0.1 200.0 ground 0.3 90.0
2 air 0.05 180.0 ground 0.2 70.0
```

**输出：**
```
350.00
```

**说明：**
3 个中转段，延误风险阈值为 0.5。第一段只有 ground 可选（风险 0.15，运费 80）。
可行方案：
(1) ground+ground+air：风险 0.15+0.3+0.05=0.5，运费 80+90+180=350
(2) ground+air+ground：风险 0.15+0.1+0.2=0.45，运费 80+200+70=350
(3) ground+air+air：风险 0.15+0.1+0.05=0.3，运费 80+200+180=460
ground+ground+ground 风险 0.65 超出阈值，不可行。
最小运费为 350。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686537/detail?pid=66224894&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686537/detail?pid=66224894&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:07:12.045475+00:00', '2026-07-02T15:09:40.263214+00:00', 2000, 262144, 'Ai'),
	(90, '对称INT8量化方案', '对称INT8量化方案', '华为', 'Medium', 'matrix-grid', '在嵌入式设备上运行神经网络推理时，由于硬件资源有限，通常需要将浮点参数压缩为低比特整数表示，以减少存储开销和加速计算。

本题要求你实现一种对称INT8量化方案，分别对激活矩阵 A 和参数矩阵 B 进行量化，然后在整数域完成矩阵乘法，最后还原为浮点结果并输出。

具体规则如下： 

1. 原始矩阵
激活矩阵 A 的维度为 M*K，其中每一行代表一个样本向量。参数矩阵 B 的维度为 K*N，其中每一列代表一个输出通道。 

2. 量化过程 

(1) 对激活矩阵 A 按行量化（per-sample）
对第 i 行，先计算缩放因子： $s_A^{(i)} = \frac{\max_{k \in [1,K]} |A_{i,k}|}{127}$ 再对每个元素量化： $Q_A^{(i,k)} = \text{clip}\left(\text{round}\left(\frac{A_{i,k}}{s_A^{(i)}}\right), -127, 127\right)$ 

(2) 对参数矩阵 B 按列量化（per-channel）
对第 j 列，先计算缩放因子： $s_B^{(j)} = \frac{\max_{k \in [1,K]} |B_{k,j}|}{127}$ 再对每个元素量化： $Q_B^{(k,j)} = \text{clip}\left(\text{round}\left(\frac{B_{k,j}}{s_B^{(j)}}\right), -127, 127\right)$ 

注意： 

round 采用 Python round() 的逻辑，即银行家舍入（四舍六入五取偶）。

非 0.5 的情况遵循常规四舍五入；恰好 0.5 时舍入到最接近的偶数。
- clip(x, -127, 127) 将 x 限制在 [-127, 127] 范围内。 

3. 量化矩阵乘法
先在整数域计算乘积（结果为INT32）： $Y_{\text{int32}}^{(i,j)} = \sum_{k=1}^{K} Q_A^{(i,k)} \cdot Q_B^{(k,j)}$ 然后乘以对应的缩放因子还原为浮点数： $Y_{\text{fp32}}^{(i,j)} = Y_{\text{int32}}^{(i,j)} \cdot s_A^{(i)} \cdot s_B^{(j)}$

## 输入格式

从标准输入读取，依次给出矩阵 A 和矩阵 B。

对于每个矩阵，第一行为两个整数表示行数和列数，随后若干行为矩阵元素（浮点数），同一行内元素以空格分隔。

## 输出格式

输出还原后的浮点结果矩阵，每个元素四舍五入保留两位小数（建议使用 Python 的 format(num, ''.2f'') 处理）。同一行内元素以单个空格分隔，行首行尾不要有多余空格。

## 样例

### 样例 1

**输入：**
```
1 3
2.0 -1.0 3.0
3 1
1.0
-2.0
0.5
```

**输出：**
```
5.52
```

**说明：**
激活矩阵 A 为 1*3 矩阵 [2.0, -1.0, 3.0]，参数矩阵 B 为 3*1 矩阵 [[1.0], [-2.0], [0.5]]。

对 A 按行量化：该行绝对值最大为 3.0，缩放因子 s_A = 3.0/127。量化后 Q_A = [round(84.67), round(-42.33), round(127.0)] = [85, -42, 127]。

对 B 按列量化：该列绝对值最大为 2.0，缩放因子 s_B = 2.0/127。量化后 Q_B = [round(63.5), round(-127.0), round(31.75)] = [64, -127, 32]。注意 round(63.5) = 64（银行家舍入，取偶数）。

整数域乘法：Y_int32 = 85*64 + (-42)*(-127) + 127*32 = 5440 + 5334 + 4064 = 14838。

还原：Y_fp32 = 14838 * (3.0/127) * (2.0/127) = 5.52（四舍五入到两位小数）。

### 样例 2

**输入：**
```
3 2
10.0 -5.0
0.0 8.0
-3.0 -3.0
2 2
4.0 -6.0
2.0 7.0
```

**输出：**
```
29.84 -95.35
16.13 56.00
-18.05 -2.98
```

**说明：**
A 有3个样本向量，B 有2个输出通道。对 A 逐行、对 B 逐列分别计算缩放因子和量化值，在整数域完成矩阵乘法后，乘以对应的行缩放因子和列缩放因子还原为浮点数。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686553/detail?pid=66224888&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686553/detail?pid=66224888&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:06:54.534240+00:00', '2026-07-02T15:09:54.058778+00:00', 2000, 262144, 'Ai'),
	(203, '删除链表的倒数第n个节点', '删除链表的倒数第n个节点', '牛客', 'Medium', 'linked-list', '给定一个链表，删除链表的倒数第 n 个节点并返回链表的头指针
例如， 
给出的链表为: $1\to 2\to 3\to 4\to 5$, $n= 2$.
删除了链表的倒数第 $n$ 个节点之后,链表变为$1\to 2\to 3\to 5$. 

数据范围： 链表长度 $0\le n \le 1000$，链表中任意节点的值满足 $0 \le val \le 100$ 
要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$
备注： 
题目保证 $n$ 一定是有效的

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2},2
```

**输出：**
```
{2}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/f95dcdafbde44b22a6d741baf71653f6?tpId=295&tqId=727&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/f95dcdafbde44b22a6d741baf71653f6?tpId=295&tqId=727&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.445730+00:00', '2026-07-03T12:12:17.395031+00:00', 2000, 262144, '常见101'),
	(93, '用户分群', '用户分群', '华为', 'Medium', 'simulation', '某电商平台希望根据用户的购物行为对用户进行分群，以便制定差异化的运营策略。

每位用户有三个特征指标：
purchase_amount（月均消费金额）
visit_frequency（月均访问次数）
return_rate（退货率，已归一化）
你需要实现 KMeans 聚类算法，将用户划分为若干个群体。

KMeans 算法的流程如下：给定 K 个初始聚类中心，计算每个数据点到各聚类中心的欧氏距离，将数据点分配到距离最近的聚类中心所在的组。然后对每个组重新计算中心点（即该组内所有数据点各维度的算术平均值），完成一轮迭代。
重复上述过程指定的迭代次数后，输出最终的 K 个聚类中心，每个维度的值保留两位小数（四舍五入）。 

欧氏距离的计算公式为： $d=\sqrt{(x_1-x_2)^2+(y_1-y_2)^2+(z_1-z_2)^2}$

## 输入格式

第一行一个正整数 K，表示聚类中心的个数。
接下来 K 行，每行三个浮点数，表示初始聚类中心的三个特征值。
下一行一个正整数，表示迭代次数。
下一行一个正整数 m，表示数据点的个数。
接下来 m 行，每行三个浮点数，表示一个数据点的三个特征值。

## 输出格式

输出 K 行，每行三个数值，表示迭代结束后各聚类中心的三个特征值，保留两位小数，四舍五入。

## 样例

### 样例 1

**输入：**
```
2
10 20 30
40 50 60
2
6
8 18 25
12 22 35
42 48 58
38 52 62
45 55 65
5 15 28
```

**输出：**
```
8.33 18.33 29.33
41.67 51.67 61.67
```

**说明：**
初始中心为 [10,20,30] 和 [40,50,60]，共 6 个数据点，迭代 2 次。
第 1 轮：前三个点 (8,18,25)、(12,22,35)、(5,15,28) 距离中心 [10,20,30] 更近，分到第一组；后三个点 (42,48,58)、(38,52,62)、(45,55,65) 距离中心 [40,50,60] 更近，分到第二组。更新中心为 [8.33,18.33,29.33] 和 [41.67,51.67,61.67]。
第 2 轮：分配结果不变，中心保持不变。

### 样例 2

**输入：**
```
3
5 5 5
15 15 15
25 25 25
1
4
4 4 4
6 6 6
14 16 14
26 24 26
```

**输出：**
```
5.00 5.00 5.00
14.00 16.00 14.00
26.00 24.00 26.00
```

**说明：**
初始中心为 [5,5,5]、[15,15,15]、[25,25,25]，共 4 个点，迭代 1 次。
(4,4,4) 和 (6,6,6) 距离中心 [5,5,5] 最近，分到第一组，新中心为 [(4+6)/2,(4+6)/2,(4+6)/2]=[5,5,5]。
(14,16,14) 距离中心 [15,15,15] 最近，分到第二组，新中心为 [14,16,14]。
(26,24,26) 距离中心 [25,25,25] 最近，分到第三组，新中心为 [26,24,26]。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686503/detail?pid=66224898&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686503/detail?pid=66224898&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:07:26.504746+00:00', '2026-07-02T15:09:17.833181+00:00', 2000, 262144, 'Ai'),
	(96, '小红的告警树诊断', '小红的告警树诊断', '华为', 'Medium', 'tree', '小红正在给一套智能运维平台做故障诊断模块。平台会持续收到交换机和路由器上报的多项运行指标，例如 CPU 使用率、内存占用、丢包率和温度等。

为了让规则学习过程更统一，小红会先把每个连续值指标转成二值告警信号：如果该指标值小于对应阈值，则记为 0；如果该指标值大于等于对应阈值，则记为 1。

在完成这一步之后，每条训练样本都会变成一个只包含 0/1 特征的告警向量，再配合样本标签（0 表示正常，1 表示故障）用于训练一棵 ID3 决策树。

构建决策树时，设当前样本集合为 D，其信息熵为 H(D) = -sum(p_i * log2(p_i))，其中 p_i 表示第 i 类样本在集合 D 中所占的比例。

对于某个尚未使用过的特征 A，它在当前节点上的信息增益定义为 Gain(D, A) = H(D) - sum((|D_v| / |D|) * H(D_v))，其中 D_v 表示特征 A 取值为 v 的样本子集。

决策树的构建规则如下：先把所有训练样本按给定阈值离散化成 0/1 特征；如果当前节点样本标签已经完全相同，则该节点直接成为叶子；否则，从当前还未使用的特征中选择信息增益最大的那个作为划分特征；如果有多个特征的信息增益相同，则选择下标更小的特征；对于某个分支，如果继续划分时没有可用特征，或者该分支样本无法再继续有效区分，则该节点输出当前样本集合中的多数类；如果两类数量相同，则输出 0。

预测新样本时，先按同样阈值离散化，再沿决策树向下走到叶子并输出预测类别。

请你输出所有待预测样本的分类结果。

## 输入格式

第一行包含两个整数 N 和 M，分别表示训练样本数量和特征数量，满足 1 <= N <= 10^3，1 <= M <= 20。

第二行包含 M 个浮点数，表示每个特征各自对应的告警阈值。

接下来 N 行，每行包含 M+1 个数。前 M 个为该训练样本的原始特征值，最后一个为标签，标签只会是 0 或 1。

下一行包含一个整数 q，表示待预测样本数量，满足 1 <= q <= 10^3。

接下来 q 行，每行包含 M 个原始特征值，表示一个需要预测的新样本。

## 输出格式

输出一行，包含 q 个整数，表示这 q 个待测样本的预测类别，类别之间用空格分隔。

## 样例

### 样例 1

**输入：**
```
6 3
50.0 60.0 70.0
40.0 55.0 65.0 0
55.0 58.0 90.0 1
52.0 80.0 72.0 1
30.0 50.0 60.0 0
75.0 40.0 85.0 1
35.0 75.0 50.0 0
3
45.0 65.0 68.0
70.0 50.0 75.0
60.0 85.0 90.0
```

**输出：**
```
0 1 1
```

**说明：**
先按阈值把训练样本转成二值特征，例如第一条会变成 0 0 0，第二条会变成 1 0 1。在这组数据里，第三个特征最先把两类样本区分开，因此三个待测样本的预测结果依次为 0、1、1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686076/detail?pid=67115759&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686076/detail?pid=67115759&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:07:40.935505+00:00', '2026-07-02T15:08:45.479260+00:00', 2000, 262144, 'Ai'),
	(95, '小红的示例检索重排', '小红的示例检索重排', '华为', 'Medium', 'matrix-grid', '小红正在调试一个智能学习助手。这个系统会先从知识库里召回一批候选示例，再从中挑出若干条最适合展示给用户的结果。

如果系统只按“和当前问题有多相关”来排序，往往会返回许多内容非常接近的示例。为了让结果既相关又有区分度，小红决定使用最大边际相关性（MMR）策略做二次重排。

现在一共有 N 个候选文档。第 i 个文档有一个互不相同的文档编号 ID，还给出了它和当前查询的相关性分数 rel[i]。此外，系统还知道任意两个候选文档之间的相似度 sim[i][j]。

小红会维护一个已经选中的文档集合 S，初始时它为空。随后重复执行 K 轮，每一轮都要在还没被选过的文档里，计算当前的 MMR 分数：

MMR(i) = λ * rel[i] - (1 - λ) * max(sim[i][j])，其中 j 来自集合 S。

如果当前 S 为空，那么上式中的最大相似度部分按 0 处理。

每一轮都选出当前 MMR 分数最高的那个文档加入集合 S，并把它的文档编号按顺序记入答案中。如果有多个文档在这一轮的 MMR 分数完全相同，则选择文档编号较小的那个。

请你输出这 K 轮依次选中的文档编号。

## 输入格式

第一行一个整数 N，表示候选文档数量，满足 1 <= N <= 1000。

接下来 N 行，每行包含一个浮点数 rel 和一个整数 ID，表示按输入顺序编号的第 i 个候选文档的相关性分数和文档编号。所有文档编号互不相同，且在 1 到 10^9 之间。相关性分数在 [0,1] 范围内。

接下来 N 行，每行包含 N 个浮点数，构成相似度矩阵 sim。其中第 i 行第 j 列表示文档 i 和文档 j 的相似度。题目保证矩阵对称，且 sim[i][i] = 1.00。所有相似度都在 [0,1] 范围内，并精确到小数点后两位。

最后一行包含一个浮点数 λ 和一个整数 K，其中 0 <= λ <= 1，0 <= K <= N。

## 输出格式

输出一行，包含 K 个整数，表示按选择顺序得到的文档编号，编号之间用空格分隔。

如果 K = 0，输出一个空行即可。

## 样例

### 样例 1

**输入：**
```
4
0.80 11
0.75 7
0.60 30
0.50 25
1.00 0.90 0.20 0.10
0.90 1.00 0.30 0.20
0.20 0.30 1.00 0.80
0.10 0.20 0.80 1.00
0.6 3
```

**输出：**
```
11 30 7
```

**说明：**
第一轮集合为空，只看 0.6 * rel，文档 11 最高。第二轮开始要扣掉与已选文档的最大相似度，文档 30 与 11 的相似度更低，因此先被选出。第三轮继续比较后，得到顺序 11 30 7。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686076/detail?pid=67115759&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686076/detail?pid=67115759&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:07:40.888665+00:00', '2026-07-02T15:08:55.939971+00:00', 2000, 262144, 'Ai'),
	(92, '关闭工位', '关闭工位', '华为', 'Medium', 'simulation', '某工厂的流水线上有 T 个工位，产品依次经过每个工位进行加工。为了降低能耗，工厂决定关闭其中 k 个工位，让产品直接跳过这些工位。工程师发现，当某个工位被关闭时，产品会因为缺少该环节的加工而产生一定的质量偏差。

具体来说，用一个长度为 T-1 的偏差值列表来描述关闭每个工位的影响：列表中第 t 个元素（0<=t<T-1，从0开始编号）表示关闭第 t+1 号工位后，产品所增加的质量偏差值。

但是，连续两个相邻工位不能同时关闭，否则产品的结构完整性无法保证。请你设计一个方案，在满足约束的前提下恰好关闭 k 个工位，使得总质量偏差最小。如果无法找到满足条件的关闭方案，则输出 -1。

## 输入格式

第一行一个正整数 T，表示流水线上的工位总数（1<T<=1000）。
第二行一个非负整数 k，表示需要关闭的工位数（0<=k<T）。
第三行 T-1 个正整数，以空格分隔，表示关闭对应工位后所增加的质量偏差值，每个值均为小于 1000 的正整数。

## 输出格式

输出一个整数。如果存在合法的关闭方案，输出最小的总质量偏差值；否则输出 -1。

## 样例

### 样例 1

**输入：**
```
5
2
3 1 4 2
```

**输出：**
```
3
```

**说明：**
共 5 个工位，需要关闭 2 个，偏差列表为 [3, 1, 4, 2]。最优方案是关闭第 2 号和第 4 号工位（对应偏差值 1 和 2），总偏差为 1+2=3。注意不能同时关闭第 1 号和第 2 号（相邻），也不能同时关闭第 3 号和第 4 号（相邻）。

### 样例 2

**输入：**
```
4
3
5 8 3
```

**输出：**
```
-1
```

**说明：**
共 4 个工位，偏差列表长度为 3，最多只能关闭 2 个不相邻的工位（例如第 1 号和第 3 号），无法关闭 3 个不相邻的工位，因此输出 -1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686537/detail?pid=66224894&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686537/detail?pid=66224894&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:07:12.105358+00:00', '2026-07-02T15:09:28.429821+00:00', 2000, 262144, 'Ai'),
	(89, '连续子序列', '连续子序列', '华为', 'Medium', 'sliding-window', '在网络安全日志分析系统中，每台服务器每秒会产生一条由字母和数字组成的事件编码。安全分析师发现，当连续一段时间内的事件编码序列中没有出现重复的编码字符时，这段时间内的日志可以被认为是"独立事件窗口"，有助于精确定位异常行为。窗口越长，说明系统在该时段内产生的事件种类越丰富，分析价值越高。

现在给你一条完整的事件编码序列 s，请你找到其中最长的一段连续子序列，使得这段子序列中每个字符都不相同，并输出该子序列的长度。

## 输入格式

一行，一个字符串 s，仅由 ASCII 字母和数字组成，不含空格。字符串长度为 n (1 <= n <= 10^7)。

## 输出格式

一个整数，表示 s 中最长的不含重复字符的连续子串的长度。

## 样例

### 样例 1

**输入：**
```
xY3abxY3c
```

**输出：**
```
6
```

**说明：**
最长的无重复字符子串为 "abxY3c"（从第4个字符到第9个字符），长度为6。其中每个字符 a, b, x, Y, 3, c 都只出现了一次。

### 样例 2

**输入：**
```
aaaaaaa
```

**输出：**
```
1
```

**说明：**
所有字符都相同，任意长度大于1的子串都包含重复字符，因此最长无重复子串长度为1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686553/detail?pid=66224888&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686553/detail?pid=66224888&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:06:54.433245+00:00', '2026-07-02T15:10:05.938773+00:00', 2000, 262144, 'Ai'),
	(100, '探索宇宙中的星系联盟', '探索宇宙中的星系联盟', '华为', 'Medium', 'graphs', '在浩瀚无垠的宇宙中，散布着无数的星系。一部分星系之间通过稳定的“星际航道”紧密相连，形成一个个“星系联盟”。在本题的设定里，一个星系联盟由一个或多个通过星际航道直接或间接相连的星系构成，这在图论中被称为一个 无向图的连通分量 。

每个星系都拥有一个独一无二的“文明等级”，这是一个正整数，代表了该星系文明的繁荣程度。而一个星系联盟的总实力，则定义为该联盟内所有星系文明等级之和。

现在，作为星际探险家的您，得到了一份星图。这份星图包含了各个星系的文明等级信息，以及它们之间的星际航道连接情况。您的任务是：

1. 分析这份星图，找出其中所有独立的星系联盟。

2. 计算每个星系联盟的总实力。

3. 在所有联盟中，找到总实力最强的那一个。

4. 最终，请报告这个最强联盟中，文明等级最高的那个星系的名称，以及该联盟的总实力。

## 输入格式

输入数据描述了一张包含 $n$ 个星系和 $m$ 条星际航道的星图。

- 第一行是一个整数 $n$，代表星系的总数。$n$ 的取值范围为 $[1, 160]$。
- 接下来 $n$ 行，每行描述一个星系。格式为 `星系名称 文明等级`。
- `星系名称` 是一个长度不超过 $32$ 的字符串，仅由小写字母和数字组成。
- `文明等级` 是一个整数，其取值范围为 $[1, 10000]$。
- 之后的一行是一个整数 $m$，代表星际航道的总数。$m$ 的取值范围为 $[0, 160]$。
- 随后的 $m$ 行，每行描述一条星际航道，格式为 `星系A名称 星系B名称`，表示星系 $A$ 与星系 $B$ 之间存在一条双向航道。输入保证这里出现的星系名称都已在前文中定义过。
- 特别地，当 $m=0$ 时，表示星系之间没有任何航道，每个星系都是一个独立的联盟。

## 输出格式

请输出一行，包含两项内容，以空格隔开：在总实力最强的星系联盟中，文明等级最高的星系的名称，以及该联盟的总实力。

题目保证所有星系的文明等级各不相同，并且总实力最强的星系联盟是唯一的。

## 样例

### 样例 1

**输入：**
```
10
21hjdgv0vj 6587
3j82e2tmk2 7928
43hhi7u8f8 6659
80htg9ud23 6957
8b96bgxl55 8524
bf98w33f47 8692
i1b09lbu79 5801
nuy3c55lzm 9341
r371vsjr84 7467
wj7x829uc1 2438
8
3j82e2tmk2 80htg9ud23
43hhi7u8f8 80htg9ud23
43hhi7u8f8 bf98w33f47
43hhi7u8f8 r371vsjr84
80htg9ud23 r371vsjr84
8b96bgxl55 wj7x829uc1
i1b09lbu79 nuy3c55lzm
i1b09lbu79 r371vsjr84
```

**输出：**
```
nuy3c55lzm 52845
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683691/detail?pid=63699019&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683691/detail?pid=63699019&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.111020+00:00', '2026-07-02T15:27:32.150667+00:00', 2000, 262144, '开发'),
	(99, '魔理沙的魔导书收纳', '魔理沙的魔导书收纳', '华为', 'Medium', 'graphs', '雾雨魔理沙正在帕秋莉的图书馆中“借”阅魔导书。魔理沙初始拥有 $E$ 点魔力值，她面前依次排列着 $n$ 本被魔法结界保护的魔导书。

对于第 $i$ 本魔导书，魔理沙可以选择挑战结界或直接跳过。

1. 挑战结界：只有当魔理沙当前的魔力值严格大于该结界消耗值 $a_i$ 时，才能挑战成功。挑战成功后，她的魔力值会减少 $a_i$，但随后会从魔导书中吸收 $b_i$ 点魔力反馈。即：魔力值变为 $current - a_i + b_i$。

2. 跳过：魔理沙不挑战该结界，直接前往下一本书，魔力值保持不变。

魔理沙希望在保证挑战过程中魔力值始终不为负数的情况下，尽可能多地收纳魔导书。请你计算她最多能成功挑战多少个结界。

## 输入格式

第一行输入一个整数 $E$ ($1 \leqq E \leqq 10^9$)，代表魔理沙的初始魔力值。 

第二行输入若干个由空格分隔的整数 $a_i$ ($1 \leqq a_i \leqq 10^9$)，代表每本魔导书的结界消耗值。 

第三行输入若干个由空格分隔的整数 $b_i$ ($1 \leqq b_i \leqq 10^9$)，代表挑战成功后的魔力反馈值。

两行数组的元素个数相同，设其长度为 $n$ ($1 \leqq n \leqq 100$)。

## 输出格式

输出一个整数，表示魔理沙最多能成功挑战的结界数量。

## 样例

### 样例 1

**输入：**
```
18
15 17 4 18
1 15 4 17
```

**输出：**
```
2
```

**说明：**
- 魔理沙初始魔力为 $18$。

- 跳过第 1 本书（消耗 15，反馈 1），魔力仍为 $18$。

- 挑战第 2 本书：当前魔力 $18 > 17$，挑战成功。魔力变为 $18 - 17 + 15 = 16$。

- 挑战第 3 本书：当前魔力 $16 > 4$，挑战成功。魔力变为 $16 - 4 + 4 = 16$。

- 第 4 本书消耗为 $18$，当前魔力 $16 \leqq 18$，无法挑战，只能跳过。

- 最终成功挑战的数量为 2。其他方案均无法超过 2。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686270/detail?pid=67103538&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686270/detail?pid=67103538&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.060554+00:00', '2026-07-02T15:27:50.865911+00:00', 2000, 262144, '开发'),
	(98, '红魔馆的走廊清理', '红魔馆的走廊清理', '华为', 'Medium', 'matrix-grid', '十六夜咲夜正准备为蕾米莉亚大小姐端上红茶。红魔馆的走廊可以看作一个 $m$ 行 $n$ 列的网格图。由于大小姐对红茶的平稳度有极高的要求，咲夜在移动时必须遵循极其严格的规则：她只能向右或向下移动。

走廊的每个格点 $(i, j)$ 可能放置了不同的物件。具体定义如下：

- 若格点数值为 $0$，表示该处为空旷的走廊，可以通行。

- 若格点数值为 $1, 2, 3, 4$ 中的任意一种，分别代表家具、电源、孔洞或地线，这些均被视为障碍物，无法通行。

咲夜需要从左上角的厨房 $(0, 0)$ 出发，到达右下角的大小姐房间 $(m-1, n-1)$。为了保证红茶不溢出，她希望在移动过程中尽可能减少转向的次数。所谓“转向”，是指移动方向从“向右”变为“向下”，或从“向下”变为“向右”。

请你计算在保证只经过数值为 $0$ 的格点，且仅向右或向下移动的前提下，从起点到终点所需的最少转向次数。

## 输入格式

输入包含一个测试用例。

第一行包含两个整数 $m$ 和 $n$ ($0 < m, n \leqq 100$)，分别表示走廊的行数和列数。

若 $m$ 和 $n$ 在合法范围内，接下来将有 $m$ 行输入，每行包含 $n$ 个整数，代表网格中每个位置的数值 $p_{i,j}$ ($0 \leqq p_{i,j} \leqq 4$)。

特别地，如果 $m$ 或 $n$ 的取值范围不在 $(0, 100]$ 之内，则视为无效输入。

## 输出格式

输出一个整数，表示从 $(0, 0)$ 到 $(m-1, n-1)$ 所需的最少转向次数。

如果无法到达终点，或输入维度无效，请输出 $-1$。

## 样例

### 样例 1

**输入：**
```
3 3
0 1 0
0 0 0
2 0 0
```

**输出：**
```
2
```

**说明：**
样例中走廊为 $3 \times 3$ 的矩阵。其中 $(0, 1)$ 和 $(2, 0)$ 为障碍物。

从起点 $(0, 0)$ 到终点 $(2, 2)$ 存在以下两条路径：

1. $(0,0) \to (1,0) \to (1,1) \to (1,2) \to (2,2)$：

- 方向变化为：下 $\to$ 右（第 1 次转向）$\to$ 右 $\to$ 下（第 2 次转向）。共转向 2 次。

2. $(0,0) \to (1,0) \to (1,1) \to (2,1) \to (2,2)$：

- 方向变化为：下 $\to$ 右（第 1 次转向）$\to$ 下（第 2 次转向）$\to$ 右（第 3 次转向）。共转向 3 次。

因此，最少转向次数为 2。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686270/detail?pid=67103538&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686270/detail?pid=67103538&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.002586+00:00', '2026-07-02T15:28:05.487111+00:00', 2000, 262144, '开发'),
	(205, '链表相加(二)', '链表相加(二)', '牛客', 'Medium', 'linked-list', '假设链表中每一个节点的值都在 0 - 9 之间，那么链表整体就可以代表一个整数。 
给定两个这种链表，请生成代表两个整数相加值的结果链表。 
数据范围：$0 \le n,m \le 1000000$，链表任意值 $0 \le val \le 9$
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$

例如：链表 1 为 9->3->7，链表 2 为 6->3，最后生成新的结果链表为 1->0->0->0。 

![题面配图](https://uploadfiles.nowcoder.com/images/20211105/423483716_1636084743981/C2DB572B01B0FDC03C097BE7ABA45114)

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[9,3,7],[6,3]
```

**输出：**
```
{1,0,0,0}
```

**说明：**
如题面解释

### 样例 2

**输入：**
```
[0],[6,3]
```

**输出：**
```
{6,3}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c56f6c70fb3f4849bc56e33ff2a50b6b?tpId=295&tqId=1008772&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c56f6c70fb3f4849bc56e33ff2a50b6b?tpId=295&tqId=1008772&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.534849+00:00', '2026-07-03T12:11:52.682620+00:00', 2000, 262144, '常见101'),
	(230, '判断是不是平衡二叉树', '判断是不是平衡二叉树', '牛客', 'Easy', 'tree', '输入一棵节点数为 n 二叉树，判断该二叉树是否是平衡二叉树。 
在这里，我们只需要考虑其平衡性，不需要考虑其是不是排序二叉树 
平衡二叉树（Balanced Binary Tree），具有以下性质：它是一棵空树或它的左右两个子树的高度差的绝对值不超过1，并且左右两个子树都是一棵平衡二叉树。

样例解释： 

![题面配图](https://uploadfiles.nowcoder.com/images/20210918/382300087_1631935149594/D55A07912354B3AB7E9F2F5EA27CB7D6)

样例二叉树如图，为一颗平衡二叉树

注：我们约定空树是平衡二叉树。 

数据范围：$n \le 100$,树上节点的val值满足 $0 \le n \le 1000$ 
要求：空间复杂度$O(1)$，时间复杂度 $O(n)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,2,3,4,5,6,7}
```

**输出：**
```
true
```

### 样例 2

**输入：**
```
{}
```

**输出：**
```
true
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/8b3b95850edb4115918ecebdf1b4d222?tpId=295&tqId=23250&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/8b3b95850edb4115918ecebdf1b4d222?tpId=295&tqId=23250&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.940939+00:00', '2026-07-03T16:40:12.640284+00:00', 2000, 262144, '常见101'),
	(218, '二叉树的中序遍历', '二叉树的中序遍历', '牛客', 'Medium', 'tree', '给定一个二叉树的根节点root，返回它的中序遍历结果。

数据范围：树上节点数满足 $0 \le n \le 1000$，树上每个节点的值满足 $-1000 \le val \le 1000$

进阶：空间复杂度 $O(n)$，时间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,#,#,3}
```

**输出：**
```
[2,3,1]
```

### 样例 2

**输入：**
```
{}
```

**输出：**
```
[]
```

### 样例 3

**输入：**
```
{1,2}
```

**输出：**
```
[2,1]
```

### 样例 4

**输入：**
```
{1,#,2}
```

**输出：**
```
[1,2]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/0bf071c135e64ee2a027783b80bf781d?tpId=295&tqId=1512964&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/0bf071c135e64ee2a027783b80bf781d?tpId=295&tqId=1512964&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:31:22.083503+00:00', '2026-07-03T16:42:19.573671+00:00', 2000, 262144, '常见101'),
	(105, '术式终端的并行调度', '术式终端的并行调度', '华为', 'Medium', 'simulation', '小红正在术士协会的实训室里调试一套魔导调度系统。这套系统由若干台规格相同的核心服务器组成，每台服务器都拥有固定的 CPU 算力上限 $C$ 和内存容量上限 $M$。

小红手头共有 $n$ 个待运行的术式任务。对于第 $i$ 个任务，它需要消耗 $c_i$ 单位的算力、消耗 $m_i$ 单位的内存，并在运行成功后产生 $v_i$ 单位的术式价值。对于每一台独立的服务器，在其上运行的任务集合 $S$ 必须严格满足以下约束：

1. 任务的算力消耗总和不得超过服务器上限，即 $\sum_{i \in S} c_i \leqq C$。

2. 任务的内存消耗总和不得超过服务器上限，即 $\sum_{i \in S} m_i \leqq M$。

现在，小红希望分别计算：当她拥有 $1, 2, \dots, n$ 台服务器时，通过合理分配任务到各台服务器上，所能获得的任务总价值最大分别是多少？

## 输入格式

输入仅包含一组测试数据。

第一行包含三个整数 $n, C, M$ ($1 \leqq n \leqq 15, 1 \leqq C, M \leqq 10^6$)，分别代表任务的总数、单台服务器的 CPU 算力上限以及内存容量上限。

接下来 $n$ 行，每行包含三个整数 $c_i, m_i, v_i$ ($1 \leqq c_i, m_i, v_i \leqq 10^6$)，分别表示第 $i$ 个术式任务的算力需求、内存需求及产生的价值。

## 输出格式

输出共 $n$ 行。

第 $i$ 行（$1 \leqq i \leqq n$）输出一个整数，表示在使用 $i$ 台服务器的情况下，所能获得的最大任务总价值。

## 样例

### 样例 1

**输入：**
```
3 3 10
1 4 1
2 5 2
2 6 4
```

**输出：**
```
5
7
7
```

**说明：**
当拥有 $k=1$ 台服务器时：小红可以选择运行第 1 个和第 3 个任务。总算力消耗为 $1+2=3 \leqq 3$，总内存消耗为 $4+6=10 \leqq 10$，此时获得最大价值 $1+4=5$。

当拥有 $k=2$ 台服务器时：第一台服务器运行任务 1 和 3，第二台服务器运行任务 2。总价值为 $1+4+2=7$。

当拥有 $k=3$ 台服务器时：由于 2 台服务器已经可以运行全部任务，第 3 台服务器会保持空闲，最大价值仍为 7。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686037/detail?pid=66847171&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686037/detail?pid=66847171&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.379358+00:00', '2026-07-02T15:26:24.418167+00:00', 2000, 262144, '开发'),
	(104, '魔导模块的效能迭代', '魔导模块的效能迭代', '华为', 'Medium', 'simulation', '小红正在术式终端上维护一套由 $n$ 个魔导模块构成的核心系统。每个模块 $i$ 在运行时的执行耗时为 $a_i$。根据术士协会的规程，每个模块都有一个性能下限 $b_i$，即该模块的执行耗时无论如何优化都不能低于 $b_i$。

小红计划在接下来的 $m$ 天内，每天对其中一个模块进行一次效能迭代。如果选中的模块当前耗时为 $t$，经过一次迭代后，其新耗时将变为 $\max(\lceil t / 2 \rceil, b_i)$。其中 $\lceil x \rceil$ 表示对 $x$ 向上取整。

请问在 $m$ 天的优化结束后，所有模块的执行耗时之和最小是多少？

## 输入格式

第一行包含两个整数 $n$ 和 $m$ ($1 \leqq n \leqq 1000, 0 \leqq m \leqq 1000$)，分别表示模块的数量和优化的总天数。 

第二行包含 $n$ 个整数 $a_1, a_2, \dots, a_n$ ($1 \leqq a_i \leqq 10^5$)，表示各模块的初始执行耗时。 

第三行包含 $n$ 个整数 $b_1, b_2, \dots, b_n$ ($1 \leqq b_i \leqq a_i \leqq 10^5$)，表示各模块允许的执行耗时下限。

## 输出格式

输出一个整数，表示 $m$ 天后所有模块执行耗时之和的最小值。

## 样例

### 样例 1

**输入：**
```
2 3
100 80
40 10
```

**输出：**
```
70
```

**说明：**
在样例中，$n=2, m=3$：

- 第 1 天：优化模块 1，其耗时从 $100$ 变为 $\max(\lceil 100/2 \rceil, 40) = 50$。

- 第 2 天：优化模块 2，其耗时从 $80$ 变为 $\max(\lceil 80/2 \rceil, 10) = 40$。

- 第 3 天：再次优化模块 2，其耗时从 $40$ 变为 $\max(\lceil 40/2 \rceil, 10) = 20$。

最终各模块的耗时分别为 $50$ 和 $20$，总和为 $50 + 20 = 70$。此时总和达到最小。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686037/detail?pid=66847171&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686037/detail?pid=66847171&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.324692+00:00', '2026-07-02T15:26:36.855442+00:00', 2000, 262144, '开发'),
	(103, '魔导数据包的混合进制编码', '魔导数据包的混合进制编码', '华为', 'Medium', 'hashing', '小红正在术式终端前维护城市结界的能耗监控系统。为了压缩传输过程中的冗余数据，她需要对一个魔力值整数 $n$ 进行“混合进制编码”处理。

具体编码规程如下：

1. 符号位确定：首先根据 $n$ 的正负号确定编码序列的第一个数字 $s$。若 $n < 0$，则 $s = 1$；若 $n \geqq 0$，则 $s = 0$。

2. 进制分解：取 $q = |n|$（$n$ 的绝对值）。给定一个包含 $m$ 个正整数的进制序列 $b_1, b_2, \dots, b_m$。按照序列顺序，对 $q$ 依次进行如下操作：

对于每个 $b_i$，当前位的编码数字 $d_i = q \bmod b_i$，随后更新 $q = \lfloor q / b_i \rfloor$。

3. 字符映射：将得到的数字序列 $(s, d_1, d_2, \dots, d_m)$ 按顺序映射为小写字母，映射规则为 $0 \to \text{''a''}, 1 \to \text{''b''}, \dots, 25 \to \text{''z''}$。将这些字母拼接，得到最终的编码字符串 $S$。

4. 回文校验与提取：

- 若 $S$ 本身是一个回文字符串，则输出 $S$ 并在其后紧跟后缀 `(palindrome)`。

- 若 $S$ 不是回文字符串，则需要提取 $S$ 中长度最长的回文子串；若存在多个长度相等的最长回文子串，则输出其中字典序最小的一个。

## 输入格式

输入包含两行。

第一行一个整数 $n$（$-10^6 \leqq n \leqq 10^6$），代表待编码的魔力值。

第二行包含若干个以空格分隔的整数，表示进制序列 $b_1, b_2, \dots, b_m$（$1 \leqq m \leqq 10$，$2 \leqq b_i \leqq 26$）。

## 输出格式

输出一个字符串，表示按规程处理后的编码结果。

## 样例

### 样例 1

**输入：**
```
-21
5 7 3
```

**输出：**
```
bb
```

**说明：**
1. $n = -21 < 0$，故符号位 $s = 1$，映射为 ''b''。

2. 初始 $q = |-21| = 21$。

- 第一位进制 $b_1 = 5$：$d_1 = 21 \bmod 5 = 1$，$q = \lfloor 21 / 5 \rfloor = 4$。

- 第二位进制 $b_2 = 7$：$d_2 = 4 \bmod 7 = 4$，$q = \lfloor 4 / 7 \rfloor = 0$。

- 第三位进制 $b_3 = 3$：$d_3 = 0 \bmod 3 = 0$，$q = \lfloor 0 / 3 \rfloor = 0$。

3. 序列为 $(1, 1, 4, 0)$，映射得到字符串 $S = \text{"bbea"}$。

4. "bbea" 不是回文串。其所有的回文子串包括 "b", "e", "a", "bb"。其中最长的是 "bb"，故输出 "bb"。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686037/detail?pid=66847171&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686037/detail?pid=66847171&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.270065+00:00', '2026-07-02T15:26:50.334453+00:00', 2000, 262144, '开发'),
	(102, '命令行解析与出现次数统计', '命令行解析与出现次数统计', '华为', 'Medium', 'simulation', '在一种复杂的命令行系统中，命令的格式由一个模板字符串定义。模板由关键字、抉择结构 `{...}` 和可选结构 `[...]` 组成，元素间由空格分隔。

您的任务是解析这个模板，找出所有在顶层定义的固定关键字，并计算出每一个固定关键字在任意合法的命令中保证会出现的最小次数。

定义:

1. 关键字: 仅由小写字母组成的字符串。

2. 固定关键字: 在模板的顶层，不被任何括号包裹的关键字。它们是命令的根基。

3. 抉择结构 `{ A | B | ... }`: 表示该位置必须从选项 `A`, `B`, ... 中选择一个。选项本身可以是复杂的子模板。

4. 可选结构 `[ C ]`: 表示 `C` 部分是可选的，可以出现 0 次或 1 次。

保证出现次数的计算规则:

一个关键字 $K$ 的“保证出现次数” $C(K)$，是基于以下递归逻辑计算的：

- 首先，统计 $K$ 作为固定关键字出现的次数。

- 然后，遍历模板中的所有抉择结构 `{ A | B | ... }`，如果 $K$ 在每一个选项 $A, B, \dots$ 中都保证会出现（即，递归计算出的保证次数都 $\ge 1$），那么这个抉择结构就为 $C(K)$ 贡献 `+1`。

- 在可选结构 `[...]` 内部的任何关键字，都不被视为“保证出现”。

## 输入格式

- 输入为一行字符串，代表命令格式模板。
- 字符串由关键字、`{`, `}`, `|`, `[`, `]` 和空格组成。
- 输入字符串保证格式合法。

## 输出格式

- 输出共两行。
- 第一行：按输入顺序，输出所有固定关键字，以单个空格分隔。
- 第二行：对应第一行的每个关键字，输出其保证出现的最小次数以单个空格分隔。

## 样例

### 样例 1

**输入：**
```
a b { c | d [ e ] } [ f { g | h } ]
```

**输出：**
```
a b
1 1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683691/detail?pid=63699019&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683691/detail?pid=63699019&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.206734+00:00', '2026-07-02T15:27:04.185714+00:00', 2000, 262144, '开发'),
	(206, '单链表的排序', '单链表的排序', '牛客', 'Medium', 'linked-list', '给定一个节点数为n的无序单链表，对其按升序排序。

数据范围：$0 < n \le 100000$，保证节点权值在$[-10^9,10^9]$之内。

要求：空间复杂度 $O(n)$，时间复杂度 $O(nlogn)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,3,2,4,5]
```

**输出：**
```
{1,2,3,4,5}
```

### 样例 2

**输入：**
```
[-1,0,-2]
```

**输出：**
```
{-2,-1,0}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/f23604257af94d939848729b1a5cda08?tpId=295&tqId=1008897&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/f23604257af94d939848729b1a5cda08?tpId=295&tqId=1008897&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.579572+00:00', '2026-07-03T12:11:38.678802+00:00', 2000, 262144, '常见101'),
	(108, '无线网络信号塔覆盖', '无线网络信号塔覆盖', '华为', 'Medium', 'matrix-grid', '在一个 $n \times m$ 的城市网格中，需要部署无线网络信号塔来为居民区提供服务。网格中每个单元格的属性由一个整数值 $A[i][j]$ 定义：

1. 如果 $A[i][j] > 0$，表示该单元格是一个居民区，其数据需求为 $A[i][j]$。

2. 如果 $A[i][j] < 0$，表示该单元格可以建立一个信号塔，其信号半径为 $-A[i][j]$。

3. 如果 $A[i][j] = 0$，表示该单元格是空地。

一个位于 $(x_1, y_1)$ 的信号塔，其信号半径为 $R$ (即其原始值为 $-R$)，能够覆盖另一个位于 $(x_2, y_2)$ 的居民区，当且仅当它们的欧几里得距离满足以下条件：

$(x_1 - x_2)^2 + (y_1 - y_2)^2 \le R^2$

- 未被任何信号塔覆盖的居民区，其数据服务价值为 0。

- 如果一个居民区被 $k$ 个信号塔同时覆盖，由于信号干扰，其有效数据服务价值将从 $A[i][j]$ 下降为 $\lfloor \frac{A[i][j]}{k} \rfloor$。

你需要制定一个信号塔激活方案，选择激活哪些信号塔，以最大化所有居民区的总有效数据服务价值。请计算这个最大总价值，以及在达到最大总价值时，所需激活的最少信号塔数量。

## 输入格式

第一行输入两个整数 $n$ 和 $m$ ($1 \le n, m \le 600$)，代表城市网格的尺寸。
接下来 $n$ 行，每行包含 $m$ 个整数，代表网格单元格的属性值 $A[i][j]$ ($-800 \le A[i][j] \le 1000$)。
数据保证信号塔的总数（即 $A[i][j] < 0$ 的单元格数量）不超过 11 个。

## 输出格式

输出一行，包含两个用空格隔开的整数，分别代表：
1. 可以实现的最大总数据服务价值。
2. 在实现最大价值的前提下，所需激活的最少信号塔数量。

## 样例

### 样例 1

**输入：**
```
12 10
0 500 0 0 0 0 0 0 0 0
73 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
-401 0 0 0 0 0 -431 0 0 0
381 0 0 0 0 0 0 0 66 0
0 269 0 0 -783 0 0 0 0 0
0 0 0 0 0 680 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 289 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 804 0 0 0 0 0
0 0 0 0 0 0 0 -579 0 0
```

**输出：**
```
3062 1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686188/detail?pid=64451294&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686188/detail?pid=64451294&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.543719+00:00', '2026-07-02T15:25:47.487375+00:00', 2000, 262144, '开发'),
	(107, '云服务资源调度', '云服务资源调度', '华为', 'Medium', 'greedy', '一个云计算平台需要调度一批数据处理任务。每个任务都有一个计算成本，由一个正整数数组 $costs$ 表示，其中 $costs[i]$ 代表第 $i$ 个任务的计算成本。

平台拥有一批计算能力相同的服务器，每台服务器的最大计算容量为 $C$。为了优化资源利用率，任务分配遵循一种贪心策略：调度器为一台服务器分配任务时，总是优先选择当前未分配的、计算成本最高的，且不会超出服务器剩余容量的任务。

你需要计算，要处理完所有任务，最少需要多少台服务器。

## 输入格式

第一行：一个正整数 $N$，表示任务的总数，其中 $1 \le N \le 10^4$。

第二行：一个包含 $N$ 个正整数的数组 $costs$，表示每个任务的计算成本，其中 $1 \le costs[i] \le 10^4$。

第三行：一个正整数 $C$，表示每台服务器的最大计算容量，其中 $1 \le C \le 10^4$。

## 输出格式

输出一个整数，代表处理所有任务所需的最少服务器数量。

## 样例

### 样例 1

**输入：**
```
13
78 32 44 98 73 46 98 31 54 27 51 9 8
113
```

**输出：**
```
7
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686188/detail?pid=64451294&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686188/detail?pid=64451294&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.480085+00:00', '2026-07-02T15:25:58.891714+00:00', 2000, 262144, '开发'),
	(207, '判断一个链表是否为回文结构', '判断一个链表是否为回文结构', '牛客', 'Easy', 'linked-list', '给定一个链表，请判断该链表是否为回文结构。 
回文是指该字符串正序逆序完全一致。 
数据范围： 链表节点数 $0 \le n \le 10^5$，链表中每个节点的值满足 $|val| \le 10^7$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1}
```

**输出：**
```
true
```

### 样例 2

**输入：**
```
{2,1}
```

**输出：**
```
false
```

**说明：**
2->1

### 样例 3

**输入：**
```
{1,2,2,1}
```

**输出：**
```
true
```

**说明：**
1->2->2->1', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/3fed228444e740c8be66232ce8b87c2f?tpId=295&tqId=1008769&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/3fed228444e740c8be66232ce8b87c2f?tpId=295&tqId=1008769&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.623138+00:00', '2026-07-03T12:11:19.611569+00:00', 2000, 262144, '常见101'),
	(229, '判断是不是完全二叉树', '判断是不是完全二叉树', '牛客', 'Medium', 'tree', '给定一个二叉树，确定他是否是一个完全二叉树。 

完全二叉树的定义：若二叉树的深度为 h，除第 h 层外，其它各层的结点数都达到最大个数，第 h 层所有的叶子结点都连续集中在最左边，这就是完全二叉树。（第 h 层可能包含 [1~2h] 个节点）

数据范围：节点数满足 $1 \le n \le 100 \$

样例图1： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211112/392807_1636687704633/3FDF585A954EFF629B41FD21BA20B0C9)

样例图2： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211112/392807_1636687742831/942721EB3583D230F79D69B3097D3416)

样例图3： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211112/392807_1636687774162/1D0ED443BD0A777690EF55BABCD978D5)

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,3,4,5,6}
```

**输出：**
```
true
```

### 样例 2

**输入：**
```
{1,2,3,4,5,6,7}
```

**输出：**
```
true
```

### 样例 3

**输入：**
```
{1,2,3,4,5,#,6}
```

**输出：**
```
false
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/8daa4dff9e36409abba2adbe413d6fae?tpId=295&tqId=2299105&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/8daa4dff9e36409abba2adbe413d6fae?tpId=295&tqId=2299105&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.894495+00:00', '2026-07-03T16:40:22.513314+00:00', 2000, 262144, '常见101'),
	(208, '链表的奇偶重排', '链表的奇偶重排', '牛客', 'Medium', 'linked-list', '给定一个单链表，请设定一个函数，将链表的奇数位节点和偶数位节点分别放在一起，重排后输出。

注意是节点的编号而非节点的数值。

数据范围：节点数量满足 $0 \le n \le 10^5$，节点中的值都满足 $0 \le val \le 1000$

要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,3,4,5,6}
```

**输出：**
```
{1,3,5,2,4,6}
```

**说明：**
1->2->3->4->5->6->NULL重排后为1->3->5->2->4->6->NULL

### 样例 2

**输入：**
```
{1,4,6,3,7}
```

**输出：**
```
{1,6,7,4,3}
```

**说明：**
1->4->6->3->7->NULL重排后为1->6->7->4->3->NULL奇数位节点有1,6,7，偶数位节点有4,3。重排后为1,6,7,4,3', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/02bf49ea45cd486daa031614f9bd6fc3?tpId=295&tqId=1073463&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/02bf49ea45cd486daa031614f9bd6fc3?tpId=295&tqId=1073463&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.667483+00:00', '2026-07-03T12:11:04.792531+00:00', 2000, 262144, '常见101'),
	(115, '星际跃迁网络', '星际跃迁网络', '华为', 'Medium', 'simulation', '在一个广袤的宇宙中，存在一个由 $N$ 个星系组成的星际网络，星系编号从 $0$ 开始。

探险家们依赖 $M$ 条不同的“跃迁航线”在星系间穿梭。每条跃迁航线都连接着多个星系。

如果两条不同的跃迁航线都经过同一个星系，那么探险家就可以在该星系从一条航线切换到另一条，我们称之为一次“航线换乘”。

现在，给定一系列的星际旅行任务，每个任务包含一个起始星系和一个目标星系，请计算出完成每个任务所需的最少航线换乘次数。

## 输入格式

第一行包含三个整数 $N$、$M$ 和 $K$，分别代表星系的总数量、跃迁航线的总数量以及需要查询的旅行任务数量。

接下来 $M$ 行，每行描述一条跃迁航线。
行首是一个整数 $C$，表示该航线连接的星系数量，随后是 $C$ 个整数，代表这些星系的编号。

再接下来 $K$ 行，每行包含两个整数 $S$ 和 $T$，分别代表一个旅行任务的起始星系和目标星系。

所有变量的取值范围均为 $[0, 1000]$。

## 输出格式

对于每个查询任务，输出一个整数，即从起始星系 $S$ 到目标星系 $T$ 所需的最少换乘次数。
如果无法从 $S$ 到达 $T$，则输出 $-1$。

## 样例

### 样例 1

**输入：**
```
19 9 6
5 5 8 10 13 18
4 1 5 7 9
2 9 10
7 1 5 6 7 12 15 16
7 0 4 6 8 13 14 17
6 3 4 10 15 16 18
9 2 3 6 7 8 9 12 14 17
5 1 3 7 9 11
9 3 5 6 8 9 10 14 15 18
2 5
1 8
10 6
5 12
5 7
17 8
```

**输出：**
```
1
1
0
0
0
0
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686204/detail?pid=64837923&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686204/detail?pid=64837923&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.924300+00:00', '2026-07-02T15:24:00.137018+00:00', 2000, 262144, '开发'),
	(114, '安保系统最大警戒值', '安保系统最大警戒值', '华为', 'Medium', 'tree', '一座重要建筑的安保系统被设计成一个树形结构，每个节点代表一个安保传感器。

每个传感器都有一个特定的警戒值，并且可以被激活或关闭。

为了防止信号干扰，系统有一个严格的规定：

如果一个传感器被激活，那么与它直接相连的所有传感器（即它的父节点和子节点）都必须保持关闭状态。

作为安保系统的总工程师，您需要制定一个传感器激活方案，使得整个安保系统的总警戒值达到最大。

安保系统的拓扑结构是一个二叉树，由一个层序遍历的数组表示。

数组中的每个元素值代表对应传感器的警戒值。

您的任务是计算在该激活规则下，所能获得的最大总警戒值是多少。

## 输入格式

第一行为一个整数 $N$，代表层序遍历数组的大小。
第二行为 $N$ 个整数，代表层序遍历的数组，用空格分隔。

关于层序遍历的说明：
输入数组是二叉树的层序遍历结果。从根节点开始，自上而下、从左到右逐层记录每个节点的警戒值。如果某个位置在结构上应该有节点但实际没有（即 `null` 节点），则用 `0` 来占位。

数据范围：
$1 \le N \le 10^6$
$0 \le \text{警戒值} \le 100$

## 输出格式

输出一个整数，表示能够获得的最大总警戒值。

## 样例

### 样例 1

**输入：**
```
18
78 44 73 98 54 51 0 0 27 0 53 87 34 0 0 0 0 40
```

**输出：**
```
391
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686350/detail?pid=64696342&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686350/detail?pid=64696342&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.874251+00:00', '2026-07-02T15:24:11.282050+00:00', 2000, 262144, '开发'),
	(112, '实时社交媒体热点追踪', '实时社交媒体热点追踪', '华为', 'Medium', 'stack-queue', '您正在为一个社交媒体平台设计一个实时热点追踪系统。

该系统持续不断地从海量的用户帖子中提取关键词，并将这些关键词送入一个处理队列。

系统需要维护一个仪表盘，用于展示当前最受关注的热点话题。

然而，仪表盘的显示空间有限。

为了保证话题的新鲜度，系统遵循“先进先出”的原则：

每当一批新的关键词流入后，系统会从队列中最早进入的话题开始，更新并展示在仪表盘上，展示完毕后即从队列中移除，为更新的话题腾出空间。

您需要模拟这个热点追踪系统的核心逻辑。系统维护一个带计数器的关键词队列。

- 当一批新的关键词流入时，如果某个关键词已存在于队列中，其计数器加一；如果是新关键词，则将其加入队列尾部，计数器置为一。

- 每处理完一批关键词后，系统会从队列头部（即最早进入的关键词）开始，输出最多 $n$ 个关键词及其当前的计数值。

- 被输出的关键词将从队列中被彻底移除。这意味着，如果该关键词后续再次出现，它将被视为一个全新的热点，重新从队尾进入。

## 输入格式

- 第一行为一个整数 $n$，代表仪表盘的显示容量。$n$ 的范围是 $[0, 100]$。当 $n=0$ 时，表示仪表盘关闭，不输出任何内容。
- 从第二行开始，每行为一批用空格分隔的关键词字符串。
- 每批最多包含 $200$ 个关键词，总批数不超过 $1000$ 行。

## 输出格式

- 从第二行输入开始，每一批输入对应一行输出。
- 输出格式为 `关键词 计数值`，多个关键词信息之间用空格隔开。
- 如果当前队列为空，无法输出任何内容，则该行输出 `null`。

## 样例

### 样例 1

**输入：**
```
28
zws psp fdz fas gxl qua

jzp ekp vap kgb qyv lay buy wle lbb pee wtv kyn wyv ngc

neq ikg qjk qqf tde pjj nmr
cog qbx yjg qve dmb erx yli
ksx jkx ijo wvt wsp rcc pbg ctf xun cpb byo edp pyj jta

hrv nyo dvv muv rnq yyr

ywe jde zmi kxq olj gdk ckb xfz aqw

nrt vmj abm pdd itt utk xyy ecy fmo tat fza zcb rap
axr anx rnl phd yms qam cyq yhm kku vjn yms wox

toz xbi dtt hvd cfv uuu rqi hlz jhv rig iky wxp zhu
scr olw mwk qyy adi

wga icd cjg afn kyu lcq jpk yht
zit xce pkf tji yxg wke zfb bhw him klh tdg lwg pos fan

jgy ebc ocp nzf yhn yte zqt cyl ytm vrk ecl
upz hvd ngk dbg fjl bjv ekw ojq edh cte yzr cik nwc pqa
hjo eki upj ahq dpx fkl wfs app vlr vdf qlb rxb uja ryg

pwk ywg wmv tln eaq flv nwq
fvz dox yrc izs jmc obo fdw jml zbr shi qmg yqw chj kno ado
ind fsx nva gox tva jrk gzl dbe
ych tbr wmy kml xwx ttn
efv zkk hro hwt loc ihc hbs hyg oug asz dwb zqn jtl

hpc zqa tnp mbq vwu mno kno uhx lie shr
sum skm soy ymq kqh jlu zwh iwi irb
cwh vsf nmp iqb nry ovx zws gup tvy diu ina obd
mqd ccr noq gvo oxi

egi xdb rro vlq fvv hkw xch
vta ege wtf cem bcc zmv bgx vkt gcv gwq rsw iad

tun dfj hst rlu tbe zrx ugx

xqp shc aur uyz ojh gib mfz ulp kzm kfx hhv
qjl msx bsz lfy fxr mpf hvj xnr kuc ayq mup hye yxz uvj
ifh ivr ztu wzr mub ens bzg xgu lxy lvi cqv
bxh jpz bsb uju dbk tru moa hyk gga ull wsy vdm bsv mvr
```

**输出：**
```
zws 1 psp 1 fdz 1 fas 1 gxl 1 qua 1
null
jzp 1 ekp 1 vap 1 kgb 1 qyv 1 lay 1 buy 1 wle 1 lbb 1 pee 1 wtv 1 kyn 1 wyv 1 ngc 1
null
null
null
neq 1 ikg 1 qjk 1 qqf 1 tde 1 pjj 1 nmr 1
cog 1 qbx 1 yjg 1 qve 1 dmb 1 erx 1 yli 1
ksx 1 jkx 1 ijo 1 wvt 1 wsp 1 rcc 1 pbg 1 ctf 1 xun 1 cpb 1 byo 1 edp 1 pyj 1 jta 1
null
hrv 1 nyo 1 dvv 1 muv 1 rnq 1 yyr 1
null
null
ywe 1 jde 1 zmi 1 kxq 1 olj 1 gdk 1 ckb 1 xfz 1 aqw 1
null
nrt 1 vmj 1 abm 1 pdd 1 itt 1 utk 1 xyy 1 ecy 1 fmo 1 tat 1 fza 1 zcb 1 rap 1
axr 1 anx 1 rnl 1 phd 1 yms 2 qam 1 cyq 1 yhm 1 kku 1 vjn 1 wox 1
null
null
toz 1 xbi 1 dtt 1 hvd 1 cfv 1 uuu 1 rqi 1 hlz 1 jhv 1 rig 1 iky 1 wxp 1 zhu 1
scr 1 olw 1 mwk 1 qyy 1 adi 1
null
wga 1 icd 1 cjg 1 afn 1 kyu 1 lcq 1 jpk 1 yht 1
zit 1 xce 1 pkf 1 tji 1 yxg 1 wke 1 zfb 1 bhw 1 him 1 klh 1 tdg 1 lwg 1 pos 1 fan 1
null
jgy 1 ebc 1 ocp 1 nzf 1 yhn 1 yte 1 zqt 1 cyl 1 ytm 1 vrk 1 ecl 1
upz 1 hvd 1 ngk 1 dbg 1 fjl 1 bjv 1 ekw 1 ojq 1 edh 1 cte 1 yzr 1 cik 1 nwc 1 pqa 1
hjo 1 eki 1 upj 1 ahq 1 dpx 1 fkl 1 wfs 1 app 1 vlr 1 vdf 1 qlb 1 rxb 1 uja 1 ryg 1
null
pwk 1 ywg 1 wmv 1 tln 1 eaq 1 flv 1 nwq 1
fvz 1 dox 1 yrc 1 izs 1 jmc 1 obo 1 fdw 1 jml 1 zbr 1 shi 1 qmg 1 yqw 1 chj 1 kno 1 ado 1
ind 1 fsx 1 nva 1 gox 1 tva 1 jrk 1 gzl 1 dbe 1
ych 1 tbr 1 wmy 1 kml 1 xwx 1 ttn 1
efv 1 zkk 1 hro 1 hwt 1 loc 1 ihc 1 hbs 1 hyg 1 oug 1 asz 1 dwb 1 zqn 1 jtl 1
null
null
hpc 1 zqa 1 tnp 1 mbq 1 vwu 1 mno 1 kno 1 uhx 1 lie 1 shr 1
sum 1 skm 1 soy 1 ymq 1 kqh 1 jlu 1 zwh 1 iwi 1 irb 1
cwh 1 vsf 1 nmp 1 iqb 1 nry 1 ovx 1 zws 1 gup 1 tvy 1 diu 1 ina 1 obd 1
mqd 1 ccr 1 noq 1 gvo 1 oxi 1
null
egi 1 xdb 1 rro 1 vlq 1 fvv 1 hkw 1 xch 1
vta 1 ege 1 wtf 1 cem 1 bcc 1 zmv 1 bgx 1 vkt 1 gcv 1 gwq 1 rsw 1 iad 1
null
tun 1 dfj 1 hst 1 rlu 1 tbe 1 zrx 1 ugx 1
null
xqp 1 shc 1 aur 1 uyz 1 ojh 1 gib 1 mfz 1 ulp 1 kzm 1 kfx 1 hhv 1
qjl 1 msx 1 bsz 1 lfy 1 fxr 1 mpf 1 hvj 1 xnr 1 kuc 1 ayq 1 mup 1 hye 1 yxz 1 uvj 1
ifh 1 ivr 1 ztu 1 wzr 1 mub 1 ens 1 bzg 1 xgu 1 lxy 1 lvi 1 cqv 1
bxh 1 jpz 1 bsb 1 uju 1 dbk 1 tru 1 moa 1 hyk 1 gga 1 ull 1 wsy 1 vdm 1 bsv 1 mvr 1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686350/detail?pid=64696342&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686350/detail?pid=64696342&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.750472+00:00', '2026-07-02T15:24:35.286039+00:00', 2000, 262144, '开发'),
	(121, '山峰间的极限跳跃', '山峰间的极限跳跃', '华为', 'Medium', 'tree', '您是一位极限运动家，正挑战一片由计算机生成的、结构奇特的数字山脉。

这片山脉由 $N$ 个山峰组成，每个山峰都有其独特的海拔高度。

您的目标是规划出一条最长的、符合“极限跳跃”规则的下山路径。

这片数字山脉的结构可以用一棵二叉树来精确描述。您规划的路径必须遵循一系列严格的规则，我们称之为一条“极限交替路径”：

路径方向 : 路线必须严格自上而下，即只能从一个山峰移动到与之直接相连的子山峰。

严格交替 : 路径上海拔的变化必须是严格的交替上升和下降。例如，一条合法的路径可以是海拔 $p_1 \to p_2 \to p_3 \to p_4$，其海拔序列满足 $p_1 < p_2 > p_3 < p_4$。无论是“先升后降”还是“先降后升”的交替模式都是允许的。

极限跳跃 : 每次移动（从一个山峰到下一个）的海拔绝对差值必须大于或等于一个给定的阈值 $k$。形式化地，对于路径上任意相邻的两个山峰 $A$ 和 $B$，必须满足 $|\text{altitude}(B) - \text{altitude}(A)| \ge k$。

您的任务是找出在这片山脉中，能够规划出的最长“极限交替路径”的长度。路径的长度以其所包含的山峰数量计算。

## 输入格式

第一行包含两个整数 $N$ 和 $K$。
$N$ 是山峰的总数, $1 \le N \le 10000$。
$K$ 是要求的最小海拔差 (极限跳跃阈值), $1 \le K \le 100$。
接下来的 $N$ 行描述了山脉的结构。每行包含三个整数 $X, Y, Z$：
$X$ 是当前山峰的海拔。
$Y$ 是其左侧子山峰的海拔。
$Z$ 是其右侧子山峰的海拔。
如果某个子山峰不存在，则用 $-1$ 表示。
所有山峰的海拔高度都在 $[1, 100000]$ 范围内，且保证互不相同。
这 $N$ 行的输入顺序遵循该山脉地图的先序遍历顺序。

## 输出格式

一个整数，代表最长“极限交替路径”的长度。

## 样例

### 样例 1

**输入：**
```
6 10
20 10 -1
10 21 -1
21 -1 11
11 -1 22
22 12 -1
12 -1 -1
```

**输出：**
```
6
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686405/detail?pid=64952987&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686405/detail?pid=64952987&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.246549+00:00', '2026-07-02T15:22:46.118808+00:00', 2000, 262144, '开发'),
	(120, '中世纪的商路', '中世纪的商路', '华为', 'Medium', 'graphs', '时值中世纪，您是一位雄心勃勃的商人，计划在地中海的各大城市之间开展一系列贸易活动。您获得了一份航海图，上面标注了 $n$ 条利润丰厚的贸易航线。每一条航线都连接着两个港口，有明确的出发和到达日期，并需要一支特定规模的商队来完成。您的目标是在有限的资源下，规划出最赚钱的贸易路线。

您有 $n$ 个贸易机会可供选择。对于第 $i$ 个贸易机会，您掌握以下信息：

出发时间 : $startTime_i$

到达时间 : $endTime_i$

所需商队规模 : $effort_i$

预期利润 : $profit_i$

您所能召集的最大商队规模为 $maxEffort$。在任何时候，您都只能派遣一支商队，因此您不能同时进行时间上重叠的贸易活动。然而，如果一趟贸易在时间 $X$ 结束，您可以立即开始一趟新的、在时间 $X$ 出发的贸易。

您的任务是制定一份贸易计划，选择一部分贸易机会来执行，使得总利润最大化，同时确保任何时刻派遣的商队规模之和都不超过您的最大能力 $maxEffort$。

## 输入格式

输入包含 5 个参数，前四个是描述贸易机会的数组，第五个是您的最大商队规模。

1. 出发时间数组 ($startTime$) : 一个整数数组，表示每个贸易机会的出发时间。
2. 到达时间数组 ($endTime$) : 一个整数数组，表示每个贸易机会的到达时间。
3. 商队规模数组 ($effort$) : 一个整数数组，表示完成每个贸易机会所需的商队规模。
4. 利润数组 ($profit$) : 一个整数数组，表示完成每个贸易机会可获得的利润。
5. 最大商队规模 ($maxEffort$) : 一个整数，表示您能召集的最大商队规模。

约束条件 :
所有数组的长度 $n$ 相等，且 $1 \le n \le 2000$。
$1 \le startTime_i < endTime_i \le 2000$。
$1 \le effort_i, profit_i \le 10^9$。
$1 \le maxEffort \le 1000$。

输入格式 :
输入共 5 行，每行代表一个参数。前 4 行的数组数据由空格分隔。

## 输出格式

一个整数，代表您能获得的最大总利润。

## 样例

### 样例 1

**输入：**
```
2 4 7
6 8 11
20 20 20
30 90 30
40
```

**输出：**
```
90
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686489/detail?pid=64933347&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686489/detail?pid=64933347&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.188716+00:00', '2026-07-02T15:22:58.594225+00:00', 2000, 262144, '开发'),
	(119, '星际勘探者', '星际勘探者', '华为', 'Medium', 'simulation', '公元 2242 年，您是星际勘探舰“奥德赛号”的舰长，正在执行一项穿越未知小行星带的危险任务。

远程扫描显示，前方有一条由 $m$ 颗小行星组成的直线路径，每一颗都蕴藏着宝贵的能量水晶。

您的任务是规划航线，最大限度地补充舰船的能量储备。

您将要穿越的星系包含 $m$ 颗小行星，编号从 $1$ 到 $m$。您的舰船只能沿着编号递增的方向前进，无法后退。

初始状态 : 您的舰船携带有 $n$ 个单位的初始能量。

航行消耗 : 从当前位置航行到下一颗小行星，需要消耗 $1$ 个单位的能量。如果能量为 $0$，舰船将无法启动，无法航行到新的小行星。

能量采集 : 您装备了一台高能水晶采集器，但由于能源核心的限制，在整个任务中最多只能使用 $k$ 次。每颗小行星最多只能被采集一次。采集小行星 $i$ 上的水晶，可以为舰船瞬间补充 $a_i$ 个单位的能量。

您的目标是，在整个勘探任务的任意时刻，舰船所能达到的**最大能量值**是多少？

请注意，您可以选择不登陆任何小行星。

## 输入格式

第一行包含三个正整数 $m, n, k$ ($1 \le m, n, k \le 20$)，由空格隔开。
第二行包含 $m$ 个整数 $a_1, a_2, \dots, a_m$ ($0 \le a_i \le 20$)，代表每颗小行星上蕴含的能量水晶数量，由空格隔开。

## 输出格式

一个整数，表示在整个任务过程中，舰船能达到的最大能量值。

## 样例

### 样例 1

**输入：**
```
17 20 19
19 0 2 6 20 3 4 1 8 3 8 7 14 8 19 11 17
```

**输出：**
```
153
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686489/detail?pid=64933347&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686489/detail?pid=64933347&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.133153+00:00', '2026-07-02T15:23:12.094008+00:00', 2000, 262144, '开发'),
	(118, '命令行软件', '命令行软件', '华为', 'Medium', 'hashing', '在2077年，您是一位顶尖的“深空网络”工程师，负责维护一个位于遥远星系的分布式文件系统。

该系统的稳定运行对于星际通信至关重要。

现在，您需要编写一个模拟程序来测试和验证该文件系统的核心命令行功能。

## 输入格式

这个星际文件系统是一个典型的树状结构。系统的根目录表示为 $\Large /$。系统初始化时，根目录下已经创建了一个名为 usr 的用户目录，而您的初始工作目录也正是 /usr。

您需要处理一连串的命令行指令。支持的指令集如下：

mkdir: 在当前目录下，创建一个名为的新目录。如果同名目录已存在，则此指令将被忽略。
cd .. : 切换到上一级父目录。
cd: 切换到当前目录下的子目录。
ls : 列出当前目录下所有子目录的名称，并按字典序升序排列。

您将接收到 $m$ 条指令。您的任务是模拟这些指令的执行，并输出所有 ls 指令的结果。

## 输出格式

对于每一条 ls 指令，您需要输出其执行结果。每条 ls 的结果占一行，目录名之间用单个空格分隔。
特别地，如果当前目录下没有任何子目录， ls 指令应当输出一个单独的空格。

## 样例

### 样例 1

**输入：**
```
20
mkdir syadhzdgck
mkdir irky
cd ..
cd usr
ls
cd ..
ls
mkdir wfanr
cd usr
ls
cd ..
ls
mkdir fuuszuicsn
cd wfanr
cd ..
cd fuuszuicsn
cd ..
mkdir ebw
cd ebw
ls
```

**输出：**
```
irky syadhzdgck
usr
irky syadhzdgck
usr wfanr
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686489/detail?pid=64933347&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686489/detail?pid=64933347&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.081426+00:00', '2026-07-02T15:23:25.313425+00:00', 2000, 262144, '开发'),
	(117, '基因调控网络', '基因调控网络', '华为', 'Easy', 'graphs', '在基因组学研究中，基因之间的调控关系可以被抽象成一个有向图，我们称之为基因调控网络。

在这个网络中，每个节点代表一个基因，一条从基因 $u$ 指向基因 $v$ 的有向边表示基因 $u$ 会激活基因 $v$。

科学家们对一种被称为“协同调控模体”（Co-regulatory Motif）的特殊结构非常感兴趣。

一个协同调控模体由四个不同的基因 $a, b, c, d$ 组成，它们需要满足以下激活关系：

1. 主调节基因 $a$ 能够直接激活两个中间基因 $b$ 和 $d$。

2. 这两个中间基因 $b$ 和 $d$ 又都能直接激活同一个目标基因 $c$。

简单来说，这个结构意味着存在两条从基因 $a$ 到基因 $c$ 的长度为 2 的不同路径，一条路径为 $a \rightarrow b \rightarrow c$，另一条为 $a \rightarrow d \rightarrow c$。

给定一个基因调控网络的结构，请计算该网络中总共存在多少个这样的“协同调控模体”。

## 输入格式

第一行包含两个整数 $n$ 和 $m$，使用空格隔开。
$n$ 代表基因的数量（编号从 $1$ 到 $n$），$m$ 代表已知的直接激活关系的数量。
接下来的 $m$ 行，每行包含两个整数 $u, v$，表示存在一条从基因 $u$ 到基因 $v$ 的激活关系。

数据范围：$1 \le n \le 1000$，$0 \le m \le 10000$。

## 输出格式

输出一个整数，代表网络中“协同调控模体”的总数量。

## 样例

### 样例 1

**输入：**
```
24 60
1 4
1 6
1 7
2 9
2 12
2 13
2 16
2 19
2 23
3 5
4 3
4 6
4 11
4 15
4 17
4 22
5 4
5 12
6 20
6 21
7 2
7 23
8 1
8 4
8 22
9 20
9 23
10 1
10 9
10 17
10 20
11 12
12 1
12 5
12 16
14 9
14 17
14 20
14 21
15 12
16 12
16 17
17 5
17 6
17 14
18 1
19 22
19 23
20 22
21 17
21 24
22 11
22 21
23 10
23 14
23 17
23 24
24 5
24 16
24 17
```

**输出：**
```
20
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686204/detail?pid=64837923&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686204/detail?pid=64837923&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.033226+00:00', '2026-07-02T15:23:37.154756+00:00', 2000, 262144, '开发'),
	(210, '删除有序链表中重复的元素-II', '删除有序链表中重复的元素-II', '牛客', 'Medium', 'linked-list', '给出一个升序排序的链表，删除链表中的所有重复出现的元素，只保留原链表中只出现一次的元素。
例如：
给出的链表为$1 \to 2\to 3\to 3\to 4\to 4\to5$, 返回$1\to 2\to5$.
给出的链表为$1\to1 \to 1\to 2 \to 3$, 返回$2\to 3$. 

数据范围：链表长度 $0 \le n \le 10000$，链表中的值满足 $|val| \le 1000$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,2}
```

**输出：**
```
{1}
```

### 样例 2

**输入：**
```
{}
```

**输出：**
```
{}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/71cef9f8b5564579bf7ed93fbe0b2024?tpId=295&tqId=663&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/71cef9f8b5564579bf7ed93fbe0b2024?tpId=295&tqId=663&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.764708+00:00', '2026-07-03T12:10:29.687100+00:00', 2000, 262144, '常见101'),
	(127, '基因序列分组优化', '基因序列分组优化', '华为', 'Medium', 'simulation', '在一个基因工程研究项目中，科学家们获得了一批基因序列样本 $G_0$。

这批样本的数量为 $N$，其中 $N$ 是一个偶数，且 $1 \le N \le 500$。

每个基因序列都有一个整数ID，ID值可能会重复出现。

为了进行对比实验，需要将这批样本 $G_0$ 分成两个小组：实验组 $G_A$ 和对照组 $G_B$。

分组必须遵循以下严格的实验标准：

1. 数量均等 : 两个小组的基因序列样本数量必须完全相等，即 $|G_A| = |G_B| = \frac{N}{2}$。

2. 组内ID唯一性 : 在同一个小组内，所有基因序列的ID必须是唯一的。

3. 有序排列 : 输出时，两个小组内的基因序列ID都必须按升序排列。

4. 实验组复杂度最小化 : 为了确保实验结果的准确性，实验组 $G_A$ 的“基因复杂度”（定义为组内所有ID的总和 $\sum_{id \in G_A} id$）必须达到最小值。

您的任务是设计一个算法，根据给定的初始样本集合 $G_0$，找出满足上述所有条件的最优分组方案。

如果存在这样的方案，请输出两个小组的ID列表。

如果无法找到任何满足条件的分组方案，则输出 `null`。

## 输入格式

一个包含 $N$ 个正整数的数组，代表初始基因序列样本集合 $G_0$ 的ID列表。
数组长度 $N$ 的范围为 $[1, 500]$。

## 输出格式

如果存在有效分组，输出两行。
第一行是实验组 $G_A$ 的ID列表（升序），第二行是对照组 $G_B$ 的ID列表（升序）。
ID之间用空格隔开。

如果不存在有效分组，则输出字符串 `null`。

## 样例

### 样例 1

**输入：**
```
1 1 2 4 3 6
```

**输出：**
```
1 2 3
1 4 6
```

### 样例 2

**输入：**
```
1 1 1 2
```

**输出：**
```
null
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686472/detail?pid=65084866&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686472/detail?pid=65084866&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.586960+00:00', '2026-07-02T15:20:43.765732+00:00', 2000, 262144, '开发'),
	(125, '古代咒语共鸣匹配', '古代咒语共鸣匹配', '华为', 'Medium', 'simulation', '作为一名古代奥术师，您正在研究一卷新发现的神秘卷轴。

卷轴上铭刻着一段由古代符文组成的强大文本。

您相信，通过念出特定的咒语（同样由符文组成），可以与卷轴文本产生共鸣，从而释放强大的魔法。

共鸣的强度取决于咒语的符文与卷轴文本的匹配方式和位置。

您的任务是开发一个系统，来精确计算任意咒语与卷轴文本之间的共鸣分数。

共鸣分数由两个核心部分决定：匹配度 和 位置能量 。

1. 匹配度 (Match Score)

根据咒语的符文序列（`incantation`）与卷轴文本序列（`scroll_text`）的匹配情况，分为以下四个等级，按优先级从高到低判断 ：

1. 完美谐振 (Perfect Harmonic Match) : 咒语中的所有符文，在卷轴文本中以相同的顺序出现（可以不相邻）。

匹配度得分 : $X_1 = 1.0$

2. 部分谐振 (Partial Harmonic Match) : 咒语中的所有符文，都能在卷轴文本中找到，但顺序不完全一致。

匹配度得分 : $X_2 = 0.8$

3. 微弱回响 (Faint Echo) : 只有部分咒语符文能在卷轴文本中找到。设咒语总符文数为 $k$，实际匹配到的符文数为 $i$。

匹配度得分 : $X_3 \times \frac{i}{k}$，其中 $X_3 = 0.6$

4. 静默 (Silence) : 不属于以上任何一种情况（即咒语中没有任何一个符文出现在卷轴文本中）。

匹配度得分 : $X_4 = 0.0$

2. 位置能量 (Positional Energy)

出现在卷轴开头的符文能引导更强大的能量。

设卷轴文本的符文总数为 $L$。对于在卷轴中匹配到的一个符文，其 0-索引位置为 $p$，则该符文贡献的 位置能量 为：

$[ W_p = 1.0 - \frac{p}{L-1} ]$

(当 $L=1$ 时，分母为0，此时约定 $W_0 = 1.0$)

一个咒语的 总位置能量 是其所有匹配到的符文的 位置能量之和 。

如果卷轴文本中包含多个相同的符文，只计算第一次出现的那个符文的位置能量。

3. 最终共鸣分数

共鸣分数由匹配度与总位置能量相乘得到，并需要进行精度处理。

$[ \text{Resonance Score} = \lfloor (\text{Match Score} \times \text{Positional Energy}) \times 10000 \rfloor / 10000 ]$

(这相当于将结果小数点后第4位之后的部分直接截断，而不是四舍五入)

注意 ：所有符文匹配过程 忽略大小写 。

## 输入格式

输入为单行字符串，由半角管道符 `|` 分隔。
第一个部分是卷轴文本 (`scroll_text`)。
之后的部分是 N 个待测试的咒语 (`incantation_1`, `incantation_2`, ...)。
格式: `scroll_text|incantation_1|incantation_2|...|incantation_N`
卷轴文本和咒语都由一个或多个符文（英文单词）组成，符文之间用空格分隔。
咒语的数量 $N < 100$。

## 输出格式

为每个输入的咒语计算一个共鸣分数。
所有分数在一行内输出，同样由半角管道符 `|` 分隔，并保留4位小数。
格式: `score_1|score_2|...|score_N`

## 样例

### 样例 1

**输入：**
```
Advanced Camera: Capture Life in Stunning Detail! Elevate Your Photography with Our Cutting-Edge Camera!|Camera|Camera Photography|digital phone|phone
```

**输出：**
```
0.9230|1.2307|0.0000|0.0000
```

### 样例 2

**输入：**
```
buy red running shoes online!|red shoes|buy shoes running|shoes black|Phone
```

**输出：**
```
1.0000|1.4000|0.0750|0.0000
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686416/detail?pid=65076727&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686416/detail?pid=65076727&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.477706+00:00', '2026-07-02T15:21:55.167822+00:00', 2000, 262144, '开发'),
	(124, '星港交通调度', '星港交通调度', '华为', 'Medium', 'simulation', '在星际纪元 2333 年，您是“星尘港务局”最先进的交通调度AI。

您负责管理银河系中最繁忙的垂直太空港——“天穹站”。

空间站从上到下共分为 $F$ 个停泊层级，每个层级都配备了 $M$ 个标准化的无人对接泊位。

每天，数以万计的星舰涌入“天穹站”的管辖空域，提交停泊申请。

您的核心任务是以最低的能源消耗，最高效地为这些星舰分配泊位。

星舰的停泊规则非常特殊：

停泊分配 ：每艘星舰 $i$ 的申请中会包含一个 首选停泊层级 $R_i$ 和一个 船员人数 $P_i$。根据空间站的设计，星舰只能被安排在其首选层级 $R_i$ 或 其下方的任意层级（直至最底部的1层）。

能源消耗计算 ：为一次停泊分配计算总能耗是您的关键绩效指标（KPI）。总能耗由两部分构成：

1. 基础能耗 ：无论在哪一层停泊，仅对接过程本身就需要消耗 $2$ 个单位的能量。

2. 调度能耗 ：如果一艘星舰被安排在低于其首选层级的位置，为了转运船员和货物，每向下一层，就需要额外消耗 $1$ 个单位的能量。

总能耗公式 ：对于一艘首选层级为 $R_i$，最终停在 $A_i$ 层 ($A_i \le R_i$)，载有 $P_i$ 名船员的星舰，其单次任务能耗为：$P_i \times (2 + (R_i - A_i))$。

任务目标 ：您的目标是为所有 $N$ 艘申请的星舰找到一个停泊方案，使得 总能耗（所有星舰的能耗之和）达到最小值。

异常情况 ：如果泊位总数不足以容纳所有申请的星舰，调度计划无法完成，此时应报告异常，输出 $-1$。

## 输入格式

第一行包含三个整数 $F, M, N$。
$F$ ：空间站的总层级数 ($1 \le F \le 1000$)。
$M$ ：每层的泊位数 ($1 \le M \le 100$)。
$N$ ：总共收到的星舰停泊申请数 ($1 \le N \le 100000$)。
接下来 $N$ 行，每行包含两个整数 $R_i, P_i$。
$R_i$ ：第 $i$ 艘星舰的首选停泊层级 ($1 \le R_i \le F$)。
$P_i$ ：第 $i$ 艘星舰的船员人数 ($1 \le P_i \le 50$)。

## 输出格式

输出一个整数，表示能够实现的最低总能耗。
如果无法为所有星舰安排泊位，则输出 $-1$。

## 样例

### 样例 1

**输入：**
```
3 3 4
2 20
1 10
2 10
2 10
```

**输出：**
```
100
```

### 样例 2

**输入：**
```
1 1 2
1 10
1 20
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686416/detail?pid=65076727&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686416/detail?pid=65076727&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.413496+00:00', '2026-07-02T15:22:07.971275+00:00', 2000, 262144, '开发');
INSERT INTO public.problems VALUES
	(123, '星际虫洞网络', '星际虫洞网络', '华为', 'Medium', 'graphs', '在遥远的未来，人类已步入深空探索时代。

一家名为“星尘航路”的先锋公司绘制了一份包含 $n$ 个未知星系的宏伟星图。

每个星系 $i$ 都被赋予了一个独特的空间量子签名 $a_i$，这是一个用于描述其多维度物理特性的巨大整数。

“星尘航路”公司掌握了一项革命性技术：在两个星系之间开启稳定的虫洞。

然而，虫洞的建立条件极为苛刻，只有当两个星系 $i$ 和 $j$ 的空间量子签名发生“谐波共振”时才能成功。

您是“星尘航路”公司的一名网络架构师，负责规划星际航线。您需要分析给定的 $n$ 个星系及其签名，以确定最高效的航行网络。

星系网络 : 整个星图可以被看作一个巨大的网络（一个无向图），其中每个星系是一个节点。

虫洞（边）: 只有当星系 $i$ 和星系 $j$ ($i \neq j$) 的签名 $a_i$ 和 $a_j$ 满足谐波共振条件时，它们之间才能建立一条虫洞（一条边）。共振条件被定义为两个签名的 按位与 (Bitwise AND) 运算结果不为零：

$a_i \ \& \ a_j \neq 0$

航行回路 : 您的任务是找出这个星际网络中最短的航行回路（即图论中的“环”）。一个有效的回路必须至少包含 3 个星系。回路的长度定义为它所包含的虫洞数量。

任务目标 : 计算出最短航行回路的长度。如果网络中不存在任何回路，则报告该情况。

## 输入格式

第一行是一个整数 $n$，代表已发现的星系总数 ($1 \leq n \leq 10^6$)。
第二行是 $n$ 个用空格分隔的整数 $a_1, a_2, \dots, a_n$，代表每个星系的空间量子签名 ($0 \leq a_i \leq 10^{18}$)。注意：签名值可能为 0 或出现重复。

## 输出格式

输出一个整数，表示最短航行回路的长度。
如果星际网络中不存在任何回路，则输出 $-1$。

## 样例

### 样例 1

**输入：**
```
10
448 0 112 0 0 0 28 260 3 0
```

**输出：**
```
4
```

### 样例 2

**输入：**
```
4
1 2 4 8
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686405/detail?pid=64952987&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686405/detail?pid=64952987&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.354050+00:00', '2026-07-02T15:22:20.946295+00:00', 2000, 262144, '开发'),
	(139, '细胞增殖', '细胞增殖', '华为', 'Medium', 'simulation', '生物学家小明正在研究一种特殊的细胞，这种细胞的增殖模式十分奇特。

他通过显微镜长期观察，记录下了 $N$ 个不同时间点的细胞种群数量。

小明提出了一个理论模型：他认为这些细胞的增殖可能遵循一种规律，即种群数量会等于某个“增殖基数” $B$ 的 $t$ 次方与一个“稳定基数” $S$ 的和，其中 $t$ 代表增殖周期（一个正整数）。完整的公式为：$C = B^t + S$。

现在，小明整理出了 $M$ 组假说，每组假说包含一个增殖基数 $B_j$ 和一个稳定基数 $S_j$。

他希望您能帮他验证，对于每一组假说 $(B_j, S_j)$，在他的 $N$ 条观测记录中：

1. 总共有多少条记录符合 $C_i = B_j^t + S_j$ 的模式（$t$ 可以取任意正整数）？

2. 在所有符合该模式的记录中，单个增殖周期（即固定的 $t$ 值）所能对应的最高重复观测次数是多少？我们称之为“增殖峰值”。

## 输入格式

输入第一行包含两个正整数 $N$ 和 $M$，分别代表观测记录的数量和假说的数量。
$(1 \le N \le 100000, 1 \le M \le 200000)$

第二行包含 $N$ 个整数，表示 $N$ 条细胞种群数量的观测记录 $C_i$。数据保证按从小到大的顺序排列。
$(1 \le C_i \le 10^9)$

接下来 $M$ 行，每行包含两个整数 $B_j$ 和 $S_j$，代表一组假说的增殖基数和稳定基数。
$(0 \le B_j, S_j \le 10^7)$

## 输出格式

输出共 $M$ 行，每行对应一组假说的验证结果。

每行输出两个整数，以空格隔开，分别代表：
1. 符合该假说模式的总观测记录数。
2. 该假说模式下的增殖峰值。

## 样例

### 样例 1

**输入：**
```
4 2
45 78 90 429981774
12 78
9 42561285
```

**输出：**
```
2 1
1 1
```

### 样例 2

**输入：**
```
11 3
2 3 4 5 5 6 7 7 9 16 17
2 0
2 1
0 7
```

**输出：**
```
3 1
5 2
2 2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686148/detail?pid=65575554&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686148/detail?pid=65575554&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.228312+00:00', '2026-07-02T15:17:46.532350+00:00', 2000, 262144, '开发'),
	(133, '飞船扫描', '飞船扫描', '华为', 'Medium', 'matrix-grid', '在遥远的未来，人类的星际方舟“启示录号”在穿越一片未知的小行星带时，船体遭到了微型陨石的撞击，导致部分区域受损。

为了评估飞船的结构完整性，维修系统需要对一块大小为 $N \times M$ 的船体截面进行扫描。

扫描结果被表示为一个 $N \times M$ 的矩阵，其中每个元素代表一个船体单元的状态：

$0$：表示该单元完好无损。

$1$：表示该单元已损坏或出现破裂。

一个“独立密封舱”被定义为一片由一个或多个相连的完好单元组成的区域，该区域在上下左右四个方向上被损坏单元完全包围。

一个重要的前提是：扫描矩阵的外部区域被认为是与飞船主体相连的、广阔的完好区域 。

因此，任何与矩阵边界直接或间接相连的完好单元区域，都被视作飞船主体结构的一部分，而不是“独立密封舱”。

您的任务是编写一个程序，计算出所有独立密封舱的总面积（即，其中包含的完好单元的总数）。

## 输入格式

第一行包含两个整数 $M$ 和 $N$，分别代表船体截面扫描图的宽度和高度。

$1 \le M, N \le 300$

接下来的 $N$ 行，每行包含 $M$ 个整数（$0$ 或 $1$），代表扫描矩阵的每一行。

## 输出格式

输出一个整数，代表所有独立密封舱的总面积。

## 样例

### 样例 1

**输入：**
```
7 7
1 1 1 1 1 1 1
1 0 0 0 0 0 1
1 0 1 1 1 0 1
1 0 1 0 1 0 1
1 0 1 1 1 0 1
1 0 0 0 0 0 1
1 1 1 1 1 1 1
```

**输出：**
```
17
```

### 样例 2

**输入：**
```
8 4
1 1 1 0 1 1 1 1
1 0 1 0 1 1 0 1
1 1 1 0 1 1 1 1
0 0 1 0 0 1 1 1
```

**输出：**
```
2
```

### 样例 3

**输入：**
```
8 4
0 0 1 0 1 0 0 0
0 0 1 0 0 1 0 0
1 1 1 0 0 1 1 1
0 0 0 0 0 0 0 0
```

**输出：**
```
0
```

### 样例 4

**输入：**
```
8 4
0 0 0 1 1 0 0 0
0 0 1 0 0 1 0 0
0 0 1 0 0 1 0 0
0 0 0 1 1 0 0 0
```

**输出：**
```
4
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686308/detail?pid=65254753&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686308/detail?pid=65254753&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.935712+00:00', '2026-07-02T15:19:31.044095+00:00', 2000, 262144, '开发'),
	(132, '时间序列', '时间序列', '华为', 'Medium', 'simulation', '在一次高纬度时空实验中，科学家捕获了两段来自不同宇宙的时间序列信号，分别记为序列 $A$ 和序列 $B$。

为了分析这两段信号的潜在关联，需要找到它们之间“共鸣度”最高的子序列对。

1. 子序列 (Subsequence) ：从一个序列中删除任意数量（可以为零）的元素，保持剩下元素的相对顺序不变，所得到的新序列。例如，$[2, 5]$ 是 $[1, 2, 3, 4, 5]$ 的一个子序列，但 $[5, 2]$ 不是。

2. 共鸣度 (Resonance Score) ：对于两个等长的序列，其共鸣度定义为对应位置元素之差的绝对值之和。

例如，对于序列 $X = [x_1, x_2]$ 和 $Y = [y_1, y_2]$，它们的共鸣度为：

$S = |x_1 - y_1| + |x_2 - y_2|$

您的任务是，分别从原始时间序列 $A$ 和 $B$ 中，找出一对长度相同的非空子序列，使得它们的共鸣度最大，并返回这个最大值。

## 输入格式

1. 第一行 : 两个整数 $N$ 和 $M$，分别代表序列 $A$ 和序列 $B$ 的长度。
$1 \le N, M \le 500$
2. 第二行 : $N$ 个整数，代表序列 $A$ 的元素。
每个元素的取值范围为 $[-1000, 100]$。
3. 第三行 : $M$ 个整数，代表序列 $B$ 的元素。
每个元素的取值范围为 $[-1000, 100]$。

## 输出格式

输出一个整数，表示可找到的最大共鸣度。

## 样例

### 样例 1

**输入：**
```
3 3
1 3 5
2 4 6
```

**输出：**
```
6
```

### 样例 2

**输入：**
```
2 2
1 2
3 4
```

**输出：**
```
4
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686375/detail?pid=65176641&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686375/detail?pid=65176641&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.883044+00:00', '2026-07-02T15:19:42.009536+00:00', 2000, 262144, '开发'),
	(131, '地下探险', '地下探险', '华为', 'Medium', 'matrix-grid', '一位勇敢的探险家正准备深入一个神秘的地下洞穴，寻找传说中的古代遗物。

整个洞穴系统可以看作一个二维网格。

探险家每次只能向上、下、左、右四个方向移动一格。

探险家携带的氧气瓶是有限的，最多只够支持连续行走 $k$ 步。

氧气耗尽后，必须立刻找到洞穴内的氧气补给站来补充氧气，否则将无法继续前进。

在补给站，氧气可以被瞬间充满，恢复到最大值（即可再次行走 $k$ 步）。

您的任务是编写一个程序，计算探险家从洞穴入口到达古代遗物所在位置所需的最短路径长度（总步数）。

## 输入格式

输入包含以下部分：

1. 第一行 : 洞穴的尺寸，包含两个整数 $m$ 和 $n$，分别代表网格的行数和列数。
$1 \le m, n \le 1000$

2. 接下来的 $m$ 行 : 每行包含 $n$ 个整数，描述了 $m \times n$ 的洞穴网格。每个整数的含义如下：
0 : 可通行的洞穴路径。
1 : 无法通行的岩壁障碍。
2 : 氧气补给站。

3. 倒数第三行 : 两个整数 $r_s, c_s$，代表探险家出发的入口坐标（左上角为 $(0,0)$）。

4. 倒数第二行 : 两个整数 $r_d, c_d$，代表古代遗物所在的终点坐标。

5. 最后一行 : 一个整数 $k$，代表氧气瓶支持的最大连续移动步数。
$1 \le k \le 100000$

## 输出格式

输出一个整数，表示从入口到遗物所在地的最短路径长度。如果无法到达，则输出 -1 。

## 样例

### 样例 1

**输入：**
```
3 3
0 0 0
0 2 0
0 0 0
0 0
2 2
2
```

**输出：**
```
4
```

### 样例 2

**输入：**
```
3 3
0 0 0
1 1 1
0 0 0
0 0
2 2
2
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686375/detail?pid=65176641&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686375/detail?pid=65176641&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.825581+00:00', '2026-07-02T15:19:53.527603+00:00', 2000, 262144, '开发'),
	(130, '星环-', '星环', '华为', 'Medium', 'intervals', '在一座名为“星环”的巨大环形空间站上，资源仓呈线性排列，首尾相连。

现需要为一艘抵达的货运船，请求一段连续的空闲资源仓用于停靠。

星环的状态由一个十进制 `byte` 序列描述。

序列中的每个数字代表一个“监控单元”，对应着 $8$ 个连续的资源仓。

该数字的二进制表示中的每一位 (`bit`) 描述了一个资源仓的状态：`1` 代表“空闲”，`0` 代表“已被占用”。

为便于管理，所有资源仓从 $0$ 开始统一编号。

若监控单元序列共有 $N$ 个数字，则第一个数字的 `bit 0` 到 `bit 7` 对应 $0 \sim 7$ 号资源仓，第二个数字对应 $8 \sim 15$ 号，以此类推。

第 $N$ 个数字对应 $8N-8 \sim 8N-1$ 号资源仓。

$0$ 号和 $8N-1$ 号资源仓在物理上是相邻的，共同构成了星环的闭环。

货运船当前停靠在 $m$ 号资源仓附近，需要从此位置之后（顺时针方向）寻找一片长度为 $k$ 的连续空闲资源仓。分配时需遵循以下优先级规则：

1. 搜索顺序 ：从 $m+1$ 号资源仓开始，按编号递增方向（$[m+1, 8N-1]$）进行搜索。若未找到，则回到星环起点，继续搜索 $[0, m]$ 区间。

2. 最优匹配 (Best-Fit) ：如果找到多个满足长度要求的连续空闲仓段，优先选择长度最接近 $k$ 的仓段。

3. 最近原则 (Nearest-First) ：在所有“最优匹配”的仓段中，选择起始编号离 $m$ **距离最近**的一个。

4. 距离计算 ：设候选仓段的起始编号为 $j$，总仓位数为 $8N$。

- 若 $j > m$，距离为 $j - m$。

- 若 $j \le m$，距离为 $(j + 8N) - m$。（计算回环距离）

## 输入格式

输入为一个数字序列，包含两部分：

1. 第一行 ：包含两个整数，分别为：
$k$ ：请求的连续资源仓数量，范围 $[0, 65535]$。
$m$ ：当前停靠的资源仓编号，范围 $[0, 3600]$。
2. 第二行及之后 ：描述星环状态的 `byte` 序列（最多 $500$ 个数字），数字之间由空格或换行符分隔，每个数字的范围是 $[0, 255]$。

## 输出格式

输出一个整数，表示最终分配的资源仓段的 起始编号 。
如果无法找到满足条件的资源仓段，则输出 -1 。

## 样例

### 样例 1

**输入：**
```
3 6
59 143
```

**输出：**
```
15
```

### 样例 2

**输入：**
```
3 1
0 0
```

**输出：**
```
-1
```

### 样例 3

**输入：**
```
3 1
61 7
```

**输出：**
```
8
```

### 样例 4

**输入：**
```
2 1
0 254
```

**输出：**
```
9
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686375/detail?pid=65176641&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686375/detail?pid=65176641&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.774076+00:00', '2026-07-02T15:20:06.686894+00:00', 2000, 262144, '开发'),
	(129, '晶体能量阱储量计算', '晶体能量阱储量计算', '华为', 'Medium', 'matrix-grid', '在一个前沿的材料科学研究中，您需要分析一种新型二维晶体材料的能量存储特性。

该晶体可以被建模为一个 $N \times M$ 的矩阵 $P$，其中每个元素 $P_{ij}$ 代表在坐标 $(i, j)$ 处的 势能 。

当某个位置的势能低于其所有可能的逃逸路径上的最低势能壁垒时，该位置就可以被视为一个 能量阱 ，能够存储能量。

晶体矩阵的外部空间被定义为势能恒为 $0$ 的区域。

对于晶体中的任意一点 $(i, j)$，其 逃逸势能 $P_{escape}(i, j)$ 定义为从该点移动到晶体外部的所有可能路径中，路径上遇到的最高势能的最小值。

该点能够存储的能量 $E_{trap}(i, j)$ 为：

$[ E_{trap}(i, j) = \max(0, P_{escape}(i, j) - P_{ij}) ]$

您的任务是计算整个晶体材料能够存储的总能量 $E_{total}$，即所有能量阱存储能量的总和：

$[ E_{total} = \sum_{i=1}^{N} \sum_{j=1}^{M} E_{trap}(i, j) ]$

## 输入格式

第 1 行 : 输入两个整数 $M$ 和 $N$，分别代表晶体矩阵的宽度（列数）和高度（行数）。
其中 $M, N \in [1, 300]$。
第 2 行到第 $N+1$ 行 : 描述了 $N \times M$ 的势能矩阵 $P$。
每行包含 $M$ 个整数，代表该行各点的势能。
每个势能值 $P_{ij} \in [-500, 8000]$。

## 输出格式

输出一个整数，代表整个晶体能够存储的总能量 $E_{total}$。

## 样例

### 样例 1

**输入：**
```
4 5
0 2 3 4
2 -1 -1 4
2 0 -1 3
4 4 4 4
4 0 0 1
```

**输出：**
```
11
```

### 样例 2

**输入：**
```
1 1
-10
```

**输出：**
```
10
```

### 样例 3

**输入：**
```
4 4
0 2 3 4
2 0 0 4
2 0 0 3
4 4 4 4
```

**输出：**
```
8
```

### 样例 4

**输入：**
```
2 2
-500 -500
-500 -500
```

**输出：**
```
2000
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686472/detail?pid=65084866&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686472/detail?pid=65084866&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.714800+00:00', '2026-07-02T15:20:19.465028+00:00', 2000, 262144, '开发'),
	(190, '支配权值划分', '支配权值划分', '美团', 'Medium', 'intervals', '给定一个数组 $t$，定义任意数 $x$ 在 $t$ 中的出现次数为 $\mathrm{cnt}(x)$。称 $t$ 被 $v$ 支配，当且仅当对任意 $v''$ 有 $\mathrm{cnt}(v)\ge \mathrm{cnt}(v'')$；若出现次数相同，则取数值最大的那个$v$。定义数组 $t$ 的权值为 $v \times |t|$（其中 $|t|$ 为 $t$ 的长度）。

现在给定一个长度为 $n$ 的数组 $a_1,a_2,\dots,a_n$，你需要将其划分为若干个非空连续子数组，使得各子数组权值之和最小，输出该最小值。

【子数组】子数组为原数组中任意一个连续且非空的元素区间。

## 输入格式

输入包含多组测试数据。第一行包含整数 $T\left(1\leqq T\leqq 10^3\right)$ 表示测试组数。每组数据描述如下： 
第一行包含一个整数 $n\ \left(1\leqq n\leqq 2\times 10^3\right)$； 
第二行包含 $n$ 个整数，表示数组 $a_1,a_2,\dots,a_n\ \left(-10^9\leqq a_i\leqq 10^9\right)$。 
保证所有测试中 $n$ 的总和不超过 $5\times 10^3$。

## 输出格式

对于每组测试数据，输出一行一个整数，表示将数组划分为若干非空连续子数组后，权值之和的最小值。

## 样例

### 样例 1

**输入：**
```
3
5
1 1 2 2 3
3
5 5 5
4
1 2 3 4
```

**输出：**
```
8
15
10
```

**说明：**
样例一：一种最优划分为 $[1,1,2],[2],[3]$，权值分别为 $1\times3, 2\times1, 3\times1$，总和 $3+2+3=8$。 
样例二：任意划分总和均为 $5\times3=15$。 
样例三：将其划分为单点 $[1],[2],[3],[4]$，总和 $1+2+3+4=10$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:45.157875+00:00', '2026-07-02T16:42:58.875498+00:00', 2000, 262144, '算法'),
	(138, '物流中心包裹分拣', '物流中心包裹分拣', '华为', 'Medium', 'simulation', '你是一家大型物流中心的分拣主管。

一条传送带上源源不断地送来包裹，每个包裹上都标有一个目的地编号。

这一连串的包裹可以看作一个整数数组 $A$。

你的任务是将这一整条传送带上的包裹，划分成最多数量的连续“批次”。

每一个批次会被送到一个独立的机器人处进行整理，机器人会将该批次内的包裹按照目的地编号从小到大排序。

所有批次都整理完毕后，再按照原先批次的先后顺序重新拼接起来。

你需要设计一种划分方案，使得最终拼接好的包裹序列，与将所有包裹一次性进行全局排序的结果完全一致。

请问，你最多能将这些包裹划分成多少个批次？

## 输入格式

输入为一行，包含多个由空格隔开的正整数，代表传送带上每个包裹的目的地编号。

数据范围 :
包裹总数 $N$ 的范围为 $[1, 500]$。
每个包裹的目的地编号 $A_i$ 都是一个正整数。

## 输出格式

输出一个整数，代表最多可以划分的批次数。

## 样例

### 样例 1

**输入：**
```
2 1 3 4 4 5
```

**输出：**
```
5
```

### 样例 2

**输入：**
```
5 4 3 2 1
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686124/detail?pid=65466707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686124/detail?pid=65466707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.174908+00:00', '2026-07-02T15:18:32.551571+00:00', 2000, 262144, '开发'),
	(137, '健身达人每日步数', '健身达人每日步数', '华为', 'Medium', 'simulation', '作为一名健身达人，你坚持每天记录自己的步行数据，并持续了 $N$ 天。

为了更好地激励自己，你定义了一个“突破日”的概念：

如果某一天的步数，严格大于其后任意一天步数的两倍，那么这一天就被称作一个“突破日”。

现在，请你根据这 $N$ 天的步数记录，统计出其中共有多少个“突破日”。

## 输入格式

输入共 2 行：

1. 第一行是一个整数 $N$，代表记录的总天数。
2. 第二行包含 $N$ 个整数 $S_0, S_1, \dots, S_{N-1}$，代表从第 $0$ 天到第 $N-1$ 天，每天的步数记录。

数据范围 :
$0 \le N \le 1000$
$0 \le S_i \le 100000$

## 输出格式

输出一个整数，代表这 $N$ 天中“突破日”的总数量。

## 样例

### 样例 1

**输入：**
```
5
2 4 3 5 1
```

**输出：**
```
3
```

### 样例 2

**输入：**
```
5
1 3 2 3 1
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686124/detail?pid=65466707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686124/detail?pid=65466707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.128879+00:00', '2026-07-02T15:18:45.723223+00:00', 2000, 262144, '开发'),
	(136, '奶茶店特调', '奶茶店特调', '华为', 'Medium', 'heap-priority-queue', '在一家创意奶茶店，你是一位顶级的奶茶制作师。

顾客可以定制一杯独一无二的“千层特调”，这杯奶茶由多种口味的配料堆叠而成。

每种配料都有一个特定的风味编号。

你面前有一张初始配方单，详细记录了要依次添加的 $N$ 层配料的风味编号和它们的添加顺序（从 $0$ 开始编号）。

这个初始的添加顺序将作为这层配料的身份标识。

例如，初始配方单为 `1 1 2 3 4`，则：

身份标识为 $0$ 的配料，其风味编号是 $1$。

身份标识为 $1$ 的配料，其风味编号也是 $1$。

身份标识为 $2$ 的配料，其风味编号是 $2$，以此类推。

制作过程中，顾客可能会提出一些“升级”请求。每个请求会指定一个配料的身份标识。一旦收到请求，如果该身份标识对应的配料还存在于奶茶中，它就会进入“待升级”状态，并遵循以下规则进行融合：

1. 融合规则 1 ：如果某“待升级”的配料层，其下方紧邻的配料层风味编号与它完全相同，那么这两层将融合成一层全新的配料。新配料的风味编号等于原风味编号加 1。

2. 融合规则 2 ：新融合的配料层将继承“待升级”状态，并立即尝试与它下方新的相邻层继续融合，这个过程会不断重复，直到它下方没有相同风味的配料，或者它已成为奶茶的最底层。

3. 融合规则 3 ：通过融合产生的新配料层是“隐藏款”，它没有身份标识。因此，顾客无法通过指令直接指定它进入“待升级”状态。但是，如果上方的配料层在融合后下沉，变为与它相邻，它依然可以作为被动方参与后续的融合。

完成所有顾客的“升级”请求后，你需要计算这杯“千层特调”最终还剩下多少层配料。

## 输入格式

输入共 4 行：

1. 第一行是一个整数 $N$，代表初始配方单上的配料层数。
2. 第二行包含 $N$ 个整数 $I_0, I_1, \dots, I_{N-1}$，代表从下到上每一层配料的风味编号。
3. 第三行是一个整数 $M$，代表顾客提出的“升级”请求数量。
4. 第四行包含 $M$ 个整数 $U_0, U_1, \dots, U_{M-1}$，每个整数代表一个请求，内容是配料的**身份标识**（即它在初始配方单中的位置）。

数据范围 :
$1 \le N \le 10^5$
$1 \le M \le 10^3$
$1 \le I_i \le 30$
$0 \le U_j < N$

## 输出格式

输出一个整数，代表所有操作完成后，奶茶中剩余的配料层数。

## 样例

### 样例 1

**输入：**
```
5
2 2 2 1 1
3
4 1 2
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
12
7 5 4 3 2 1 1 9 8 7 7 10
4
0 10 11 6
```

**输出：**
```
3
```

### 样例 3

**输入：**
```
6
5 4 3 2 1 1
1
5
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686124/detail?pid=65466707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686124/detail?pid=65466707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.082143+00:00', '2026-07-02T15:18:57.051078+00:00', 2000, 262144, '开发'),
	(135, '能量共振', '能量共振', '华为', 'Medium', 'intervals', '在一项对时空连续体的高维研究中，科学家们发现了一种被称为“零点能量共振”的现象。

这种现象表现为在一段连续的时间序列能量读数中，存在一个可以被精确分割成两个连续部分、且每个部分的能量扰动总和都恰好为零的区间。

这种特殊的“对称”共振区间被认为是时空稳定的关键指标。

给定一个记录了 $N$ 个连续时间点能量扰动值的数组 $A$。

数组中的元素为带符号整数。

你的任务是找出其中最短的、能够表现出“零点能量共振”的子数组。

一个子数组被称为“可对称分割”，如果它能被分割成两个连续的子数组，且这两个子数组的元素和都为零。

形式化地说，对于一个子数组 $A[i \dots j-1]$（下标从 $i$ 到 $j-1$），如果存在一个分割点 $k$（其中 $i < k < j$），使得：

$\sum_{p=i}^{k-1} A[p] = 0$ 并且 $\sum_{p=k}^{j-1} A[p] = 0$

那么，这个子数组 $A[i \dots j-1]$ 就是一个满足条件的共振区间。

你的目标是找到所有这类共振区间中，长度最短的一个或多个。

你需要报告这个最短的长度，以及具有该最短长度的共振区间的数量。

## 输入格式

输入包含两行：

第一行是一个整数 $N$，代表时间序列的长度（数组 $A$ 的元素数量）。
$1 \le N \le 10^6$

第二行包含 $N$ 个整数 $X_i$，代表数组 $A$ 的元素。
$-10000 \le X_i \le 10000$

## 输出格式

输出一行，包含两个整数，由空格隔开：
1. 满足条件的最短子数组的长度。
2. 具有该最短长度的子数组的个数。

如果不存在任何满足条件的子数组，则输出 `-1 -1`。

## 样例

### 样例 1

**输入：**
```
5
1 -1 1 -1 1
```

**输出：**
```
4 2
```

### 样例 2

**输入：**
```
7
0 100 1 300 2 10 0
```

**输出：**
```
-1 -1
```

### 样例 3

**输入：**
```
7
100 1 -1 3 -2 -1 100
```

**输出：**
```
5 1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686308/detail?pid=65254753&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686308/detail?pid=65254753&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.033768+00:00', '2026-07-02T15:19:08.013887+00:00', 2000, 262144, '开发'),
	(141, '整理科研数据文件', '整理科研数据文件', '华为', 'Medium', 'hashing', '一位科研人员在进行一系列实验后，得到了大量的以字母和数字混合命名的数据文件，例如 `Exp-A-Run1`, `Exp-A-Run01`, `Exp-A-Run10` 等。

标准的按文件名排序（字典序）会错误地将 `Exp-A-Run10` 排在 `Exp-A-Run2` 之前，这给数据分析带来了不便。

为了解决这个问题，需要一个能够理解数字真实大小的“自然排序”程序。

您能否编写一个程序，对给定的 $N$ 个文件名进行这种特殊的自然排序？

排序规则：

程序需要从左到右逐段比较两个文件名 $A$ 和 $B$：

1. 分段处理 ：将文件名分割成“连续的非数字字符串”和“连续的数字字符串”段落。例如，`ts010tc12` 被视为 `["ts", "010", "tc", "12"]`。

2. 逐段比较 ：

如果 $A$ 和 $B$ 的当前段都是非数字串，则按字典序（区分大小写）进行比较。如果不同，则排序完成。

如果 $A$ 和 $B$ 的当前段都是数字串，则将它们转换为整数值进行比较。如果数值不同，则排序完成。

如果一个是数字串，另一个是非数字串，则规定数字串排在前面。

3. 前缀优先 ：如果一个文件名是另一个文件名的前缀（例如 `test` 和 `testcase1`），则较短的前缀名排在前面。

4. 稳定性 ：排序必须是稳定的。如果根据以上所有规则，两个文件名被认为是等价的（例如 `Run01` 和 `Run1`），它们在输入中的原始相对顺序必须在输出中保持不变。

## 输入格式

第一行：一个整数 $N$，代表待排序的文件名数量。
($1 \le N \le 100$)
接下来 $N$ 行：每行一个文件名 $F_i$。
文件名仅包含大小写字母和数字。
文件名长度在 $[1, 127]$ 范围内。
文件名中任意连续的数字串长度不超过 9。

## 输出格式

共 $N$ 行，每行输出一个排序后的文件名。

## 样例

### 样例 1

**输入：**
```
3
ts1tc1
ts1tc01
ts0tc1
```

**输出：**
```
ts0tc1
ts1tc1
ts1tc01
```

### 样例 2

**输入：**
```
2
testcase10
testcase9
```

**输出：**
```
testcase9
testcase10
```

### 样例 3

**输入：**
```
3
ts09sc1
ts01tc1
ts010tc12
```

**输出：**
```
ts01tc1
ts09sc1
ts010tc12
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686148/detail?pid=65575554&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686148/detail?pid=65575554&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.323414+00:00', '2026-07-02T15:17:12.322032+00:00', 2000, 262144, '开发'),
	(140, '小店的经营分析', '小店的经营分析', '华为', 'Medium', 'intervals', '小张开了一家小小的咖啡店，他习惯于记录每天的盈利状况。

盈利记为正数，亏损则记为负数。

经过一段时间的经营，他收集了连续 $N$ 天的经营数据。

为了评估不同时段的经营效益，小张设定了一个“目标利润区间” $[L, R]$。

他现在想知道，在这 $N$ 天里，有多少个连续的经营周期（例如，从第 $i$ 天到第 $j$ 天），其总利润恰好落在了他设定的目标区间内？

这个问题对小张来说有些复杂，您能编程帮他快速统计出结果吗？

## 输入格式

第一行 : 一个整数 $N$，代表记录的总天数。
($1 < N \le 10000$)
第二行 : $N$ 个整数，代表一个数组 $P$，其中 $P_i$ 表示第 $i$ 天的利润或亏损。
($-255 \le P_i \le 255$)
第三行 : 两个整数 $L$ 和 $R$，用空格隔开，代表目标利润区间的左右边界。
($-2550000 \le L \le R \le 2550000$)

## 输出格式

一个整数，表示总利润在区间 $[L, R]$ 内的连续经营周期的总数量。

## 样例

### 样例 1

**输入：**
```
4
1 -1 1 -1
0 0
```

**输出：**
```
4
```

### 样例 2

**输入：**
```
3
-3 4 -2
-3 2
```

**输出：**
```
5
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686148/detail?pid=65575554&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686148/detail?pid=65575554&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:40.275707+00:00', '2026-07-02T15:17:27.440610+00:00', 2000, 262144, '开发'),
	(134, '助手招募', '助手招募', '华为', 'Medium', 'backtracking', '在一个充满魔法与奇迹的世界里，一位伟大的大魔法师正准备进行一场前所未有的宏大炼金实验。

为了确保实验的成功，他需要招募三名来自不同专精领域的助手：一名“巨龙血脉”（专精火与力量）、一名“精灵之森”（专精自然与敏捷）以及一名“深海智者”（专精水与智慧）。

候选者名单已经拟定。你需要帮助大魔法师从所有候选中，选出三人组成一个完美的团队。团队必须满足以下条件：

1. 团队中必须恰好包含一名“巨龙血脉”、一名“精灵之森”和一名“深海智者”。

2. 为了避免不同派系的魔力产生冲突，所选中的三名助手的魔力印记（即他们所掌握的独特法术符文）不能有任何重合 。

你的任务是找出所有可能的、符合上述条件的团队组合。

## 输入格式

第一行是一个整数 $N$，代表候选者的总数。
$0 < N \le 100$

接下来的 $N$ 行，每行代表一位候选者的信息，格式如下：
$ID$ $T$ $R_1$ $R_2$ $R_3$ $R_4$

$ID$：候选者的唯一编号，是一个整数。($0 < ID \le 100$)
$T$：候选者的专精领域（类型），$1$ 代表“巨龙血脉”，$2$ 代表“精灵之森”，$3$ 代表“深海智者”。
$R_1, R_2, R_3, R_4$：该候选者所拥有的四个魔力印记的编号。印记编号是一个整数，范围为 $[0, 100]$。如果编号为 $0$，则代表该位置没有印记。

## 输出格式

输出所有可能的团队组合。

每一行代表一个组合，格式为：
`巨龙血脉ID 精灵之森ID 深海智者ID`

输出结果需要按照“巨龙血脉”的 $ID$ 升序排序；如果 $ID$ 相同，则按“精灵之森”的 $ID$ 升序排序；如果前两者 $ID$ 也相同，则按“深海智者”的 $ID$ 升序排序。

如果不存在任何满足条件的组合，请输出 `-1`。

## 样例

### 样例 1

**输入：**
```
6
2 2 5 6 7 8
3 3 9 10 11 12
4 2 1 2 3 0
5 1 5 0 7 8
1 1 1 2 3 4
6 1 1 2 3 4
```

**输出：**
```
1 2 3
5 4 3
6 2 3
```

### 样例 2

**输入：**
```
4
1 1 1 2 3 4
2 2 5 6 7 8
3 3 9 10 11 12
4 2 13 14 15 16
```

**输出：**
```
1 2 3
1 4 3
```

### 样例 3

**输入：**
```
1
1 1 1 2 3 4
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686308/detail?pid=65254753&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686308/detail?pid=65254753&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.982976+00:00', '2026-07-02T15:19:20.125161+00:00', 2000, 262144, '开发'),
	(128, '神经网络信号传播预测', '神经网络信号传播预测', '华为', 'Medium', 'matrix-grid', '您正在为一个先进的神经形态计算平台设计一个信号传播模拟器。

该平台的核心是一个二维神经元矩阵 $M$，矩阵中的每个单元可以是 非导电介质（值为 $0$），也可以是具有特定 激活延迟 的 神经元（值为 $1$ 到 $k$ 的正整数）。

信号在矩阵中按以下规则传播：

当一个神经元被激活后，它会经历一段等于其激活延迟时间的内部处理。

处理完成后，它会立即向其上、下、左、右四个相邻的神经元发送激活信号。

您的任务是，给定一个初始被激活的神经元集合 $S$ 和一个特定的目标神经元 $T$，计算出目标神经元 $T$ 被 首次激活 的最早时间。

如果目标神经元的位置是非导电介质，或者信号无论如何都无法传播到该位置，则返回 $-1$。

## 输入格式

输入数据包含以下几个部分：

1. 二维神经元矩阵 $M$ : 
其维度为 $m \times n$，其中 $0 < m, n \le 100$。矩阵中的每个元素 $M_{ij}$ 代表该位置的单元类型：$0$ 表示非导电介质，正整数表示神经元的激活延迟。

2. 初始激活源 $S$ : 
一个由多个坐标组成的集合 $S = \{(x_i, y_i) | 0 \le x_i < m, 0 \le y_i < n\}$。激活源的数量小于 $5$。

3. 目标神经元 $T$ : 
单个坐标 $T = (a, b)$，其中 $0 \le a < m, 0 \le b < n$。

输入格式 :

第 1 行 : 矩阵的维度 $m$ 和 $n$，由空格分隔。
第 2 行到第 $m+1$ 行 : 神经元矩阵 $M$ 的内容，每行代表矩阵的一行，行内数字由空格分隔。
第 $m+2$ 行 : 初始激活源 $S$ 的坐标。例如，`x1 y1 x2 y2 ...` 表示集合 $\{(x_1, y_1), (x_2, y_2), ...\}$。
第 $m+3$ 行 : 目标神经元 $T$ 的坐标 `a b`。

## 输出格式

一个整数，表示信号传播到目标神经元 $T$ 所需的最短时间。
如果无法到达，则输出 $-1$。

## 样例

### 样例 1

**输入：**
```
3 3
1 2 0
0 3 1
1 0 2
0 0 2 0
2 2
```

**输出：**
```
7
```

### 样例 2

**输入：**
```
3 3
1 0 0
0 3 1
1 0 2
0 0 2 0
2 2
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686472/detail?pid=65084866&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686472/detail?pid=65084866&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.649438+00:00', '2026-07-02T15:20:31.973705+00:00', 2000, 262144, '开发'),
	(126, '荧光森林的共鸣路径', '荧光森林的共鸣路径', '华为', 'Medium', 'tree', '在一片神秘的荧光森林中，生长着一种名为“辉光之树”的奇特植物。

这些植物的根系在地底深处交织成一张巨大的网络，形成了一棵宏伟的二叉树结构。

每株植物都是树上的一个节点，并且自身储存着一定的能量。

作为一名探索这片森林的植物学家，您发现当能量以一种特定的“之字形”模式在植物间传导时，会引发壮观的“能量共鸣”现象。

您的任务是找出这片森林中所有可能形成的、总能量值恰好等于特定值的共鸣路径。

给定一个由 $N$ 株荧光植物构成的二叉树，以及一个目标能量值 $E$。您需要计算出满足以下条件的 共鸣路径 的总数量。

路径 (Path) : 一条有效的路径必须从树中的任意一个节点开始，并一直延伸到某个 叶子节点（没有子节点的植物）结束。

共鸣路径 (Resonance Path) : 一条路径要被称为“共鸣路径”，其上的节点序列必须遵循“之字形”的能量传导规则，并且路径长度至少为3。规则如下：

1. 从父节点到第一个子节点的方向是任意的（左或右）。

2. 此后，能量的传导方向必须严格交替。即，如果上一步是“父 -> 左子”，则下一步必须是“当前 -> 右子”；如果上一步是“父 -> 右子”，则下一步必须是“当前 -> 左子”。

* 例如：`父 -> 左子 -> 右子 -> 左子 -> ... -> 叶子节点`

* 或者：`父 -> 右子 -> 左子 -> 右子 -> ... -> 叶子节点`

任务目标 : 找出所有满足“路径上所有植物的能量值之和等于目标能量 $E$ ”的 共鸣路径 的数量。

## 输入格式

第一行 : 一个整数 $N_{nodes}$，表示辉光之树的节点总数。 ($1 \le N_{nodes} \le 1024$)
第二行 : 一个包含 $N_{nodes}$ 个整数的数组 $V$。$V_i$ 代表二叉树中第 $i$ 个节点（植物）的能量值。
能量值 $V_i \ge 0$。
若某个位置的值为 $-1$，表示该节点在树的结构中不存在。
建树规则 : 数组 $V$ 是树的层序遍历表示。例如，$V_0$ 是根节点，$V_1, V_2$ 分别是根的左右子节点，$V_3, V_4, V_5, V_6$ 是下一层的节点，以此类推。
第三行 : 一个整数 $E$，代表目标能量和。 ($0 \le E \le 10000$)

## 输出格式

输出一个整数，表示路径能量和恰好为 $E$ 的共鸣路径总数。
如果不存在任何共鸣路径（例如，树的深度不足以形成长度为3的路径），则输出 $-1$。

## 样例

### 样例 1

**输入：**
```
10
3 2 1 2 1 4 1 -1 -1 5
8
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
3
2 3 1
4
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686416/detail?pid=65076727&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686416/detail?pid=65076727&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.530771+00:00', '2026-07-02T15:21:25.471893+00:00', 2000, 262144, '开发'),
	(122, '云服务器资源优化', '云服务器资源优化', '华为', 'Medium', 'backtracking', '您是一位顶尖的云计算工程师，负责为一个客户在数据中心部署一组高性能计算服务。

您拥有一台物理服务器，但这台服务器的总功耗预算是有限的。

现在，您需要从一系列待选服务中，挑选出一个最优的组合进行部署，以在满足功耗限制的前提下，实现最大的计算价值。

现有 $n$ 个待部署的计算服务，按 $1$ 到 $n$ 升序编号，服务器的总功耗预算为 $K$。

对于每个服务 $i$，我们有两个关键指标：

功耗（Power Consumption）: $c_i$

计算价值（Computing Value）: $v_i$

您的任务是选择一个服务的组合，同时满足以下两个条件：

1. 所有被选中服务的总功耗之和不得超过服务器的功耗预算 $K$，即 $\sum c_i \le K$。

2. 所有被选中服务的总计算价值之和 $\sum v_i$ 应达到最大。

## 输入格式

第一行是一个整数 $n$，表示待选服务的总数，其中 $1 \le n \le 50$。
第二行是一个整数 $K$，表示服务器的总功耗预算，其中 $1 \le K \le 1000$。
接下来的 $n$ 行，每行代表一个服务。第 $i$ 行包含两个整数 $c_i$ 和 $v_i$，分别代表编号为 $i$ 的服务的功耗和计算价值。
$1 \le c_i \le 100$
$1 \le v_i \le 1000$

## 输出格式

输出您最终选择的服务组合的编号，编号按从小到大排序，并用空格隔开。

择优规则（注意优先级）：
1. 如果没有任何一个服务组合能满足功耗预算，则输出 -1 。
2. 如果存在多个服务组合都能达到相同的最高总计算价值，则在这些组合中，选择总功耗最小的那个。
3. 如果在满足前一个条件后仍有多个组合，则在这些组合中，选择包含服务数量最少的那个。
4. 题目保证在上述所有规则的约束下，最终只会有一组唯一的最优解。

## 样例

### 样例 1

**输入：**
```
5
80
30 400
45 470
15 200
15 200
80 870
```

**输出：**
```
1 2
```

### 样例 2

**输入：**
```
1
80
100 300
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686405/detail?pid=64952987&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686405/detail?pid=64952987&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:39.299201+00:00', '2026-07-02T15:22:33.528641+00:00', 2000, 262144, '开发'),
	(116, '星际勘探任务', '星际勘探任务', '华为', 'Medium', 'simulation', '一名星际探险家正在规划一次勘探任务。已知宇宙中有 $n$ 个未探索的星球，探险家的飞船总共有 $T$ 单位的续航时间和 $H$ 单位的能量储备。

对于第 $i$ 个星球，进行勘探需要花费 $t_i$ 的续航时间、消耗 $h_i$ 的能量，并能够获得价值为 $a_i$ 的科学数据。

请问，在总续航时间不超过 $T$、总能量消耗不超过 $H$ 的前提下，探险家最多可以获得多少总价值的科学数据？

数据范围提示：$1 \le n \le 100$，其他所有输入数值均为正整数。

## 输入格式

第一行输入一个正整数 $n$，代表待勘探星球的数量。

第二行输入两个正整数 $T$ 和 $H$，分别代表续航时间上限和能量储备上限。

接下来的 $n$ 行，每行输入三个正整数 $t_i, h_i, a_i$，分别代表勘探第 $i$ 个星球所需的时间、消耗的能量以及能获得的科学数据价值。

## 输出格式

输出一个整数，代表能够获得的最大科学数据总价值。

## 样例

### 样例 1

**输入：**
```
9
35 35
5 1 22
4 2 11
3 9 48
2 3 22
1 4 41
5 2 38
9 4 96
8 1 98
7 8 62
```

**输出：**
```
405
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686204/detail?pid=64837923&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686204/detail?pid=64837923&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.978066+00:00', '2026-07-02T15:23:48.300902+00:00', 2000, 262144, '开发'),
	(113, '无人机物流网络最优路径规划', '无人机物流网络最优路径规划', '华为', 'Medium', 'graphs', '在一座未来城市中，一个高度自动化的无人机物流网络负责着全城的包裹配送。

这个网络由 $n$ 个配送站 $S_1, S_2, \dots, S_n$ 组成。

无人机可以在这些配送站之间沿着预设的空中走廊进行飞行。

每条空中走廊连接两个配送站，并且是双向通行的。

由于距离、风阻等因素，无人机飞过每条走廊都需要消耗一定的能量，记为 $E_{uv}$。

这个能耗是固定的，且双向飞行的能耗相同 ($E_{uv} = E_{vu}$)。

当一个配送任务下达时，系统需要从起始站 $S_{start}$规划出一条到达目的站 $S_{end}$ 的、总能耗最低的飞行路径。

无人机的导航系统遵循最短路径原则。对于一个从 $S_{start}$ 到 $S_{end}$ 的任务，系统会计算出一条或多条总能耗最低的路径。

无人机从起始站出发的第一站被称为下一跳。由于可能存在多条能耗并列最低的路径，因此下一跳也可能不止一个。

您的任务是：给定整个物流网络的布局和各条走廊的能耗，并指定起始站和目的站，计算出：

1. 完成该配送任务所需的最低总能耗。

2. 无人机从起始站出发的所有可能的下一跳站点的集合。

## 输入格式

第一行包含两个整数 $N$ 和 $K$，分别代表配送站的总数和空中走廊的数量。
$1 \le N \le 1000$
$1 < K \le \frac{N \times (N-1)}{2}$

接下来的 $K$ 行描述了空中走廊的信息。每行包含三个正整数 $u, v, e$，分别代表这条走廊连接的两个配送站的编号 $S_u, S_v$ 和飞行所需的能耗 $E_{uv}$。
$1 \le E_{uv} \le 100$
站点编号 $u, v$ 的范围在 $[1, N]$ 内。

最后一行包含两个正整数 $S_{start}$ 和 $S_{end}$，代表任务的起始站和目的站。

## 输出格式

输出共两行：

第一行为一个整数，表示从 $S_{start}$ 到 $S_{end}$ 的最低总能耗。
第二行为一个或多个正整数，代表所有可能的下一跳站点的编号。请将这些编号按升序排列，并用单个空格分隔。

特殊情况：
1. 如果目的站 $S_{end}$ 无法从起始站 $S_{start}$ 到达，则最低能耗输出 `-1`，下一跳集合也输出 `-1`。
2. 如果起始站与目的站相同 ($S_{start} = S_{end}$)，则最低能耗为 `0`，下一跳集合输出 `-1`。

## 样例

### 样例 1

**输入：**
```
19 71
7 9 98
9 14 98
6 11 27
2 10 8
6 8 2
10 11 68
16 17 34
2 13 29
13 18 70
5 7 46
1 5 76
5 12 96
5 17 18
11 16 91
3 18 45
8 10 76
7 13 20
2 9 21
8 12 96
7 10 37
6 16 45
15 19 32
4 11 15
2 6 46
7 11 32
6 13 38
9 18 44
8 14 42
18 19 80
4 7 75
6 9 51
9 12 64
10 13 26
1 13 10
10 15 69
10 19 69
2 19 16
11 12 24
17 19 15
13 17 48
13 16 84
3 11 31
1 9 10
15 16 49
3 8 69
7 8 31
4 15 96
5 8 45
9 10 12
9 16 78
10 17 20
5 18 5
8 17 39
5 6 48
4 16 40
14 16 15
13 15 65
10 16 43
12 18 74
1 14 83
1 10 18
2 5 55
12 16 41
4 18 13
5 16 59
9 13 14
4 8 2
4 12 45
14 18 97
12 17 17
4 13 40
16 18
```

**输出：**
```
53
4
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686350/detail?pid=64696342&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686350/detail?pid=64696342&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.826519+00:00', '2026-07-02T15:24:23.248604+00:00', 2000, 262144, '开发'),
	(111, '农田最大产出评估', '农田最大产出评估', '华为', 'Medium', 'backtracking', '一位农业科学家正在评估一块狭长试验田的生产潜力。这块试验田被划分为 $n$ 个连续的地块，每个地块都有一个特定的“肥力指数”。

当一组连续的地块被用来种植同一种作物时，整个组的最终产出受到该组中肥力最差的那个地块的限制。这种效应可以用一个“产出系数”来量化，其计算公式为：

产出系数 = 组内最低肥力指数 $\times$ 组内地块数量

作为项目负责人，你需要分析所有可能的连续地块组合，计算它们的产出系数，并找出其中可能达到的最大值，以制定最优的种植计划。

给定一个正整数数组 $F$，代表了一系列连续地块的肥力指数。你需要计算所有连续非空地块组合的产出系数，并返回其中的最大值。

连续非空地块组合：指一组在原序列中相邻的地块。例如，肥力指数序列为 [10, 20, 30] 的组合包括：

- [10]、[20]、[30]

- [10, 20]、[20, 30]

- [10, 20, 30]

## 输入格式

- 第一行：一个整数 $n$，表示地块的总数，其中 $1 \le n \le 10^4$。
- 接下来 $n$ 行：每行一个整数，代表第 $i$ 个地块的肥力指数 $F_i$，其中 $1 \le F_i \le 10^4$。

## 输出格式

- 输出一个整数，代表所有连续组合中可以达到的最大产出系数。

## 样例

### 样例 1

**输入：**
```
8
51
50
50
1
14
32
15
2
```

**输出：**
```
150
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686254/detail?pid=64590300&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686254/detail?pid=64590300&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.702179+00:00', '2026-07-02T15:25:04.307900+00:00', 2000, 262144, '开发'),
	(110, '分布式计算任务调度', '分布式计算任务调度', '华为', 'Medium', 'simulation', '一个分布式计算系统中有 $M$ 个处理节点，所有节点的初始负载均为零。

现在有 $N$ 个计算任务需要处理，这些任务按其依赖关系顺序编号，ID 从 $0$ 到 $N-1$。

你需要设计一个任务分配方案，使得各计算节点间的负载差异最小化。

说明：

- 任务分配完成后，负载最高的节点的负载量记为 $X$。

- 负载最低的节点的负载量记为 $Y$。

- 你的目标是找到一种分配方案，使得 $X - Y$ 的值最小。

任务的分配必须满足以下严格的约束条件：

1. 顺序性：对于任意节点编号 $i < j$，分配给节点 $i$ 的所有任务的 ID 必须小于分配给节点 $j$ 的所有任务的 ID。

2. 连续性：分配给同一个节点的一组任务，它们的 ID 必须是连续的。

3. 原子性：单个任务不可拆分，必须完整地分配给一个节点。

## 输入格式

- 第一行：两个整数 $N$ 和 $M$。
- $N$ 是任务的总数，其范围为 $1 \le N \le 1000$。
- $M$ 是计算节点的数量，其范围为 $1 \le M \le N$。
- 第二行：$N$ 个整数 $C_0, C_1, \dots, C_{N-1}$，其中 $C_i$ 代表 ID 为 $i$ 的任务所需的计算量。计算量的范围为 $1 \le C_i \le 100000$。

## 输出格式

输出在最优分配方案下，负载最高的节点的负载量 $X$。

## 样例

### 样例 1

**输入：**
```
6 5
32 44 98 73 46 98
```

**输出：**
```
98
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686254/detail?pid=64590300&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686254/detail?pid=64590300&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.648506+00:00', '2026-07-02T15:25:18.496749+00:00', 2000, 262144, '开发'),
	(106, '分布式系统任务调度', '分布式系统任务调度', '华为', 'Medium', 'tree', '在一个大规模的分布式计算系统中，任务被分配到不同的计算节点上执行。这些节点构成了一个二叉树结构的集群。树的每个节点代表一个计算单元，树的层级越低则其优先级越高。高优先级的节点作为主控节点，负责管理其子树中的所有下级节点。每个节点都有一个唯一的ID，该ID为一个整数，其取值范围是 $[0, 10^9]$。

为了进行资源优化和故障排查，需要开发一个统计工具。对于系统中的任意两个节点，此工具需要能够找到它们在集群中层级最低的共同主控节点，并返回该主控节点所管辖的节点总数。

注意：如果两个节点本身存在主控与被控关系，那么它们的最低共同主控节点就是层级较高的那个节点。

节点总数 $N \le 10^5$。待查询的两个节点ID保证存在于给定的二叉树中，且两个ID不相同。

## 输入格式

第一行输入一个整数 $N$，表示二叉树的节点个数。

第二行输入 $N$ 个整数，由空格分隔，表示该二叉树的层序遍历序列。序列中的每个数字代表一个节点的ID，若节点为空，则以 $-1$ 表示。

第三行输入两个整数 $id_1$ 和 $id_2$，由空格分隔，表示待查询的两个节点ID。

## 输出格式

输出一个整数，表示两个节点最低共同主控节点所管辖的节点总数（不包括该主控节点自身）。

## 样例

### 样例 1

**输入：**
```
32
779918796 318972227 438409225 978222897 308012767 977989517 -1 723465180 86743435 -1 -1 538495872 263870840 -1 -1 455584908 -1 -1 -1 -1 -1 -1 -1 -1 -1 501120465 -1 -1 -1 -1 -1 72051133
308012767 538495872
```

**输出：**
```
12
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686188/detail?pid=64451294&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686188/detail?pid=64451294&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.429213+00:00', '2026-07-02T15:26:11.466505+00:00', 2000, 262144, '开发'),
	(101, '算法配置', '算法配置', '华为', 'Medium', 'intervals', '一个系统支持多种算法，每种算法使用一个正整数 ID 来唯一标识。管理员可以分批次地启用或禁用这些算法。

您需要编写一个程序，根据一份操作日志，计算出最终处于“启用”状态的所有算法 ID。

## 输入格式

- 第一行是一个整数 $N$，代表操作日志中的记录总数。
- 接下来的 $N$ 行，每行是一条操作记录。
- 操作记录分为两种：
1. `algorithm <ranges>`：表示 **启用** 指定范围内的所有算法。
2. `undo algorithm <ranges>`：表示 **禁用** 指定范围内的所有算法。
- `<ranges>` 是一个由逗号 `,` 分隔的字符串，用于描述算法 ID 的范围。
- 范围可以是一个单独的 ID，如 `8`。
- 也可以是一个闭区间，如 `1-100`。
- 也可以是两者的混合，如 `1-10,15-20` 或 `6,7,8,9-10`。
- 所有算法 ID 均为正整数。

## 输出格式

- 输出一行，代表经过所有操作后，最终处于“启用”状态的算法 ID 集合。
- 输出结果需要被合并为最简的、无重叠的、升序排列的区间。
- 格式与输入的 `<ranges>` 部分相同。
- 如果最终没有启用的算法，则输出一个空行。

## 样例

### 样例 1

**输入：**
```
5
undo algorithm 59,99-99
algorithm 10,15-37,35
algorithm 73
undo algorithm 72,56-94,62-71
undo algorithm 70,37-90
```

**输出：**
```
10,15-36
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97683691/detail?pid=63699019&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97683691/detail?pid=63699019&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:38.158503+00:00', '2026-07-02T15:27:18.383942+00:00', 2000, 262144, '开发'),
	(97, '爱丽丝的人偶依赖协议', '爱丽丝的人偶依赖协议', '华为', 'Medium', 'simulation', '人偶师爱丽丝正在整理她复杂的“人偶通信网络”。在这个网络中，每个人偶或部件由一个正整数编号表示。若人偶 $u$ 的运作依赖于部件 $v$，则会记录一条依赖关系 $(u, v, w)$，其中 $w$ 表示 $v$ 必须达到的最低魔法等级（版本号）。

爱丽丝发现，如果依赖关系中存在循环依赖（即一组人偶构成了环，或者某个人偶直接依赖于自身），整个网络就会陷入瘫痪。若不存在循环依赖，为了确保系统稳定性，对于任何被依赖的部件 $v$，其实际采用的版本号应为所有指向 $v$ 的依赖关系中所要求的 $w$ 的最大值。

你需要帮助爱丽丝检查网络的稳定性。如果网络稳定，请按原顺序输出更新版本号后的所有依赖关系。

## 输入格式

输入包含恰好两组测试数据。

对于每组数据：

第一行包含一个正整数 $n$ ($0 < n < 100$)，表示依赖关系的数量。

接下来的 $n$ 行，每行包含一个形如 `u,v,version` 的字符串（由逗号分隔），表示人偶 $u$ 依赖于部件 $v$，且要求的版本号为 $version$。

数据范围：

- 编号 $u, v$ 为正整数，且 $1 \leqq u, v \leqq 10^9$。

- 版本号 $1 \leqq version \leqq 99$。

- 在同一组数据中，同一个依赖序对 $(u, v)$ 最多出现一次。

## 输出格式

对于每组测试数据：

- 如果存在循环依赖，输出一行 `false`。

- 如果不存在循环依赖，对于每一条输入的依赖关系 `u,v,version`，将 $version$ 更新为所有以 $v$ 为被依赖对象的条目中 $version$ 的最大值，并按输入顺序输出更新后的关系，格式为 `u,v,max_version`。

## 样例

### 样例 1

**输入：**
```
3
1,2,23
2,3,34
4,2,25
3
1,2,23
2,3,34
3,1,12
```

**输出：**
```
1,2,25
2,3,34
4,2,25
false
```

**说明：**
在第一组样例中：

- 人偶 1 依赖 2（版本 23），人偶 4 也依赖 2（版本 25）。因此部件 2 的最大需求版本为 25。

- 人偶 2 依赖 3（版本 34）。因此部件 3 的最大需求版本为 34。

- 网络中不存在环，故按原输入顺序输出更新后的三条记录。

在第二组样例中：

- 1 依赖 2，2 依赖 3，3 依赖 1，构成了闭环，故输出 `false`。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97686270/detail?pid=67103538&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686270/detail?pid=67103538&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:16:37.906388+00:00', '2026-07-02T15:28:18.614250+00:00', 2000, 262144, '开发'),
	(196, '链表内指定区间反转', '链表内指定区间反转', '牛客', 'Medium', 'linked-list', '将一个节点数为 size 链表 m 位置到 n 位置之间的区间反转，要求时间复杂度 $O(n)$，空间复杂度 $O(1)$。

例如：

给出的链表为 $1\to 2 \to 3 \to 4 \to 5 \to NULL$, $m=2,n=4$,

返回 $1\to 4\to 3\to 2\to 5\to NULL$.

数据范围： 链表长度 $0 < size \le 1000$，$0 < m \le n \le size$，链表中每个节点的值满足 $|val| \le 1000$

要求：时间复杂度 $O(n)$ ，空间复杂度 $O(n)$

进阶：时间复杂度 $O(n)$，空间复杂度 $O(1)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,3,4,5},2,4
```

**输出：**
```
{1,4,3,2,5}
```

### 样例 2

**输入：**
```
{5},1,1
```

**输出：**
```
{5}
```

### 样例 3

**输入：**
```
{1,2,3,4},1,4
```

**输出：**
```
{4,3,2,1}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/b58434e200a648c589ca2063f1faf58c?tpId=295&tqId=654&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/b58434e200a648c589ca2063f1faf58c?tpId=295&tqId=654&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.092674+00:00', '2026-07-03T12:10:12.768091+00:00', 2000, 262144, '常见101'),
	(143, '小红的星屑共鸣', '小红的星屑共鸣', '华为', 'Medium', 'hashing', '小红是一位热衷于探索宇宙奥秘的星际旅行者。最近，她在银河系的边缘发现了一片古老的星云，这里漂浮着许多蕴含神秘能量的“星屑”。

小红通过她的飞船雷达扫描了这片区域，将每一颗星屑的位置都映射到了一个二维平面坐标系中。根据古老的传说，当两颗星屑的距离越近，它们之间产生的“共鸣波动”就越强烈。为了寻找能量最纯净的共鸣源，小红需要找出这片区域中距离最近的两颗星屑。

为了避免处理浮点数带来的精度误差，飞船的主控电脑（也就是你）被要求计算这两颗星屑之间欧几里得距离的平方。

形式化地讲，给定平面上 $n$ 个点的坐标，你需要找到两个点 $(x_i, y_i)$ 和 $(x_j, y_j)$（其中 $i \neq j$），使得它们的距离平方 $D = (x_i - x_j)^2 + (y_i - y_j)^2$ 最小，并输出这个最小值。

## 输入格式

第一行包含一个整数 $n$，表示星屑的数量。

接下来的 $n$ 行，每行包含两个整数 $x$ 和 $y$，表示一颗星屑在平面上的坐标。

$2 \leqq n \leqq 100,000$
$-100,000 \leqq x, y \leqq 100,000$

## 输出格式

输出一个整数，表示所有星屑对中，最小的距离平方值。

## 样例

### 样例 1

**输入：**
```
5
0 0
0 5
3 4
3 5
3 6
```

**输出：**
```
1
```

**说明：**
在样例中，最近的一对星屑坐标分别为 $(3, 4)$ 和 $(3, 5)$。
它们之间的距离平方计算如下：
$(3 - 3)^2 + (5 - 4)^2 = 0^2 + 1^2 = 1$
没有其他点对的距离平方小于 1。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686586/detail?pid=65783042&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686586/detail?pid=65783042&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:32.922230+00:00', '2026-07-02T15:32:36.754864+00:00', 2000, 262144, '开发'),
	(142, '小红的星尘收集', '小红的星尘收集', '华为', 'Medium', 'simulation', '小红正在星际之间进行探险，她意外发现了一条由星尘凝聚而成的璀璨银河。这条银河可以看作是一个线性的序列，序列中散落着若干团蕴含能量的星尘。

每团星尘都有其固定的能量值 $a_i$。小红拥有特殊的采集手套，可以收集这些星尘来为她的飞船充能。然而，星尘之间存在着一种不稳定的“量子纠缠”现象：如果小红采集了第 $i$ 个位置的星尘，由于能量场的剧烈波动，与其相邻的第 $i-1$ 个位置和第 $i+1$ 个位置的星尘将会立刻消散，无法再被收集。

为了能够顺利飞往下一个星系，小红需要制定一个完美的采集计划。请你帮她计算一下，在遵守上述物理规则的前提下，她最多能收集到多少能量？

## 输入格式

输入包含一行，由若干个以空格分隔的整数组成。
这些整数分别代表序列中每团星尘的能量值 $a_i$。
- 星尘的总数量 $n$ 满足：$1 < n < 500$
- 每个星尘的能量值 $a_i$ 满足：$0 \leqq a_i \leqq 10000$

## 输出格式

输出一个整数，代表小红能获得的能量值之和的最大值。

## 样例

### 样例 1

**输入：**
```
2 7 10 3 2
```

**输出：**
```
14
```

**说明：**
小红选择了第 1 个星尘（能量值 2）、第 3 个星尘（能量值 10）和第 5 个星尘（能量值 2）。
总能量 = $2 + 10 + 2 = 14$。
由于选择了第 3 个星尘，她无法选择第 2 个（能量 7）和第 4 个（能量 3）。
如果小红尝试选择能量值最高的 7 和 3，总和为 10，不如上述方案优。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686586/detail?pid=65783042&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686586/detail?pid=65783042&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:32.856831+00:00', '2026-07-02T15:32:50.012268+00:00', 2000, 262144, '开发'),
	(209, '删除有序链表中重复的元素-I', '删除有序链表中重复的元素-I', '牛客', 'Easy', 'linked-list', '删除给出链表中的重复元素（链表中元素从小到大有序），使链表中的所有元素都只出现一次
例如：
给出的链表为$1\to1\to2$,返回$1 \to 2$.
给出的链表为$1\to1\to 2 \to 3 \to 3$,返回$1\to 2 \to 3$. 

数据范围：链表长度满足 $0 \le n \le 100$，链表中任意节点的值满足 $|val| \le 100$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(n)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,1,2}
```

**输出：**
```
{1,2}
```

### 样例 2

**输入：**
```
{}
```

**输出：**
```
{}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c087914fae584da886a0091e877f2c79?tpId=295&tqId=664&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c087914fae584da886a0091e877f2c79?tpId=295&tqId=664&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.714058+00:00', '2026-07-03T12:10:47.589017+00:00', 2000, 262144, '常见101'),
	(148, '小红的岁晚可可塔', '小红的岁晚可可塔', '华为', 'Medium', 'intervals', '除夕之夜，小红正在为年夜饭准备一道名为“岁晚可可塔”的创意甜品。这道甜品由 $n$ 层厚度均匀的巧克力蛋糕叠成，每一层都加入了不同比例的可可粉或糖浆。

具体来说，第 $i$ 层蛋糕有一个“甜度值” $a_i$。如果 $a_i > 0$，表示这一层口感香甜；如果 $a_i < 0$，则表示这一层由于可可含量过高而带有苦味。为了保证口感的连贯性，小红需要从这 $n$ 层蛋糕中切出连续的非空区间 $[l,r]$ 作为最终成品，使得这段蛋糕的甜度总和达到最大。

请你帮助小红计算出，在这 $n$ 层蛋糕中，连续的一段蛋糕层所能达到的最大甜度总和是多少。

## 输入格式

输入共包含两行：
第一行包含一个整数 $n$（$1 \leqq n \leqq 1000$），代表可可塔的总层数。
第二行包含 $n$ 个整数 $a_1, a_2, \dots, a_n$，用空格分隔，表示每一层蛋糕的甜度值。每个甜度值的范围为 $[-100000, 100000]$。

## 输出格式

输出一个整数，表示连续的一段蛋糕层能够达到的最大甜度总和。

## 样例

### 样例 1

**输入：**
```
7
2 -4 3 -1 2 -4 3
```

**输出：**
```
4
```

**说明：**
在样例中，$n=7$，各层的甜度值分别为 $[2, -4, 3, -1, 2, -4, 3]$。

若选择第 $3$ 层到第 $5$ 层（对应的甜度值为 $3, -1, 2$），其甜度总和为 $3 + (-1) + 2 = 4$。

经计算，这是所有连续方案中所能得到的最大甜度总和。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686570/detail?pid=66224883&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686570/detail?pid=66224883&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.197659+00:00', '2026-07-02T15:31:43.469086+00:00', 2000, 262144, '开发'),
	(146, '幻兽防御战', '幻兽防御战', '华为', 'Medium', 'simulation', '小红正在守卫一座神秘遗迹，共有 $n$ 只怪兽正向遗迹冲来。

第 $i$ 只怪兽的初始距离为 $dist_i$，移动速度为 $speed_i$。小红拥有一把每分钟只能发射一次的弩箭，在第 $k$ 分钟开始的瞬间（$k = 0, 1, 2, \dots$），小红可以消灭任意一只尚未到达遗迹的怪兽。

对于第 $i$ 只怪兽，其到达遗迹的时间为 $t_i = dist_i / speed_i$。如果存在某只未被消灭的怪兽满足 $t_i \leqq k$，则该怪兽会在小红准备好第 $k$ 次射击时或之前抵达并摧毁遗迹，防守立即失败。

请帮小红计算，在遗迹被摧毁前，她最多能消灭多少只怪兽。

## 输入格式

输入共三行。
第一行包含一个整数 $n$（$1 \leqq n \leqq 10^5$），表示怪兽的数量。
第二行包含 $n$ 个整数 $dist_1, dist_2, \dots, dist_n$（$1 \leqq dist_i \leqq 10^5$），表示每只怪兽的初始距离。
第三行包含 $n$ 个整数 $speed_1, speed_2, \dots, speed_n$（$1 \leqq speed_i \leqq 20$），表示每只怪兽的移动速度。

## 输出格式

输出一个整数，表示小红最多能消灭的怪兽数量。

## 样例

### 样例 1

**输入：**
```
3
1 4 4
5 2 3
```

**输出：**
```
2
```

**说明：**
样例中三只怪兽的预期到达时间分别为 $0.2, 2.0, 1.33$：

- 第 0 分钟：小红准备好第 1 次射击，消灭第 1 只怪兽（到达时间 0.2）。

- 第 1 分钟：小红准备好第 2 次射击，消灭第 3 只怪兽（到达时间 1.33）。

- 第 2 分钟：最后一只怪兽的到达时间为 $2.0$。此时小红刚准备好第 3 次射击，但怪兽已经同时到达遗迹，防御失败。

因此，小红总共能消灭 2 只怪兽。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686596/detail?pid=66224876&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686596/detail?pid=66224876&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.089886+00:00', '2026-07-02T15:32:04.255949+00:00', 2000, 262144, '开发'),
	(145, '魔法相册的重复记忆', '魔法相册的重复记忆', '华为', 'Medium', 'backtracking', '小红正在整理自己的 $n$ 本魔法相册，她发现有些珍贵的记忆（照片）由于备份原因，同时出现在了多本相册中。

每张照片由一个唯一的标识符 $id$ 和一个时间戳 $t$ 组成。在一个相册内部，所有照片的 $id$ 互不相同；但在不同的相册之间，可能存在 $id$ 相同的照片。已知相同的 $id$ 总是对应相同的时间戳 $t$。

小红需要找出所有在超过一本相册中出现过的照片，并统计它们在所有相册中出现的总次数。请将这些重复的照片按照时间戳 $t$ 从小到大排序后输出。

## 输入格式

第一行输入一个整数 $n$（$0 < n < 10$），表示相册的数量。

接下来的 $n$ 行，每行包含若干个由空格分隔的整数，表示该相册内的照片信息。每两个整数为一个组合，前一个为照片的 $id$，后一个为该照片的时间戳 $t$。

每行照片的数量 $m$ 满足 $0 < m < 100$。所有 $id$ 和 $t$ 均为非负整数。

## 输出格式

输出一行整数，每两个整数为一个组合，分别为重复出现的照片 $id$ 及其在所有相册中出现的总次数。

组合之间按时间戳 $t$ 升序排列。输入保证至少存在一张重复的照片，且排序结果唯一。

## 样例

### 样例 1

**输入：**
```
4
999 1 998 2 997 3 996 4 995 5
994 6 993 7 992 8 991 9 990 10
989 11 988 12 987 13
999 1 995 5 986 14
```

**输出：**
```
999 2 995 2
```

**说明：**
样例说明：

- 照片 $id$ 为 $999$ 的时间戳为 $1$，在第 1 本和第 4 本相册中出现，总次数为 $2$。

- 照片 $id$ 为 $995$ 的时间戳为 $5$，在第 1 本和第 4 本相册中出现，总次数为 $2$。

- 其余照片均只出现了一次。

- 按照时间戳排序，$1 < 5$，故先输出 $999\ 2$，再输出 $995\ 2$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686596/detail?pid=66224876&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686596/detail?pid=66224876&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.033264+00:00', '2026-07-02T15:32:15.272126+00:00', 2000, 262144, '开发'),
	(228, '判断是不是二叉搜索树', '判断是不是二叉搜索树', '牛客', 'Medium', 'tree', '给定一个二叉树根节点，请你判断这棵树是不是二叉搜索树。 

二叉搜索树满足每个节点的左子树上的所有节点均小于当前节点且右子树上的所有节点均大于当前节点。 

例： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211109/392807_1636440937987/9C31F319601A5B78D34F62FF77A02A11)

图1 

![题面配图](https://uploadfiles.nowcoder.com/images/20211109/392807_1636440984427/5E5B576E11CB2C96724680C94755ABCB)

图2 

数据范围：节点数量满足 $1 \le n\le 10^4 \$ ，节点上的值满足 $-2^{31} \le val \le 2^{31}-1\$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,3}
```

**输出：**
```
false
```

**说明：**
如题面图1

### 样例 2

**输入：**
```
{2,1,3}
```

**输出：**
```
true
```

**说明：**
如题面图2', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/a69242b39baf45dea217815c7dedb52b?tpId=295&tqId=2288088&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/a69242b39baf45dea217815c7dedb52b?tpId=295&tqId=2288088&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.849786+00:00', '2026-07-03T16:40:30.689072+00:00', 2000, 262144, '常见101'),
	(204, '两个链表的第一个公共结点', '两个链表的第一个公共结点', '牛客', 'Easy', 'linked-list', '输入两个无环的单向链表，找出它们的第一个公共结点，如果没有公共节点则返回空。（注意因为传入数据是链表，所以错误测试数据的提示是用其他方式显示的，保证传入数据是正确的） 

数据范围： $n \le 1000$ 
要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$

例如，输入{1,2,3},{4,5},{6,7}时，两个无环的单向链表的结构如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211104/423483716_1635999204882/394BB7AFD5CEA3DC64D610F62E6647A6)

可以看到它们的第一个公共结点的结点值为6，所以返回结点值为6的结点。 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,2,3},{4,5},{6,7}
```

**输出：**
```
{6,7}
```

**说明：**
第一个参数{1,2,3}代表是第一个链表非公共部分，第二个参数{4,5}代表是第二个链表非公共部分，最后的{6,7}表示的是2个链表的公共部分
这3个参数最后在后台会组装成为2个两个无环的单链表，且是有公共节点的

### 样例 2

**输入：**
```
{1},{2,3},{}
```

**输出：**
```
{}
```

**说明：**
2个链表没有公共节点 ,返回null，后台打印{}', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/6ab1d9a29e88450685099d45c9e31e46?tpId=295&tqId=23257&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/6ab1d9a29e88450685099d45c9e31e46?tpId=295&tqId=23257&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.489701+00:00', '2026-07-03T12:12:03.225086+00:00', 2000, 262144, '常见101'),
	(153, '爱丽丝的人偶符法', '爱丽丝的人偶符法', '华为', 'Medium', 'tree', '爱丽丝正在森林中布置她的人偶阵列。她将 $n$ 个人偶通过丝线连接成了一棵以人偶 $1$ 为根的树。每个人偶 $i$ 都有一个初始状态 $init_i \in \{0, 1\}$，而爱丽丝希望通过魔法将它们全部转变为目标状态 $goal_i \in \{0, 1\}$。

爱丽丝可以对任意一个人偶 $u$ 施加一次“波及魔法”。该魔法的效果如下：

翻转人偶 $u$ 及其子树中所有与 $u$ 距离为偶数（$0, 2, 4, \dots$）的人偶的状态。所谓翻转，即 $0$ 变为 $1$，$1$ 变为 $0$。

请计算爱丽丝最少需要施加多少次魔法，才能使所有人偶都达到目标状态。

## 输入格式

第一行包含一个整数 $n$ ($1 \leqq n \leqq 10^5$)，表示人偶的总数。 

接下来的 $n-1$ 行，每行包含两个整数 $u_i$ 和 $v_i$ ($1 \leqq u_i, v_i \leqq n; u_i \neq v_i$)，表示人偶 $u_i$ 与 $v_i$ 之间有一条丝线连接。输入保证这些丝线构成一棵合法的树。 

接下来的第 $n+1$ 行包含 $n$ 个整数，第 $i$ 个整数表示人偶 $i$ 的初始状态 $init_i$ ($0$ 或 $1$)。 

接下来的第 $n+2$ 行包含 $n$ 个整数，第 $i$ 个整数表示人偶 $i$ 的目标状态 $goal_i$ ($0$ 或 $1$)。

## 输出格式

输出一个整数，表示最少需要的操作次数。

## 样例

### 样例 1

**输入：**
```
5
1 2
2 3
4 5
3 4
0 0 0 0 0
1 1 1 1 1
```

**输出：**
```
2
```

**说明：**
在样例中，树的结构为一条路径 $1-2-3-4-5$。

1. 对人偶 $1$ 进行操作：由于人偶 $1, 3, 5$ 与 $1$ 的距离分别为 $0, 2, 4$（均为偶数），它们的状态从 $0$ 变为 $1$。此时状态序列为 `1 0 1 0 1`。

2. 对人偶 $2$ 进行操作：由于人偶 $2, 4$ 与 $2$ 的距离分别为 $0, 2$（均为偶数），它们的状态从 $0$ 变为 $1$。此时状态序列为 `1 1 1 1 1`。

总共进行了 $2$ 次操作，满足所有目标状态。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686321/detail?pid=66965448&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686321/detail?pid=66965448&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.484754+00:00', '2026-07-02T15:30:50.979378+00:00', 2000, 262144, '开发'),
	(152, '小红的大模型推理 Token 调度-2', '小红的大模型推理 Token 调度', '华为', 'Medium', 'stack-queue', '小红目前正在负责一家大型 AI 实验室的推理资源调度工作。为了提高大语言模型（LLM）的并行推理效率，她需要为当前任务队列中的一系列请求分配 Token 资源（单位：k）。

队列中的每个推理请求都有一个对应的优先级评分。在分配资源时，小红设定了如下调度规则：

1. 优先级评分小于或等于 0 的请求会被视为无效任务或系统预留任务，不参与本次 Token 分配，即分配到的 Token 数量为 0。

2. 这些无效任务会将整个请求序列切分成若干个由连续有效任务（优先级评分大于 0）构成的子段。

3. 对于每个有效任务子段，段内的每个请求至少要分配 1k 个 Token。

4. 在同一个子段内部，如果某个请求的优先级评分严格高于它左边或右边相邻的任务，那么它分配到的 Token 数量必须严格多于该相邻任务。

小红希望在完全满足上述规则的前提下，计算出分配给所有任务的 Token 总数最小值是多少。

## 输入格式

输入包含一行，为若干个由英文逗号隔开的整数，代表任务队列中每个推理请求的优先级评分。

任务总数 $N$ 满足 $1 \leq N \leq 2 \times 10^5$。

每个优先级评分 $P_i$ 满足 $-10^9 \leq P_i \leq 10^9$。

## 输出格式

输出一个整数，表示小红最少需要分配的 Token 总数（以 k 为单位）。

## 样例

### 样例 1

**输入：**
```
3,5,2,0,8
```

**输出：**
```
5
```

**说明：**
在该样例中，优先级为 0 的任务将序列分割为两个有效子段：[3, 5, 2] 和 [8]。

- 对于子段 [3, 5, 2]，为了满足相邻优先级更高则分配更多的原则，最少分配方案为 [1, 2, 1]，该段总和为 4。

- 对于子段 [8]，只有一个任务，最少分配 1k Token，该段总和为 1。

- 优先级为 0 的任务不分配 Token。

总计最小分配数量为 4 + 1 = 5。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686321/detail?pid=66965448&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686321/detail?pid=66965448&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.429254+00:00', '2026-07-02T15:31:01.526164+00:00', 2000, 262144, '开发'),
	(150, '奶油蛋糕的进阶配方', '奶油蛋糕的进阶配方', '华为', 'Medium', 'simulation', '小红是一名甜品店店长，她计划通过制作一系列进阶蛋糕来提升自己的“甜度等级”。

目前共有 $n$ 种蛋糕配方，每种蛋糕最多制作一次。对于第 $i$ 种蛋糕，只有当小红当前的甜度等级不低于其制作门槛 $x_i$ 时，才能开始制作。制作该蛋糕需要消耗 $z_i$ 点体力，并在制作完成后使小红的甜度等级提升 $y_i$ 点。

小红初始的甜度等级为 $w$，总体力值为 $e$。由于精力有限，她最多只能制作 $k$ 个蛋糕。请问在体力允许且制作数量不超过 $k$ 的前提下，小红最终能达到的最大甜度等级是多少？如果有多种方案能达到该最大等级，请输出达成该等级所需制作的最少蛋糕数量。

## 输入格式

第一行包含四个整数 $n, w, e, k$，分别表示蛋糕的种类数、初始甜度等级、初始体力值以及最大制作数量。
第二行包含 $n$ 个整数，表示每种蛋糕的制作门槛 $x_i$。
第三行包含 $n$ 个整数，表示每种蛋糕提升的甜度值 $y_i$。
第四行包含 $n$ 个整数，表示每种蛋糕消耗的体力值 $z_i$。
数据范围：
- $5 \leqq n \leqq 100$
- $0 \leqq w \leqq 1000$
- $0 \leqq e \leqq 80000$
- $1 \leqq k \leqq n$
- $0 \leqq x_i, y_i \leqq 10^6$
- $1 \leqq z_i \leqq 80000$

## 输出格式

输出两个整数，用空格隔开。第一个整数表示能达到的最大甜度等级，第二个整数表示达到该等级所需制作的最少蛋糕数量。

## 样例

### 样例 1

**输入：**
```
5 0 100 3
0 5 5 8 9
5 3 4 10 6
10 20 30 40 50
```

**输出：**
```
19 3
```

**说明：**
在样例中，小红可以按照以下顺序制作蛋糕：

1. 制作第 1 种蛋糕（门槛 $x_1=0 \leqq 0$）：消耗 10 体力，甜度变为 $0+5=5$，剩余体力 90。

2. 制作第 3 种蛋糕（门槛 $x_3=5 \leqq 5$）：消耗 30 体力，甜度变为 $5+4=9$，剩余体力 60。

3. 制作第 4 种蛋糕（门槛 $x_4=8 \leqq 9$）：消耗 40 体力，甜度变为 $9+10=19$，剩余体力 20。

此时共制作 3 个蛋糕（未超过 $k=3$），最终甜度等级为 19。这是该配置下能达到的最大值。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686570/detail?pid=66224883&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686570/detail?pid=66224883&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.318107+00:00', '2026-07-02T15:31:21.553629+00:00', 2000, 262144, '开发'),
	(227, '二叉树的镜像', '二叉树的镜像', '牛客', 'Easy', 'tree', '操作给定的二叉树，将其变换为源二叉树的镜像。 
数据范围：二叉树的节点数 $0 \le n \le 1000$ ， 二叉树每个节点的值 $0\le val \le 1000$ 
要求： 空间复杂度 $O(n)$ 。本题也有原地操作，即空间复杂度 $O(1)$ 的解法，时间复杂度 $O(n)$ 

比如： 
源二叉树

![题面配图](https://uploadfiles.nowcoder.com/images/20210922/382300087_1632302001586/420B82546CFC9760B45DD65BA9244888)

镜像二叉树 

![题面配图](https://uploadfiles.nowcoder.com/images/20210922/382300087_1632302036250/AD8C4CC119B15070FA1DBAA1EBE8FC2A)

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{8,6,10,5,7,9,11}
```

**输出：**
```
{8,10,6,11,9,7,5}
```

**说明：**
如题面所示

### 样例 2

**输入：**
```
{}
```

**输出：**
```
{}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/a9d0ecbacef9410ca97463e4a5c83be7?tpId=295&tqId=1374963&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/a9d0ecbacef9410ca97463e4a5c83be7?tpId=295&tqId=1374963&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.799560+00:00', '2026-07-03T16:40:41.346614+00:00', 2000, 262144, '常见101'),
	(246, '缺失的第一个正整数', '缺失的第一个正整数', '牛客', 'Medium', 'hashing', '给定一个无重复元素的整数数组nums，请你找出其中没有出现的最小的正整数

进阶： 空间复杂度 $O(1)$，时间复杂度 $O(n)$

数据范围:

$-2^{31}\le nums[i] \le 2^{31}-1$

$0\le len(nums)\le5*10^5$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,0,2]
```

**输出：**
```
3
```

### 样例 2

**输入：**
```
[-2,3,4,1,5]
```

**输出：**
```
2
```

### 样例 3

**输入：**
```
[4,5,6,8,9]
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/50ec6a5b0e4e45348544348278cdcee5?tpId=295&tqId=2188893&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/50ec6a5b0e4e45348544348278cdcee5?tpId=295&tqId=2188893&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:55:05.536033+00:00', '2026-07-03T16:55:48.198031+00:00', 2000, 262144, '常见101'),
	(156, '爱丽丝的人偶素材采购', '爱丽丝的人偶素材采购', '华为', 'Medium', 'simulation', '爱丽丝正在为制作新的人偶准备素材。她需要购买 $n$ 种不同的素材，每种素材的单价分别为 $a_1, a_2, \dots, a_n$。为了保证每一种人偶都能顺利完成，爱丽丝制定了一个严格的计划：她必须为每种素材至少购买一个。

现在爱丽丝手中恰好有 $b$ 元，她希望知道有多少种不同的采购方案，能够恰好耗尽这 $b$ 元预算。需要注意的是，即使两种素材的单价相同，它们也被视为不同的素材种类。

## 输入格式

输入包含单组测试数据。

第一行包含一个整数 $b$ ($0 \leqq b \leqq 100$)，代表爱丽丝的总预算。 

第二行包含若干个以空格分隔的整数，代表每种素材的单价 $a_i$ ($1 \leqq n \leqq 10, 1 \leqq a_i \leqq 50$)。

## 输出格式

输出一个整数，表示恰好耗尽预算的采购方案总数。 

注意：答案可能超过 32 位整数的范围，请使用 64 位整数（如 C++ 中的 `long long`）。

## 样例

### 样例 1

**输入：**
```
10
1 2
```

**输出：**
```
4
```

**说明：**
在样例中，预算为 10，有两种单价分别为 1 和 2 的素材。

1. 首先，每种素材必须至少买一个，消耗金额为 $1 + 2 = 3$ 元。

2. 剩余预算为 $10 - 3 = 7$ 元。

3. 使用单价为 1 和 2 的素材凑齐 7 元的方案共有 4 种：

- 购买 7 个单价为 1 的素材。

- 购买 5 个单价为 1 的素材和 1 个单价为 2 的素材。

- 购买 3 个单价为 1 的素材和 2 个单价为 2 的素材。

- 购买 1 个单价为 1 的素材和 3 个单价为 2 的素材。

因此输出为 4。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686434/detail?pid=67104113&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686434/detail?pid=67104113&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.638871+00:00', '2026-07-02T15:30:18.129726+00:00', 2000, 262144, '开发'),
	(155, '帕秋莉的魔导传输网', '帕秋莉的魔导传输网', '华为', 'Medium', 'graphs', '帕秋莉正在红魔馆的地下图书馆构建一套魔导传输网络。该网络由 $n$ 个编号为 $0 \sim n-1$ 的魔导单元组成，单元之间通过 $m$ 条双向传输通道进行信息交换。

每条通道连接两个特定的单元，并具有一定的传输延迟 $c$。由于魔导路径的复杂性，同一对单元之间可能存在多条不同的通道。

咲夜需要协助帕秋莉计算特定单元对之间的最小传输总延迟。如果两个单元之间存在多条路径，咲夜必须找出总延迟之和最小的一条；若两个单元之间没有任何路径相连，则认为它们无法建立通信。

## 输入格式

第一行包含两个整数 $n, m$ ($1 \leqq n \leqq 100, 1 \leqq m \leqq n^2$)，分别表示魔导单元的数量和传输通道的数量。

接下来的 $m$ 行，每行包含三个整数 $a, b, c$ ($0 \leqq a, b < n, 1 \leqq c \leqq 100$)，表示单元 $a$ 与单元 $b$ 之间存在一条双向传输通道，其延迟为 $c$。

接下来的一个整数 $k$ ($1 \leqq k \leqq 10^4$)，表示咲夜需要进行的查询次数。

接下来的 $k$ 行，每行包含两个整数 $i, j$ ($0 \leqq i, j < n$)，表示询问单元 $i$ 与单元 $j$ 之间的最小传输总延迟。

## 输出格式

输出共 $k$ 行。对于每组查询，输出一个整数表示最小延迟。若两单元间不存在任何路径，则输出 $0$。

## 样例

### 样例 1

**输入：**
```
5 3
0 1 10
1 2 20
3 4 40
3
0 2
0 3
3 4
```

**输出：**
```
30
0
40
```

**说明：**
- 单元 0 与 1 连接（延迟 10），1 与 2 连接（延迟 20）。从 0 到 2 的最短路径为 $0 \to 1 \to 2$，总延迟为 $10 + 20 = 30$。

- 单元 0 与 3 之间没有路径连通，按照要求输出 0。

- 单元 3 与 4 直接通过一条延迟为 40 的通道连接，这是它们之间的唯一路径。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686434/detail?pid=67104113&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686434/detail?pid=67104113&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.587873+00:00', '2026-07-02T15:30:29.187202+00:00', 2000, 262144, '开发'),
	(154, '爱丽丝的人偶版本整理', '爱丽丝的人偶版本整理', '华为', 'Medium', 'prefix-sum', '爱丽丝在人偶制作的过程中，为了方便维护众多的“上海人偶”，为每个人偶标记了不同的版本号。随着人偶版本的更迭，版本号的排布变得十分混乱，她需要你帮忙将这些版本号按从小到大进行整理。

每个版本号字符串由主版本号和可选的测试版本号组成：

1. 主版本号：由 1 至 4 个非负整数组成，整数之间用 `.` 分隔（例如 `1.0.2`）。

2. 测试版本号：若存在，则位于主版本号之后，以空格分隔，格式为 `betaX`，其中 $X$ 为正整数（例如 `1.0.2 beta3`）。若不包含此部分，则该版本为正式版。

排序规则如下：

1. 比较主版本号：从左至右依次比较对应位置的整数。若在某个位置数字不同，则数字较小者对应的版本号较小；若一个主版本号是另一个的前缀且两者长度不同，则较短者较小（例如 `1.0` < `1.0.0`）。

2. 当主版本号完全相同时：

- 测试版总是小于正式版（例如 `1.0.0 beta9` < `1.0.0`）。

- 若两者均为测试版，则比较 `beta` 后续的整数 $X$，数字较小者对应的版本号较小。

## 输入格式

第一行包含一个整数 $n$ ($1 \leqq n \leqq 100$)，表示版本号的数量。 

接下来的 $n$ 行，每行包含一个符合上述格式的版本号字符串。 

主版本号的每个部分均为 $[0, 1000]$ 范围内的整数，且不含多余的前导零（除了数字 `0` 本身）。若存在 `beta` 字段，其后的数字 $X$ 亦在 $[1, 1000]$ 范围内。

## 输出格式

输出共 $n$ 行，每行一个字符串，表示按升序排列后的版本号序列。

## 样例

### 样例 1

**输入：**
```
5
1.0.1.0
1.0.0.0 beta3
1.0.0.1 beta1
1.0.0.0 beta2
1.0.0.1
```

**输出：**
```
1.0.0.0 beta2
1.0.0.0 beta3
1.0.0.1 beta1
1.0.0.1
1.0.1.0
```

**说明：**
样例排序说明：

- 首先比较主版本号：`1.0.0.0` 的部分位数字小于 `1.0.0.1` 和 `1.0.1.0`，故排在最前。

- 对于主版本号同为 `1.0.0.0` 的两个版本，比较测试版编号：由于 $2 < 3$，故 `beta2` 排在 `beta3` 之前。

- 对于主版本号同为 `1.0.0.1` 的两个版本，由于测试版 `beta1` 必须小于正式版，故 `1.0.0.1 beta1` 排在 `1.0.0.1` 之前。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686434/detail?pid=67104113&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686434/detail?pid=67104113&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.536977+00:00', '2026-07-02T15:30:40.717045+00:00', 2000, 262144, '开发'),
	(151, '爱丽丝的人偶剧场管理', '爱丽丝的人偶剧场管理', '华为', 'Medium', 'sliding-window', '人偶师爱丽丝正在布置一场人偶剧。她在舞台（屏幕）上划分了若干个矩形区域作为不同人偶的活动范围，并称之为“窗口”。

舞台是一个左上角坐标为 $(0,0)$，右下角坐标为 $(W, H)$ 的矩形区域。每个窗口具有唯一的名称、位置 $(x, y)$、尺寸 $(w, h)$ 以及层级 $level$。

窗口之间的遮挡关系遵循以下优先级：

1. 层级优先：$level$ 较大的窗口位于 $level$ 较小的窗口之上。

2. 时序次之：若两个窗口 $level$ 相同，则后创建（操作序列中位置靠后）的窗口位于先创建的窗口之上。

一个窗口的可见部分定义为：该窗口在舞台边界 $[0, W] \times [0, H]$ 之内，且未被任何优先级更高的窗口遮挡的区域。若一个窗口的可见部分面积大于 $0$，则称该窗口是可见的。

爱丽丝需要你实现一个系统，处理一系列对舞台和窗口的操作。

## 输入格式

输入包含若干行，每行一个操作。操作总数不超过 $100$ 个。

所有坐标、宽度、高度均为 $32$ 位带符号整数。窗口名称仅包含英文字母且不含空格。

1. `init W H`：初始化舞台大小为 $W \times H$。若 $W \leqq 0$ 或 $H \leqq 0$，初始化失败返回 `false`；否则返回 `true`。若初始化失败，后续将无任何操作。

2. `createWindow name x y w h level` 或 `createWindow name x y size level`：创建一个窗口。

- 若参数为 $5$ 个整数，则宽度为 $w$，高度为 $h$。

- 若参数为 $4$ 个整数，则宽度和高度均为 $size$。

- 若 $w, h \leqq 0$ 或名称已存在，返回 `false`；否则返回 `true`。

3. `removeWindow name`：移除名称为 `name` 的窗口。若窗口不存在返回 `false`，否则返回 `true`。

4. `resize name newW newH`：将指定窗口的尺寸更改为 $newW \times newH$。若窗口不存在或 $newW, newH \leqq 0$，返回 `false`，否则返回 `true`。

5. `move name newX newY`：将指定窗口的左上角移动至 $(newX, newY)$。若窗口不存在返回 `false`，否则返回 `true`。

6. `queryVisibility name`：查询窗口 `name` 是否可见。可见返回 `true`，否则（或窗口不存在）返回 `false`。

7. `queryAllVisibleWindows x y w h`：在指定的矩形区域 $Q = [x, x+w] \times [y, y+h]$ 内，按优先级从高到低列出所有可见面积大于 $0$ 的窗口名称。

- 排序规则：首先按 $level$ 降序排列，若 $level$ 相同按名称的字典序升序排列。

- 输出格式：名称之间用分号 `;` 分隔。若区域内无可见窗口，输出 `NoVisibleWindow`。

## 输出格式

对每个操作，输出其对应的返回值（`true`、`false` 或字符串）并换行。

## 样例

### 样例 1

**输入：**
```
init 200 300
createWindow window1 10 10 100 100 1
createWindow window2 20 20 40 30 2
createWindow window3 70 90 50 3
removeWindow window2
removeWindow window4
queryVisibility window1
queryAllVisibleWindows 10 10 100 100
```

**输出：**
```
true
true
true
true
true
false
true
window3;window1
```

**说明：**
1. `init 200 300` 创建了 $200 \times 300$ 的舞台。

2. `window1`, `window2`, `window3` 相继被成功创建。

3. `window2` 被成功移除；移除不存在的 `window4` 失败返回 `false`。

4. `window1` 虽然被 `window3` 部分遮挡，但仍有剩余可见面积，故返回 `true`。

5. 在查询区域 $[10, 10] \times [110, 110]$ 中，`window3` 和 `window1` 均有可见部分。由于 `window3` 的 $level=3$ 大于 `window1` 的 $level=1$，故先输出 `window3`。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686321/detail?pid=66965448&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686321/detail?pid=66965448&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.380770+00:00', '2026-07-02T15:31:10.770704+00:00', 2000, 262144, '开发'),
	(149, '小红的慕斯模具统计', '小红的慕斯模具统计', '华为', 'Medium', 'intervals', '小红经营着一家创意烘焙坊，店内共有 $N$ 种编号为 $0 \dots N-1$ 的不同款式慕斯模具。在今天的生产流水线上，小红记录了 $M$ 次模具的使用信息。第 $m$ 次记录显示，在时间点 $j_m$ 使用了编号为 $i_m$ 的模具。

为了优化清洗流程，小红提出了 $K$ 个查询。每个查询由一个起始时间 $S_k$ 和一个固定的时间跨度 $X$ 组成，代表观察的时间区间为 $[S_k, S_k + X - 1]$（闭区间）。对于每个查询，小红想知道在这个时间区间内，使用了多少种不同编号的模具。

## 输入格式

第一行包含三个整数 $N, X, K$（$1 \leqq N, X, K \leqq 10^5$），分别表示模具的总数、查询的时间跨度长度以及查询的数量。 
第二行包含 $K$ 个整数 $S_1, S_2, \dots, S_K$（$0 \leqq S_k \leqq 10^5$），表示每个查询区间的起始时间。 
第三行包含一个整数 $M$（$1 \leqq M \leqq 10^5$），表示模具的使用记录总数。 
接下来的 $M$ 行，每行包含两个整数 $i_m$ 和 $j_m$（$0 \leqq i_m < N, 0 \leqq j_m \leqq 10^5$），表示在时间 $j_m$ 使用了编号为 $i_m$ 的模具。

## 输出格式

输出一行 $K$ 个整数，每两个整数之间用空格分隔，依次对应每个查询区间内不同模具的种类数。

## 样例

### 样例 1

**输入：**
```
4 2 2
3 4
4
2 4
2 3
1 2
3 5
```

**输出：**
```
1 2
```

**说明：**
- 对于第一个查询，时间区间为 $[3, 4]$。在该区间内，模具 2 分别在时间 3 和时间 4 被使用。因此，不同模具的数量为 1（仅有模具 2）。

- 对于第二个查询，时间区间为 $[4, 5]$。在该区间内，模具 2 在时间 4 被使用，模具 3 在时间 5 被使用。因此，不同模具的数量为 2（模具 2 和模具 3）。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686570/detail?pid=66224883&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686570/detail?pid=66224883&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.254523+00:00', '2026-07-02T15:31:33.404343+00:00', 2000, 262144, '开发'),
	(147, '遗迹探险家小红', '遗迹探险家小红', '华为', 'Medium', 'simulation', '小红正在一座神秘遗迹中收集宝藏。遗迹中共有 $n$ 件宝藏，第 $i$ 件宝藏需要花费 $t_i$ 分钟来收集，其价值为 $p_i$。

小红的总探险时间不能超过 $T$ 分钟。此外，如果某件宝藏的收集时间 $t_i$ 严格大于 $30$ 分钟，该宝藏将被视为“重型宝藏”。小红在本次探险中收集的“重型宝藏”总数不得超过 $m$ 个。

每件宝藏最多只能收集一次。请你帮小红计算，在满足时间和重型宝藏数量限制的前提下，她能获得的最大价值总和。

## 输入格式

第一行包含三个整数 $n, T, m$ ($1 \leqq n \leqq 100, 1 \leqq T \leqq 5000, 0 \leqq m \leqq 100$)，分别表示宝藏总数、最大允许总时间、以及最大允许的重型宝藏数量。
接下来的 $n$ 行，每行包含两个整数 $t_i$ 和 $p_i$ ($1 \leqq t_i \leqq 60, 1 \leqq p_i \leqq 1000$)，分别表示第 $i$ 件宝藏的收集时间与价值。

## 输出格式

输出一个整数，表示小红能获得的最大总价值。

## 样例

### 样例 1

**输入：**
```
4 100 1
20 50
35 60
25 30
40 70
```

**输出：**
```
150
```

**说明：**
在样例中，$n=4, T=100, m=1$。宝藏详情如下：

- 宝藏 1：耗时 20，价值 50（普通）

- 宝藏 2：耗时 35，价值 60（重型，因为 35 > 30）

- 宝藏 3：耗时 25，价值 30（普通）

- 宝藏 4：耗时 40，价值 70（重型，因为 40 > 30）

小红可以选择收集宝藏 1、宝藏 3 和 宝藏 4。

总耗时：$20 + 25 + 40 = 85 \leqq 100$。

重型宝藏数量：仅宝藏 4 一件，数量为 $1 \leqq 1$。

总价值：$50 + 30 + 70 = 150$。

可以证明这是满足条件的最大价值方案。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686596/detail?pid=66224876&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686596/detail?pid=66224876&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D239&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:33.143022+00:00', '2026-07-02T15:31:54.098157+00:00', 2000, 262144, '开发'),
	(144, '小红的能量校准', '小红的能量校准', '华为', 'Medium', 'simulation', '小红和小紫正在探索一座远古的高科技遗迹。在遗迹的核心区域，她们被一道闪烁着幽蓝色光芒的“能量平衡门”挡住了去路。

门上显示着一串复杂的能量传导公式，公式的末尾是一个固定的目标能量值。为了打开这扇门，小红必须向能量槽中注入精确数量的初始源能（用变量 $x$ 表示）。

这个远古文明的书写习惯非常独特，它们在记录能量倍率时，常常会省略乘号。根据小紫的分析，公式的规则如下：

1. 等式左边包含变量 $x$、非负整数、运算符 `+`、`*`、`(`、`)`。等式右边一定是一个固定的数，且可能是负数（即由数字字符组成，且可能包含''-''放在数字串开头）。

2. 隐式乘法规则：当数字、变量 $x$ 或括号紧密相邻时，表示它们之间存在乘法关系。例如：

- `2(x+1)` 等同于 $2 \times (x+1)$

- `x3` 等同于 $x \times 3$

- `(x+1)2` 等同于 $(x+1) \times 2$

- `2x` 等同于 $2 \times x$

3. 公式是一个线性方程，即 $x$ 的最高次幂为 1，且 $x$ 在整个字符串中恰好出现一次，并且一定位于等号 `=` 的左侧。

现在，小红记录下了门上的那个字符串 $s$，请你帮她计算出开启大门所需的初始源能 $x$ 是多少。

## 输入格式

输入一行，包含一个字符串 $s$，表示门上显示的能量传导公式。
- $3 \leqq |s| \leqq 1000$（字符串长度在 5 到 1000 之间）。
- 题目保证解 $x$ 是一个整数。
- 所有的中间计算过程及最终结果均在 64 位有符号整数（long long）范围内。
- 输入的字符串保证合法，且只包含题目描述中提到的字符。

## 输出格式

输出一个整数，表示满足公式的 $x$ 的值。

## 样例

### 样例 1

**输入：**
```
((x+2)*3+1)*2+5=79
```

**输出：**
```
10
```

**说明：**
对于样例，我们需要找到一个 $x$，使得等式左边计算结果为 79。
当 $x = 10$ 时：
1. 最内层括号：$10 + 2 = 12$
2. 乘以 3：$12 \times 3 = 36$
3. 加 1：$36 + 1 = 37$
4. 乘以 2：$37 \times 2 = 74$
5. 加 5：$74 + 5 = 79$
等式成立，故答案为 10。

### 样例 2

**输入：**
```
3x=6
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97686586/detail?pid=65783042&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97686586/detail?pid=65783042&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T15:29:32.980594+00:00', '2026-07-02T15:32:26.187019+00:00', 2000, 262144, '开发'),
	(201, '链表中环的入口结点', '链表中环的入口结点', '牛客', 'Medium', 'linked-list', '给一个长度为n链表，若其中包含环，请找出该链表的环的入口结点，否则，返回null。 

数据范围： $n\le10000$，$1<=结点值<=10000$ 
要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

例如，输入{1,2},{3,4,5}时，对应的环形链表如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211025/423483716_1635154005498/DA92C945EF643F1143567935F20D6B46)

可以看到环的入口结点的结点值为3，所以返回结点值为3的结点。

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2},{3,4,5}
```

**输出：**
```
3
```

**说明：**
返回环形链表入口结点，我们后台程序会打印该环形链表入口结点对应的结点值，即3

### 样例 2

**输入：**
```
{1},{}
```

**输出：**
```
"null"
```

**说明：**
没有环，返回对应编程语言的空结点，后台程序会打印"null"

### 样例 3

**输入：**
```
{},{2}
```

**输出：**
```
2
```

**说明：**
环的部分只有一个结点，所以返回该环形链表入口结点，后台程序打印该结点对应的结点值，即2', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/253d2c59ec3e4bc68da16833f79a38e4?tpId=295&tqId=23449&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/253d2c59ec3e4bc68da16833f79a38e4?tpId=295&tqId=23449&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.342098+00:00', '2026-07-03T12:12:44.647363+00:00', 2000, 262144, '常见101'),
	(231, '二叉搜索树的最近公共祖先', '二叉搜索树的最近公共祖先', '牛客', 'Easy', 'tree', '给定一个二叉搜索树, 找到该树中两个指定节点的最近公共祖先。 
1.对于该题的最近的公共祖先定义:对于有根树T的两个节点p、q，最近公共祖先LCA(T,p,q)表示一个节点x，满足x是p和q的祖先且x的深度尽可能大。在这里，一个节点也可以是它自己的祖先. 
2.二叉搜索树是若它的左子树不空，则左子树上所有节点的值均小于它的根节点的值； 若它的右子树不空，则右子树上所有节点的值均大于它的根节点的值 
3.所有节点的值都是唯一的。 
4.p、q 为不同节点且均存在于给定的二叉搜索树中。

数据范围: 
3<=节点总数<=10000 
0<=节点值<=10000 

如果给定以下搜索二叉树: {7,1,12,0,4,11,14,#,#,3,5}，如下图: 

![题面配图](https://uploadfiles.nowcoder.com/images/20211110/301499_1636536407371/36404CF45DDCB5834FC8BBFEA318831A)

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{7,1,12,0,4,11,14,#,#,3,5},1,12
```

**输出：**
```
7
```

**说明：**
节点1 和 节点12的最近公共祖先是7

### 样例 2

**输入：**
```
{7,1,12,0,4,11,14,#,#,3,5},12,11
```

**输出：**
```
12
```

**说明：**
因为一个节点也可以是它自己的祖先.所以输出12', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/d9820119321945f588ed6a26f0a6991f?tpId=295&tqId=2290592&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/d9820119321945f588ed6a26f0a6991f?tpId=295&tqId=2290592&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.996412+00:00', '2026-07-03T16:40:00.810040+00:00', 2000, 262144, '常见101'),
	(226, '合并二叉树', '合并二叉树', '牛客', 'Easy', 'tree', '已知两颗二叉树，将它们合并成一颗二叉树。合并规则是：都存在的结点，就将结点值加起来，否则空的位置就由另一个树的结点来代替。例如：
两颗二叉树是:
Tree 1 

![题面配图](https://uploadfiles.nowcoder.com/images/20210928/382300087_1632821337680/9E290CFD3730B9B08A5CEFF25799608F)

Tree 2

![题面配图](https://uploadfiles.nowcoder.com/images/20210928/382300087_1632821376266/DD0A63560E770A8510049C5182E6E622)

合并后的树为

![题面配图](https://uploadfiles.nowcoder.com/images/20210928/382300087_1632821404541/9CB750F8909D5985C0D01D8B71AD58BA)

数据范围：树上节点数量满足 $0 \le n \le 500$，树上节点的值一定在32位整型范围内。 
进阶：空间复杂度 $O(1)$ ，时间复杂度 $O(n)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,3,2,5},{2,1,3,#,4,#,7}
```

**输出：**
```
{3,4,5,5,4,#,7}
```

**说明：**
如题面图

### 样例 2

**输入：**
```
{1},{}
```

**输出：**
```
{1}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/7298353c24cc42e3bd5f0e0bd3d1d759?tpId=295&tqId=1025038&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/7298353c24cc42e3bd5f0e0bd3d1d759?tpId=295&tqId=1025038&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.749310+00:00', '2026-07-03T16:40:49.670437+00:00', 2000, 262144, '常见101'),
	(198, '合并两个排序的链表', '合并两个排序的链表', '牛客', 'Easy', 'linked-list', '输入两个递增的链表，单个链表的长度为n，合并这两个链表并使新链表中的节点仍然是递增排序的。

数据范围： $0 \le n \le 1000$，$-1000 \le 节点值 \le 1000$
要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$

如输入{1,3,5},{2,4,6}时，合并后的链表为{1,2,3,4,5,6}，所以对应的输出为{1,2,3,4,5,6}，转换过程如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211014/423483716_1634208575589/09DD8C2662B96CE14928333F055C5580)

或输入{-1,2,4},{1,3,4}时，合并后的链表为{-1,1,2,3,4,4}，所以对应的输出为{-1,1,2,3,4,4}，转换过程如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211014/423483716_1634208729766/8266E4BFEDA1BD42D8F9794EB4EA0A13)

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,3,5},{2,4,6}
```

**输出：**
```
{1,2,3,4,5,6}
```

### 样例 2

**输入：**
```
{},{}
```

**输出：**
```
{}
```

### 样例 3

**输入：**
```
{-1,2,4},{1,3,4}
```

**输出：**
```
{-1,1,2,3,4,4}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/d8b6b4358f774294a89de2a6ac4d9337?tpId=295&tqId=23267&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/d8b6b4358f774294a89de2a6ac4d9337?tpId=295&tqId=23267&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.191179+00:00', '2026-07-03T12:13:38.348358+00:00', 2000, 262144, '常见101');
INSERT INTO public.problems VALUES
	(160, '数组同构', '数组同构', '美团', 'Medium', 'bit-manipulation', '定义变换函数： 

将一个正整数 $x$ 用其二进制表示中 $1$ 的个数替换，记作 $g(x)$（即 $\operatorname{popcount}$）； 

给定两个长度均为 $n$ 的正整数数组 $A$ 和 $B$； 

你可以对 $A$ 或 $B$ 中的任意元素反复执行以下操作，每次操作计数 $1$： 

将该元素 $x$ 替换为 $g(x)$； 

当且仅当存在置换 $\pi$，使得对所有 $1\leqq i\leqq n$ 都有 $A_i = B_{\pi(i)}$，也就是两个数组都排序后完全相同，我们称 $A$ 与 $B$ 同构。请计算使 $A$ 与 $B$ 同构所需的最少操作次数。

可以证明题目一定有解。

## 输入格式

第一行输入一个整数 $t\ \left(1\leqq t\leqq 10^{4}\right)$，表示测试用例数； 
每个测试用例输入格式如下： 
第一行输入一个整数 $n\ \left(1\leqq n\leqq 2\times 10^{5}\right)$； 
第二行输入 $n$ 个整数 $A_1, A_2, \dots, A_n\ \left(1\leqq A_i\leqq10^{18}\right)$； 
第三行输入 $n$ 个整数 $B_1, B_2, \dots, B_n\ \left(1\leqq B_i\leqq10^{18}\right)$； 
保证所有测试用例中 $\sum n \leqq 2\times 10^{5}$。

## 输出格式

对于每个测试用例，输出一行整数——使 $A$ 与 $B$ 同构的最少操作次数。

## 样例

### 样例 1

**输入：**
```
2
3
4 1 2
2 2 1
3
7 3 5
3 3 5
```

**输出：**
```
2
1
```

**说明：**
初始时，$A=\{4,1,2\},\ B=\{2,2,1\}$； 
对 $A$ 中元素 $4$ 执行一次变换，得到 $g(4)=1$，此时 $A=\{1,1,2\}$； 
对 $B$ 中一个元素 $2$ 执行一次变换，得到 $g(2)=1$，此时 $B=\{1,2,1\}$； 
此时两数组的元素可以一一匹配，故最少操作数为 $2$。 

在第二个测试用例中：仅需将 $A$ 中的 $7$ 变换为 $g(7)=3$，得到 $A=\{3,3,5\}$，与 $B$ 相同，操作数为 $1$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687680/detail?pid=63317389&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687680/detail?pid=63317389&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:20:46.299537+00:00', '2026-07-02T16:28:16.547368+00:00', 2000, 262144, '技术'),
	(158, '信号模拟', '信号模拟', '美团', 'Medium', 'graphs', '如下图所示，有 $2 \times n$ 个仪器，中间的方块是仪器的主体，每个仪器可以充当接收器或者信号源；主体的左右两侧是两个接线点。

现在，我们将左端 $2 \times n$ 个接线点随机分成 $n$ 组，每组各含两个点，并将右端 $2 \times n$ 个接线点同样随机分成 $n$ 组。然后将每组的两个接线点用导线连接。

![题面配图](https://uploadfiles.nowcoder.com/images/20250607/0_1749288338676/9CACA81BFCA6EE2E3B265A2D4BB43C18)

这样一来，我们就得到了一组封闭的信号线路。具体而言：

信号从任一信号源 $i$ 出发，通过右侧接线点；

随后，信号通过与右侧接线点连接的导线到达另外一个仪器的左侧接线点，再经过仪器主体到达右侧接线点；此时，如果这个仪器是接收器，那么就视为接收到了信号（注意，接收到信号不会影响信号继续往后传递）。

这个过程持续进行，最终会形成若干个独立的循环。

现在，记 $x$ 表示在所有接收器均能接收到信号的前提下，$2 \times n$ 个仪器中作为信号源的最少数量。求解 $x$ 的方差。

可以证明答案可以表示为一个不可约分数 $\tfrac{p}{q}$，为了避免精度问题，请直接输出整数 $\left(p \times q^{-1} \bmod M\right)$ 作为答案，其中 $M = 998\,244\,353$，$q^{-1}$ 是满足 $q\times q^{-1} \equiv 1 \pmod{M}$ 的整数。更具体地，你需要找到一个整数 $x \in [0, M)$ 满足 $x \times q$ 对 $M$ 取模等于 $p$，您可以查看样例解释得到更具体的说明。
## 提示
本题中，如果您需要使用到除法的取模，即计算 $\left(p\times q^{-1} \bmod M\right)$ 时，$q^{-1}$ 需要使用公式 $\left(q^{M-2} \bmod M \right)$ 得到。例如，计算 $\left(\tfrac{5}{4} \bmod M\right)$：
$$
\begin{array}{rll}
4^{-1} & = & \left(4^{M-2} \bmod M\right) \\
& = & 748\,683\,265 \\
\hline
\left(\tfrac{5}{4} \bmod M\right) & = & 5 \times4^{-1} \bmod M \\
& = & 5 \times 748\,683\,265 \bmod M \\
& = & 748\,683\,266
\end{array}
$$

## 输入格式

每个测试文件均包含多组测试数据。第一行输入一个整数 $T\left(1\leqq T\leqq 10^4\right)$ 代表数据组数，每组测试数据描述如下：
在一行上输入一个整数 $n\left(1\leqq n\leqq 10^6\right)$ 代表仪器的数量。

## 输出格式

对于每组测试数据，新起一行输出一个整数，表示 $x$ 的方差对 $M=998\,244\,353$ 取模后的结果。

## 样例

### 样例 1

**输入：**
```
3
1
2
3
```

**输出：**
```
0
887328314
168592380
```

**说明：**
对于第一组测试数据，左、右两侧各仅有一种配对方式，构成一个长度为 2 的循环。最小信号源数为 $1$，如下图所示。因此 $E(X)=1$，$D(X)=0$。

![题面配图](https://uploadfiles.nowcoder.com/images/20250808/0_1754660827080/0A7A4A62D6A7946A00BEED951BE5A4BF)

对于第二组测试数据，左侧有三种配对（$\{1,2\},\{3,4\}$；$\{1,3\},\{2,4\}$；$\{1,4\},\{2,3\}$），右侧同样三种，合计 $3\times3=9$ 种等可能组合。计算可得，需要 $1$ 个信号源的概率为 $\tfrac{6}{9}$（如下左图所示，为其中一种情况），需要 $2$ 个信号源的概率为 $\tfrac{3}{9}$（如下右图所示，为其中一种情况），故：
$E(X)=1\times\tfrac{2}{3}+2\times\tfrac{1}{3}=\tfrac{4}{3}$；
$D(X)=E\left([X-E(X)]^2 \right)=(1-\tfrac{4}{3})^2\times\tfrac{2}{3}+(2-\tfrac{4}{3})^2\times\tfrac{1}{3}=\tfrac{2}{9}$。
我们能够找到，$887\,328\,314 \times 9 = 7\,985\,954\,826$，对 $M$ 取模后恰好等于分子 $2$，所以 $887\,328\,314$ 是需要输出的答案。

![题面配图](https://uploadfiles.nowcoder.com/images/20250808/0_1754661128100/9B39F64C1D3112A8D327D96C6AC34005)', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687671/detail?pid=63140272&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687671/detail?pid=63140272&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:19:15.819426+00:00', '2026-07-02T16:28:43.517030+00:00', 2000, 262144, '技术'),
	(157, '放它一马', '放它一马', '美团', 'Medium', 'simulation', '小美会按照编号从小到大的顺序依次遇到 $n$ 只怪物（编号为 $1 \sim n$），怪物 $i(1 \leqq i \leqq n)$ 的生命为 $a_i$。

对于每只怪物，小美都可以选择放走Ta或者击败Ta。

如果放走怪物，小美将获得 $i$ 点经验值。

如果击败怪物，小美将获得 $a_i$ 点经验值，同时将额外获得 $(x \operatorname{mod} 10) \times a_i$ 点经验值，$x$ 为击败怪物数量（包括这一个怪物）。

求小美最多可以从这 $n$ 个怪物中获得的经验值。

## 输入格式

第一行输入一个整数 $n(1 \leqq n \leqq 2\times 10^5)$ 表示怪物数。
第二行输入 $n$ 个整数 $a_i(1 \leqq a_i \leqq 10^9)$ 表示怪物的生命。

## 输出格式

输出一个整数表示小美可以获得最高的经验值。

## 样例

### 样例 1

**输入：**
```
3
5 3 2
```

**输出：**
```
27
```

**说明：**
第一个怪物选择击败获得$5+5 \times 1=10$ 的经验值，第二个怪物选择击败获得 $3+3\times2=9$ 的经验值，第三只怪物选择击败获得 $2+2\times3=8$ 的经验值，总共获得 $27$ 的经验值。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687671/detail?pid=63140272&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687671/detail?pid=63140272&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:18:30.552185+00:00', '2026-07-02T16:29:08.585615+00:00', 2000, 262144, '技术'),
	(225, '对称的二叉树', '对称的二叉树', '牛客', 'Easy', 'tree', '给定一棵二叉树，判断其是否是自身的镜像（即：是否对称）
例如： 下面这棵二叉树是对称的

![题面配图](https://uploadfiles.nowcoder.com/images/20210926/382300087_1632642756706/A22A794C036C06431E632F9D5E2E298F)

下面这棵二叉树不对称。

![题面配图](https://uploadfiles.nowcoder.com/images/20210926/382300087_1632642770481/3304ABDD147D8E140B2CEF3201BD8372)

数据范围：节点数满足 $0 \le n \le 1000$，节点上的值满足 $|val| \le 1000$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$ 
备注： 
你可以用递归和迭代两种方法解决这个问题

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,2,2,3,4,4,3}
```

**输出：**
```
true
```

### 样例 2

**输入：**
```
{8,6,9,5,7,7,5}
```

**输出：**
```
false
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/ff05d44dfdb04e1d83bdbdab320efbcb?tpId=295&tqId=23452&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/ff05d44dfdb04e1d83bdbdab320efbcb?tpId=295&tqId=23452&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.701428+00:00', '2026-07-03T16:40:57.385306+00:00', 2000, 262144, '常见101'),
	(164, '我们惺惺相惜', '我们惺惺相惜', '美团', 'Medium', 'intervals', '给定一个长度为 $n$ 的数组 $a$，我们定义一个区间 $[l,r]$是好的，当且仅当这个区间可以分成两个非空的子序列，元素之间相对顺序不变，使得这两个子序列都是严格单调递增子序列。

对于给出多次询问，你需要问答区间是不是好区间。

## 输入格式

第一行一个整数 $T(1\leq T\leq 20000)$，表示有 $T$ 次询问。

对于每次询问，第一行两个整数 $n,q(2\leq n,q\leq 2\times 10^5)$，第二行 $n$ 个整数 $a_i(1\leq a_i\leq 10^9)$，表示数组 $a$。

接下来 $q$ 行，每行两个整数 $l,r(1\leq l< r\leq n)$，表示询问的区间。

单个测试文件保证 $n$ 和 $q$ 的和均不超过 $2\times 10^5$。

## 输出格式

对于每次询问，输出一行，如果区间是好区间，输出 $YES$，否则输出 $NO$。

## 样例

### 样例 1

**输入：**
```
2
4 2
1 2 3 3
1 3
1 2
5 3
4 5 4 5 3
1 4
1 5
2 4
```

**输出：**
```
YES
YES
YES
NO
YES
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687688/detail?pid=61979719&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687688/detail?pid=61979719&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:23:46.956803+00:00', '2026-07-02T16:27:23.091821+00:00', 2000, 262144, '技术'),
	(162, '行走-', '行走', '美团', 'Medium', 'simulation', '小美正在一个无限大的二维坐标轴上运动，初始时她位于坐标 $(x,y)$。

她将基于一个由 $n$ 个整数组成的数组 $\{a_1, a_2, \dots, a_n\}$ 进行移动，对于第 $i$ 次移动，她都需要选择这样两个整数 $l$ 和 $r$，满足 $|l| + |r| = a_i$，随后移动到 $(x + l, y + r)$ 这个位置。

现在请问，$n$ 次移动后，她能否恰好移动到 $(p,q)$ 这个位置。

## 输入格式

第一行一个整数 $t(1\leq t\leq 1000)$，表示数据组数。对于每组数据格式为：
第一行一个整数 $n(1\leq n\leq 10^5)$，表示数组长度。
第二行 $n$ 个整数，第 $i$ 个整数为 $a_i(0\leq a_i\leq 1)$，表示每次移动的距离。
第三行四个整数 $x,y,p,q(-10^{18}\leq x,y,p,q\leq 10^{18})$，分别表示起点的横纵坐标，终点的横纵坐标。
数据保证单个测试文件 $\sum n\leq 10^5$。

## 输出格式

对于每组数据输出一个字符串，若可以恰好移动到 $(p,q)$ 输出 "YES" ，否则输出"NO"。

## 样例

### 样例 1

**输入：**
```
2
2
0 0
1 1 1 1
3
1 1 1
1 1 2 2
```

**输出：**
```
YES
NO
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687688/detail?pid=61979719&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687688/detail?pid=61979719&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:22:16.647105+00:00', '2026-07-02T16:27:52.358831+00:00', 2000, 262144, '技术'),
	(163, '小美的陡峭值操作', '小美的陡峭值操作', '美团', 'Medium', 'intervals', '定义一个数组的的陡峭值为：相邻两个元素之差的绝对值之和。

现在小美拿到了一个数组，她可以最多进行1次操作：选择一个区间，使得区间内所有元素加1。

小美希望最终数组的陡峭值尽可能小，你能帮帮她吗？

## 输入格式

第一行输入一个正整数$t$，代表询问次数。
对于每次询问输入两行：
第一行输入一个正整数$n$，代表数组长度。
第二行输入$n$个正整数$a_i$，代表小美拿到的数组。
$1\leq t \leq 1000$
$2\leq n \leq 10^5$
$1\leq a_i \leq 10^9$
保证所有询问的$n$的总和不超过$10^5$

## 输出格式

输出$t$行，输出一个整数，代表该次查询陡峭值的最小值。

## 样例

### 样例 1

**输入：**
```
2
5
1 4 2 3 4
3
1 2 1
```

**输出：**
```
5
1
```

**说明：**
第一组询问，选择[3,4]区间即可，数组变成{1,4,3,4,4}。
第二组询问，选择[1,1]区间即可，数组变成{2,2,1}。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687688/detail?pid=61979719&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687688/detail?pid=61979719&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:23:01.819436+00:00', '2026-07-02T16:27:38.505570+00:00', 2000, 262144, '技术'),
	(161, '小美的序列问题', '小美的序列问题', '美团', 'Medium', 'simulation', '对于给定的由 n 个整数组成的数组 $\{a_1,a_2,\dots,a_n\}$，计算其中有多少个三元组 $(i,j,k)$ 满足 $1\leqq i < j < k \leqq n$ 且 $a_i>a_k>a_j$。例如，在数组$\{4,1,2,3\}$ 中三元组 $(1,2,3) ,(1,2,4),(1,3,4)$ 都是满足条件的三元组。更具体地，计算：

$\displaystyle\sum\limits_{1\leqq i < j < k \leqq n}\left[a_i>a_k>a_j\right]$

请编写一个函数，计算并返回满足条件的三元组的数量。

【名词解释】

本题公式中的中括号代表艾弗森括号，具体地，$[P] = \begin{cases} 1 & \text{如果 } P \text{ 为真} \\ 0 & \text{如果 } P \text{ 为假} \end{cases}$。

## 输入格式

第一行输入一个整数 $n \left(1\leqq n \leqq 2\times 10^5\right)$ 代表数组中的元素个数。
第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n \left(-10^9\leqq a_i \leqq 10^9\right)$ 代表数组中的元素。

## 输出格式

输出一个整数，表示满足条件的三元组个数。

## 样例

### 样例 1

**输入：**
```
5
1 5 4 2 3
```

**输出：**
```
2
```

**说明：**
在这个样例中，满足条件的三元组有：
$i=2$、$j=4$ 且 $k=5$ 构成的三元组 $\{5,2,3\}$；
$i=3$、$j=4$ 且 $k=5$ 构成的三元组 $\{4,2,3\}$。

### 样例 2

**输入：**
```
20
-6 -9 -90 -73 89 -90 2 19 52 -16 -41 -22 85 24 -22 66 75 78 48 -36
```

**输出：**
```
134
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687680/detail?pid=63317389&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687680/detail?pid=63317389&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:21:31.499704+00:00', '2026-07-02T16:28:03.875379+00:00', 2000, 262144, '技术'),
	(159, '组数制进二', '组数制进二', '美团', 'Medium', 'bit-manipulation', '小美有一个长度为 $n$ 的数组 $\{a_1,a_2,\dots,a_n\}$，他希望构造一个非负整数 $x$，满足 $x$ 的二进制位数不超过数组中最大值的二进制位数（特别的 $0$ 二进制位数为 $1$ ）。 

随后，可对数组 $a$ 重复进行以下操作，以使所有元素的总和最大： 

选择一个下标 $i$，同时将 $a_i$ 修改为 $a_i\operatorname{or} x$，将 $x$ 修改为 $a_i\operatorname{and} x$。 

在使元素总和达到最大值的前提下，要求所有操作前初始的 $x$ 尽可能小。请输出最大总和及对应的最小 $x$。

按位或：$\operatorname{or}$ 表示按位或运算，即对两个整数的二进制表示的每一位进行逻辑或操作。 

按位与：$\operatorname{and}$ 表示按位与运算，即对两个整数的二进制表示的每一位进行逻辑与操作。

## 输入格式

每个测试文件均包含多组测试数据。 
第一行输入一个整数 $T\left(1\leqq T\leqq 1000\right)$，代表数据组数； 

对于每组测试数据，输入如下： 
第一行输入一个整数 $n\left(1\leqq n\leqq 500\right)$，表示数组的长度； 
第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n\left(0\leqq a_i<2^{30}\right)$，表示数组 $a$ 的元素。

## 输出格式

对于每组测试数据，新起一行。输出两个整数，用空格分隔：第一个整数为数组可以达到的最大总和；第二个整数为在达到最大总和的前提下初始最小的 $x$。

## 样例

### 样例 1

**输入：**
```
2
2
3 3
3
1 2 3
```

**输出：**
```
6 0
9 3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687680/detail?pid=63317389&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687680/detail?pid=63317389&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:20:01.082785+00:00', '2026-07-02T16:28:28.719717+00:00', 2000, 262144, '技术'),
	(197, '链表中的节点每k个一组翻转', '链表中的节点每k个一组翻转', '牛客', 'Medium', 'linked-list', '将给出的链表中的节点每 k 个一组翻转，返回翻转后的链表
如果链表中的节点数不是 k 的倍数，将最后剩下的节点保持原样
你不能更改节点中的值，只能更改节点本身。 

数据范围： $\ 0 \le n \le 2000$ ， $1 \le k \le 2000$ ，链表中每个元素都满足 $0 \le val \le 1000$
要求空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

例如： 
给定的链表是 $1\to2\to3\to4\to5$ 
对于 $k = 2$ , 你应该返回 $2\to 1\to 4\to 3\to 5$ 
对于 $k = 3$ , 你应该返回 $3\to2 \to1 \to 4\to 5$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,3,4,5},2
```

**输出：**
```
{2,1,4,3,5}
```

### 样例 2

**输入：**
```
{},1
```

**输出：**
```
{}
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/b49c3dc907814e9bbfa8437c251b028e?tpId=295&tqId=722&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/b49c3dc907814e9bbfa8437c251b028e?tpId=295&tqId=722&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T11:30:32.143378+00:00', '2026-07-03T12:13:50.127537+00:00', 2000, 262144, '常见101'),
	(167, '最大节点权值', '最大节点权值', '美团', 'Medium', 'graphs', '给你一个由 $n$ 个编号为 $1 \sim n$ 的节点以及 $m$ 条编号为 $1 \sim m$ 的边组成的无向图，我们定义一个节点的权值为它的当前度$^\texttt{[1]}$（即已执行完之前所有操作后的状态）加上它的节点编号。

小美会进行 $q$ 次如下操作：

操作一：断开编号为 $x$ 的边，保证每条边至多被删除一次，即在进行操作一时，该边当前一定存在于图中。

操作二：向你询问编号为 $x$ 的节点所在的连通块$^\texttt{[2]}$中所有节点中最大的权值，你需要将此权值告诉他。

【名词解释】

度$^\texttt{[1]}$：与一个顶点相连接的边的条数称为该顶点的度。

连通块$^\texttt{[2]}$：也称连通分量，满足，

是原图的一个子图；

连通块内的任意两个顶点之间都存在路径相连，且路径上的点也在连通块内；

是极大的，即不能再通过添加原图中的其他顶点而依旧保持连通性；

单独的点也构成一个连通块。连通块的大小即为连通块中顶点的数量。

## 输入格式

第一行输入三个正整数 $n,m,q \left(1 \leqq n,q \leqq 2 \times 10^5;\,0 \leqq m \leqq \min\big\{\tfrac{n \times (n-1)}{2},2 \times 10^5\big\} \right)$ 表示节点个数，边个数，操作次数。
此后 $m$ 行，第 $i$ 行输入两个整数 $u_i$ 和 $v_i\ (1 \leqq u_i, v_i \leqq n;\ u_i \neq v_i)$ 表示图上第 $i$ 条边连接节点 $u_i$ 和 $v_i$。
此后 $q$ 行，第 $i$ 行先输入一个整数 $o_i \left(1 \leqq o_i \leqq 2 \right)$，表示操作编号。编号同题面，随后在同一行：
若 $o_i=1$，输入一个整数 $x_i \left(1 \leqq x_i \leqq m \right)$，表示断掉的边的编号；

若 $o_i=2$，输入一个整数 $x_i \left(1 \leqq x_i \leqq n \right)$，表示询问的节点编号。

保证图没有重边和自环，操作一合法。

## 输出格式

输出若干行，每一行对操作二进行回答。

## 样例

### 样例 1

**输入：**
```
5 5 5
1 2
1 5
3 5
2 4
1 3
2 4
1 1
2 2
1 2
2 1
```

**输出：**
```
7
5
6
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687767/detail?pid=66371978&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687767/detail?pid=66371978&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:33:16.519338+00:00', '2026-07-02T16:36:22.963175+00:00', 2000, 262144, '技术'),
	(165, '小美的因子数量', '小美的因子数量', '美团', 'Medium', 'intervals', '小美很喜欢因子数量为奇数的数。

现在小芳给了小美一个区间 $\left[l,r\right]$，请你帮小美算出区间内有多少个因子数量为奇数的数。

【名词解释】

因子：对于正整数 $x$，如果存在正整数 $p$ 使得 $x$ 能被 $p$ 整除，则称 $p$ 是 $x$ 的因子。例如，$12$ 的因子有 $1,2,3,4,6,12$。

## 输入格式

第一行输入两个整数 $l,r \left(1 \leqq l\leqq r \leqq 10^{9}\right)$，表示询问的区间。

## 输出格式

输出一个整数，表示区间内因子数量为奇数的数的个数。

## 样例

### 样例 1

**输入：**
```
1 1
```

**输出：**
```
1
```

**说明：**
在这个样例中，区间内唯一可以取到的数字为 $1$，其因子数量只有自身，为奇数。

### 样例 2

**输入：**
```
4 5
```

**输出：**
```
1
```

**说明：**
在这个样例中，区间内只有 $4$ 的因子数量为奇数。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687767/detail?pid=66371978&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687767/detail?pid=66371978&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:31:47.307822+00:00', '2026-07-02T16:36:44.341306+00:00', 2000, 262144, '技术'),
	(224, '二叉搜索树与双向链表', '二叉搜索树与双向链表', '牛客', 'Medium', 'tree', '输入一棵二叉搜索树，将该二叉搜索树转换成一个排序的双向链表。如下图所示 

![题面配图](https://uploadfiles.nowcoder.com/images/20210605/557336_1622886924427/E1F1270919D292C9F48F51975FD07CE2)

数据范围：输入二叉树的节点数 $0 \le n \le 1000$，二叉树中每个节点的值 $0\le val \le 1000$
要求：空间复杂度$O(1)$（即在原树上操作），时间复杂度 $O(n)$

注意: 
1.要求不能创建任何新的结点，只能调整树中结点指针的指向。当转化完成以后，树中节点的左指针需要指向前驱，树中节点的右指针需要指向后继
2.返回链表中的第一个节点的指针
3.函数返回的TreeNode，有左右指针，其实可以看成一个双向链表的数据结构 
4.你不用输出双向链表，程序会根据你的返回值自动打印输出 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{10,6,14,4,8,12,16}
```

**输出：**
```
From left to right are:4,6,8,10,12,14,16;From right to left are:16,14,12,10,8,6,4;
```

**说明：**
输入题面图中二叉树，输出的时候将双向链表的头节点返回即可。

### 样例 2

**输入：**
```
{5,4,#,3,#,2,#,1}
```

**输出：**
```
From left to right are:1,2,3,4,5;From right to left are:5,4,3,2,1;
```

**说明：**
5
/
4
/
3
/
2
/
1
树的形状如上图', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/947f6eb80d944a84850b0538bf0ec3a5?tpId=295&tqId=23253&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/947f6eb80d944a84850b0538bf0ec3a5?tpId=295&tqId=23253&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.652096+00:00', '2026-07-03T16:41:06.090995+00:00', 2000, 262144, '常见101'),
	(170, '小美的01树', '小美的01树', '美团', 'Medium', 'tree', '小美有一颗节点编号为 $1 \sim n$ 的树，每个节点只有 $\{0,1\}$ 这两种值之一。

我们设 $u \rightarrow v$ 为节点 $u$ 到节点 $v$ 的简单路径。$g(u \rightarrow v)$ 为从 $u$ 开始到 $v$ 结束的简单路径上经过的所有点（包括 $u,v$）按照先后顺序组成的 $01$ 字符串对应的十进制对 $10^9+7$ 取模的结果。

例如，简单路径 $u \rightarrow v$ 经过所有节点组成的字符串为 $01101$，其对应十进制就是 $13$，因此 $g(u \rightarrow v) = 13 \bmod (10^9+7) = 13$。

小美会进行 $m$ 次以下操作：

操作 $1$：将简单路径 $u \rightarrow v$ 上所有节点的值反置。

操作 $2$：询问 $g(u \rightarrow v)$ 的值。

你需要对小美的每一个操作二进行回答。

【反置】若当前字符为 $\tt 0$ ，反置后为 $\tt 1$ ；若当前字符为 $\tt 1$ ，反置后为 $\tt 0$ 。

## 输入格式

第一行输入两个整数 $n,m(1 \leqq n,m \leqq 2 \times 10^5)$ 表示树的大小以及 小美询问的次数。
第二行输入 $n$ 个整数 $a_i(a_i \in \{0,1\})$ 表示第 $i$ 个节点初始的值。

接下来 $n-1$ 行，每一行输入两个整数 $u_i,v_i(1 \leqq u_i,v_i \leqq n)$ 表示节点 $u_i$ 与 $v_i$ 之间有一条边。

接下来 $m$ 行，每一行输入三个整数 $x,u,v(x \in \{1,2\},1 \leqq u,v \leqq n)$，具体的：
$x = 1$：将简单路径 $u \rightarrow v$ 上所有节点的值反置。
$x = 2$：询问 $g(u \rightarrow v)$ 的值。

## 输出格式

对于每个操作二，在一行上输出一个整数，表示 $g(u \rightarrow v)$ 的值。

## 样例

### 样例 1

**输入：**
```
5 5
0 0 0 0 0
1 2
1 3
2 4
2 5
2 1 4
1 1 3
2 4 1
1 2 5
2 5 1
```

**输出：**
```
0
1
7
```

**说明：**
第一次询问时得到的字符串为 $000$，第二次询问得到的字符串为 $001$，第三次询问得到的字符串为 $111$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687731/detail?pid=66528871&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687731/detail?pid=66528871&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:35:17.432756+00:00', '2026-07-02T16:35:49.995071+00:00', 2000, 262144, '技术'),
	(169, '交换括号', '交换括号', '美团', 'Medium', 'simulation', '我们称一个括号序列为“平衡的括号序列”，当且仅当满足以下归纳定义： 

1) 空串是平衡的； 

2) 若字符串 $A$ 是平衡的，则“$(A)$”是平衡的； 

3) 若字符串 $A$ 与 $B$ 均是平衡的，则“$AB$”是平衡的（表示连接）。 

例如：括号序列 $()()$ 与 $(())$ 是平衡的；而 $)$、$)($、 $($ 不是。 

给定一个偶数长度的括号序列 s（仅包含 ''('' 与 '')''）。你可以进行若干次如下操作： 

选择一个位置 $i（1 ≤ i < n）$，交换相邻的两个字符 $s_i$ 与 $s_{i+1}$。

请你计算，最少需要进行多少次这样的相邻交换，才能使整个序列变为一个平衡的括号序列。

## 输入格式

每个测试文件均包含多组测试数据。第一行输入一个整数 $T\left(1\leqq T\leqq 10^5\right)$ 代表数据组数，每组测试数据描述如下：
第一行输入一个偶数 $n\ \left(2\leqq n\leqq 2\times 10^5\right)$； 
第二行输入一个长度为 $n$ 的字符串 $s$（仅包含 ''('' 与 '')''）。 
保证所有测试中 $n$ 的总和不超过 $2\times 10^5$,保证每组数据一定可以通过相邻交换变为平衡序列。

## 输出格式

对于每组测试数据，输出一行一个整数，表示将 s 变为平衡括号序列所需的最少相邻交换次数。

## 样例

### 样例 1

**输入：**
```
3
2
)(
4
()()
4
))((
```

**输出：**
```
1
0
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687731/detail?pid=66528871&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687731/detail?pid=66528871&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:34:32.223986+00:00', '2026-07-02T16:36:00.415593+00:00', 2000, 262144, '技术'),
	(168, '无限循环', '无限循环', '美团', 'Medium', 'simulation', '小美有一个长度为 $n$ 的数组 $\{a_1,a_2,\dots,a_n \}$，她为了研究这个数组做出了个大胆的决定。现在，将与初始数组完全相同的数组连续拼接到其末尾，共拼接 $10^9$ 次。设拼接完成后的新数组记为 $a''$，则新数组的长度为 $n \times \left(10^9+1\right)$，并且对于任意的 $n < i \leqq n \times \left(10^9+1\right)$，都有 $a''_i = a''_{i-n}$。 

请你计算新数组 $a''$ 的最长严格递增子序列的长度，并输出这个长度。

【名词解释】

子序列：从原序列中删除任意个（可以为零、可以为全部）元素后按原相对顺序得到的新序列。 

严格递增子序列：子序列中相邻元素的值严格递增，即若子序列为 $\{b_1,b_2,\dots,b_k\}$，则对所有 $1\leqq i<k$，都有 $b_i<b_{i+1}$。

## 输入格式

每个测试文件均包含多组测试数据。第一行输入一个整数 $T\left(1\leqq T\leqq 10^4\right)$ 代表数据组数，每组测试数据描述如下： 
第一行输入一个整数 $n\left(1\leqq n\leqq 2\times 10^5\right)$，表示原数组的长度； 
第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n\left(1\leqq a_i\leqq n\right)$，表示原数组的元素。 
除此之外，保证单个测试文件的 $n$ 之和不超过 $2 \times 10^5$。

## 输出格式

对于每一组测试数据，新起一行，输出一个整数，表示新数组的最长严格递增子序列长度。

## 样例

### 样例 1

**输入：**
```
2
4
1 1 2 3
5
4 5 3 3 4
```

**输出：**
```
3
3
```

**说明：**
在这组测试数据中： 
对于第 $1$ 组，最终最长严格递增子序列为 $\{1,2,3\}$', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687731/detail?pid=66528871&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687731/detail?pid=66528871&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:34:01.878546+00:00', '2026-07-02T16:36:11.680476+00:00', 2000, 262144, '技术'),
	(166, '超级斐波那契数列', '超级斐波那契数列', '美团', 'Medium', 'simulation', '定义超级斐波那契数列如下：给定整数 $k$，该序列的前 $k$ 项均为 $1$；对于 $n > k$，第 $n$ 项为前 $k$ 项之和，即

$\displaystyle S_n = S_{n-1} + S_{n-2} + \dots + S_{n-k}$

现给定整数 $k$ 和查询次数 $q$，每次查询一个正整数 $x$，请输出该序列的第 $x$ 项对 $10^9 + 7$ 取模后的值。

## 输入格式

第一行输入两个整数 $k, q$ $\left(1 \le k \le 10^6;\ 1 \le q \le 3\times 10^5\right)$； 
此后 $q$ 行，每行输入一个正整数 $x$ $\left(1 \le x \le 10^6\right)$。

## 输出格式

输出 $q$ 行，每行输出一个整数，表示对应查询的答案对 $10^9 + 7$ 取模后的值。

## 样例

### 样例 1

**输入：**
```
2 5
1
2
3
4
5
```

**输出：**
```
1
1
2
3
5
```

**说明：**
在这组测试数据中：
当 $x = 1$ 时，$S_1 = 1$；
当 $x = 2$ 时，$S_2 = 1$；
当 $x = 3$ 时，$S_3 = S_2 + S_1 = 1 + 1 = 2$；
当 $x = 4$ 时，$S_4 = S_3 + S_2 = 2 + 1 = 3$；
当 $x = 5$ 时，$S_5 = S_4 + S_3 = 3 + 2 = 5$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687767/detail?pid=66371978&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687767/detail?pid=66371978&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:32:32.469665+00:00', '2026-07-02T16:36:33.770539+00:00', 2000, 262144, '技术'),
	(223, '二叉树中和为某一值的路径(一)', '二叉树中和为某一值的路径(一)', '牛客', 'Easy', 'tree', '给定一个二叉树root和一个值 sum ，判断是否有从根节点到叶子节点的节点值之和等于 sum 的路径。

1.该题路径定义为从树的根结点开始往下一直到叶子结点所经过的结点 
2.叶子节点是指没有子节点的节点 
3.路径只能从父节点到子节点，不能从子节点到父节点 
4.总节点数目为n 

例如：
给出如下的二叉树，$\ sum=22$，

![题面配图](https://uploadfiles.nowcoder.com/images/20200807/999991351_1596786493913_8BFB3E9513755565DC67D86744BB6159)

返回true，因为存在一条路径 $5\to 4\to 11\to 2$的节点值之和为 22 

数据范围： 
1.树上的节点数满足 $0 \le n \le 10000$ 
2.每 个节点的值都满足 $|val| \le 1000$

要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$ 
进阶：空间复杂度 $O(树的高度)$，时间复杂度 $O(n)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{5,4,8,1,11,#,9,#,#,2,7},22
```

**输出：**
```
true
```

### 样例 2

**输入：**
```
{1,2},0
```

**输出：**
```
false
```

### 样例 3

**输入：**
```
{1,2},3
```

**输出：**
```
true
```

### 样例 4

**输入：**
```
{},0
```

**输出：**
```
false
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/508378c0823c423baa723ce448cbfd0c?tpId=295&tqId=634&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/508378c0823c423baa723ce448cbfd0c?tpId=295&tqId=634&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.593581+00:00', '2026-07-03T16:41:15.015039+00:00', 2000, 262144, '常见101'),
	(212, '二维数组中的查找', '二维数组中的查找', '牛客', 'Medium', 'binary-search', '在一个二维数组array中（每个一维数组的长度相同），每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。

[

[1,2,8,9],

[2,4,9,12],

[4,7,10,13],

[6,8,11,15]

]

给定 target = 7，返回 true。

给定 target = 3，返回 false。

数据范围：矩阵的长宽满足 $0 \le n,m \le 500$ ， 矩阵中的值满足 $-10^9 \le val \le 10^9$

进阶：空间复杂度 $O(1)$ ，时间复杂度 $O(n+m)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
7,[[1,2,8,9],[2,4,9,12],[4,7,10,13],[6,8,11,15]]
```

**输出：**
```
true
```

**说明：**
存在7，返回true

### 样例 2

**输入：**
```
1,[[2]]
```

**输出：**
```
false
```

### 样例 3

**输入：**
```
3,[[1,2,8,9],[2,4,9,12],[4,7,10,13],[6,8,11,15]]
```

**输出：**
```
false
```

**说明：**
不存在3，返回false', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/abc3fe2ce8e146608e868a70efebf62e?tpId=295&tqId=23256&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/abc3fe2ce8e146608e868a70efebf62e?tpId=295&tqId=23256&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:24:52.045461+00:00', '2026-07-03T12:27:16.357929+00:00', 2000, 262144, '常见101'),
	(222, '二叉树的最大深度', '二叉树的最大深度', '牛客', 'Easy', 'tree', '求给定二叉树的最大深度， 
深度是指树的根节点到任一叶子节点路径上节点的数量。 
最大深度是所有叶子节点的深度的最大值。 
（注：叶子节点是指没有子节点的节点。）

数据范围：$0 \le n \le 100000$，树上每个节点的val满足 $|val| \le 100$
要求： 空间复杂度 $O(1)$,时间复杂度 $O(n)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,2}
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
{1,2,3,4,#,#,5}
```

**输出：**
```
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/8a2b2bf6c19b4f23a9bdb9b233eefa73?tpId=295&tqId=642&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/8a2b2bf6c19b4f23a9bdb9b233eefa73?tpId=295&tqId=642&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.539584+00:00', '2026-07-03T16:41:25.100790+00:00', 2000, 262144, '常见101'),
	(179, '信号模拟-2', '信号模拟', '美团', 'Medium', 'graphs', '如下图所示，有 $2 \times n$ 个仪器，中间的方块是仪器的主体，每个仪器可以充当接收器或者信号源；主体的左右两侧是两个接线点。

现在，我们将左端 $2 \times n$ 个接线点随机分成 $n$ 组，每组各含两个点，并将右端 $2 \times n$ 个接线点同样随机分成 $n$ 组。然后将每组的两个接线点用导线连接。

![题面配图](https://uploadfiles.nowcoder.com/images/20250607/0_1749288338676/9CACA81BFCA6EE2E3B265A2D4BB43C18)

这样一来，我们就得到了一组封闭的信号线路。具体而言：

信号从任一信号源 $i$ 出发，通过右侧接线点；

随后，信号通过与右侧接线点连接的导线到达另外一个仪器的左侧接线点，再经过仪器主体到达右侧接线点；此时，如果这个仪器是接收器，那么就视为接收到了信号（注意，接收到信号不会影响信号继续往后传递）。

这个过程持续进行，最终会形成若干个独立的循环。

现在，记 $x$ 表示在所有接收器均能接收到信号的前提下，$2 \times n$ 个仪器中作为信号源的最少数量。求解 $x$ 的方差。

可以证明答案可以表示为一个不可约分数 $\tfrac{p}{q}$，为了避免精度问题，请直接输出整数 $\left(p \times q^{-1} \bmod M\right)$ 作为答案，其中 $M = 998\,244\,353$，$q^{-1}$ 是满足 $q\times q^{-1} \equiv 1 \pmod{M}$ 的整数。更具体地，你需要找到一个整数 $x \in [0, M)$ 满足 $x \times q$ 对 $M$ 取模等于 $p$，您可以查看样例解释得到更具体的说明。
## 提示
本题中，如果您需要使用到除法的取模，即计算 $\left(p\times q^{-1} \bmod M\right)$ 时，$q^{-1}$ 需要使用公式 $\left(q^{M-2} \bmod M \right)$ 得到。例如，计算 $\left(\tfrac{5}{4} \bmod M\right)$：
$$
\begin{array}{rll}
4^{-1} & = & \left(4^{M-2} \bmod M\right) \\
& = & 748\,683\,265 \\
\hline
\left(\tfrac{5}{4} \bmod M\right) & = & 5 \times4^{-1} \bmod M \\
& = & 5 \times 748\,683\,265 \bmod M \\
& = & 748\,683\,266
\end{array}
$$

## 输入格式

每个测试文件均包含多组测试数据。第一行输入一个整数 $T\left(1\leqq T\leqq 10^4\right)$ 代表数据组数，每组测试数据描述如下：
在一行上输入一个整数 $n\left(1\leqq n\leqq 10^6\right)$ 代表仪器的数量。

## 输出格式

对于每组测试数据，新起一行输出一个整数，表示 $x$ 的方差对 $M=998\,244\,353$ 取模后的结果。

## 样例

### 样例 1

**输入：**
```
3
1
2
3
```

**输出：**
```
0
887328314
168592380
```

**说明：**
对于第一组测试数据，左、右两侧各仅有一种配对方式，构成一个长度为 2 的循环。最小信号源数为 $1$，如下图所示。因此 $E(X)=1$，$D(X)=0$。

![题面配图](https://uploadfiles.nowcoder.com/images/20250808/0_1754660827080/0A7A4A62D6A7946A00BEED951BE5A4BF)

对于第二组测试数据，左侧有三种配对（$\{1,2\},\{3,4\}$；$\{1,3\},\{2,4\}$；$\{1,4\},\{2,3\}$），右侧同样三种，合计 $3\times3=9$ 种等可能组合。计算可得，需要 $1$ 个信号源的概率为 $\tfrac{6}{9}$（如下左图所示，为其中一种情况），需要 $2$ 个信号源的概率为 $\tfrac{3}{9}$（如下右图所示，为其中一种情况），故：
$E(X)=1\times\tfrac{2}{3}+2\times\tfrac{1}{3}=\tfrac{4}{3}$；
$D(X)=E\left([X-E(X)]^2 \right)=(1-\tfrac{4}{3})^2\times\tfrac{2}{3}+(2-\tfrac{4}{3})^2\times\tfrac{1}{3}=\tfrac{2}{9}$。
我们能够找到，$887\,328\,314 \times 9 = 7\,985\,954\,826$，对 $M$ 取模后恰好等于分子 $2$，所以 $887\,328\,314$ 是需要输出的答案。

![题面配图](https://uploadfiles.nowcoder.com/images/20250808/0_1754661128100/9B39F64C1D3112A8D327D96C6AC34005)', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:22.059062+00:00', '2026-07-02T16:40:34.233093+00:00', 2000, 262144, '算法'),
	(178, '颜色交错路径计数', '颜色交错路径计数', '美团', 'Easy', 'tree', '小美有一棵由 $n$ 个节点组成的树，每个节点被涂为红色或黑色。她想统计树中有多少条颜色交错的简单路径。

路径是指任意两个节点之间的唯一简单路径，并且我们也将单个节点自身视为长度为 1 的路径。若一条路径上任意相邻的两个节点颜色不同，则称该路径为颜色交错的路径。

请计算树中颜色交错的路径总数。 

【名词解释】

【树上的路径】从节点 $u$ 到节点 $v$ 的简单路径定义为从节点 $u$ 出发，以节点 $v$ 为终点，随意在树上走，不经过重复的点和边走出来的序列。可以证明，在树上，任意两个节点间有且仅有一条简单路径。

## 输入格式

第一行输入一个整数 $n\ (1 \leqq n \leqq 2\times10^5)$，表示树的节点数量。
接下来 $n-1$ 行，每行输入两个整数 $u$ 和 $v$ $\ (1 \leqq u,v \leqq n;\ u \neq v)$，表示节点 $u$ 与 $v$ 之间有一条无向边。保证输入构成一棵树。
接下来一行，输入一个长度为 $n$ 的字符串 $s$，仅由字符 $\texttt{B}$ 和 $\texttt{R}$ 构成，其中 $s_i=\texttt{B}$ 表示第 $i$ 个节点为黑色；$s_i=\texttt{R}$ 表示红色。

## 输出格式

输出一个整数，表示树中颜色交错的路径总数。

## 样例

### 样例 1

**输入：**
```
6
1 2
2 3
3 4
4 5
3 6
BRBRBB
```

**输出：**
```
16
```

**说明：**
这棵树共有 16 条颜色交错的路径（包括 6 条单节点路径、4 条长度为 2 的路径、3 条长度为 3 的路径、2 条长度为 4 的路径、1 条长度为 5 的路径）。

### 样例 2

**输入：**
```
3
1 2
2 3
BBB
```

**输出：**
```
3
```

**说明：**
只有单节点路径满足颜色交错，共 3 条。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:21.984236+00:00', '2026-07-02T16:40:46.213041+00:00', 2000, 262144, '算法'),
	(176, '转化-', '转化', '美团', 'Medium', 'simulation', '小美有一个长度为 $n$，仅由大小写英文字母组成的字符串 $s$。小美将对字符串执行以下 $m$ 次操作： 

当操作类型 $op=1$ 且给定两个小写字母 $letter1,letter2$（满足 $letter1\leqq letter2$）时，将字符串中所有位于字母表中 $\texttt{[letter1,letter2]}$ 的小写字母转换为对应的大写字母； 

当操作类型 $op=2$ 且给定两个大写字母 $letter1,letter2$（满足 $letter1\leqq letter2$）时，将字符串中所有位于字母表中 $\texttt{[letter1,letter2]}$ 的大写字母转换为对应的小写字母。

## 输入格式

在一行上输入两个整数 $n,m\ \left(1\leqq n,m\leqq 2\times10^5\right)$，分别表示字符串长度和操作次数； 
在一行上输入一个长度为 $n$，仅由大小写英文字母组成的字符串 $s$； 
接下来 $m$ 行，每行输入三个元素：整数 $op$ 和两个字符 $letter1,letter2$，满足： 
若 $op=1$，则 $letter1,letter2$ 为小写字母，且 $letter1\leqq letter2$； 
若 $op=2$，则 $letter1,letter2$ 为大写字母，且 $letter1\leqq letter2$。

## 输出格式

输出执行完所有操作后得到的最终字符串。

## 样例

### 样例 1

**输入：**
```
3 1
abc
1 a c
```

**输出：**
```
ABC
```

**说明：**
在此样例中，初始字符串 $\texttt{"abc"}$，将区间 $\texttt{[a,c]}$ 的小写字母统一转换成大写，得到 $\texttt{"ABC"}$。

### 样例 2

**输入：**
```
6 2
aAbBcC
1 a b
2 B C
```

**输出：**
```
AAbbcc
```

**说明：**
在此样例中， 
第一次操作将字符串中所有满足字母表区间$\texttt{[a,b]}$所有小写字母的变为大写字母，得到 $\texttt{"AABBcC"}$； 
第二次操作将字符串中所有满足字母表区间$\texttt{[B,C]}$所有大写字母的变为小写字母，最终得到 $\texttt{"AAbbcc"}$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:21.855339+00:00', '2026-07-02T16:41:08.539506+00:00', 2000, 262144, '算法'),
	(183, '小美的序列问题-2', '小美的序列问题', '美团', 'Medium', 'simulation', '对于给定的由 n 个整数组成的数组 $\{a_1,a_2,\dots,a_n\}$，计算其中有多少个三元组 $(i,j,k)$ 满足 $1\leqq i < j < k \leqq n$ 且 $a_i>a_k>a_j$。例如，在数组$\{4,1,2,3\}$ 中三元组 $(1,2,3) ,(1,2,4),(1,3,4)$ 都是满足条件的三元组。更具体地，计算：

$\displaystyle\sum\limits_{1\leqq i < j < k \leqq n}\left[a_i>a_k>a_j\right]$

请编写一个函数，计算并返回满足条件的三元组的数量。

【名词解释】

本题公式中的中括号代表艾弗森括号，具体地，$[P] = \begin{cases} 1 & \text{如果 } P \text{ 为真} \\ 0 & \text{如果 } P \text{ 为假} \end{cases}$。

## 输入格式

第一行输入一个整数 $n \left(1\leqq n \leqq 2\times 10^5\right)$ 代表数组中的元素个数。
第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n \left(-10^9\leqq a_i \leqq 10^9\right)$ 代表数组中的元素。

## 输出格式

输出一个整数，表示满足条件的三元组个数。

## 样例

### 样例 1

**输入：**
```
5
1 5 4 2 3
```

**输出：**
```
2
```

**说明：**
在这个样例中，满足条件的三元组有：
$i=2$、$j=4$ 且 $k=5$ 构成的三元组 $\{5,2,3\}$；
$i=3$、$j=4$ 且 $k=5$ 构成的三元组 $\{4,2,3\}$。

### 样例 2

**输入：**
```
20
-6 -9 -90 -73 89 -90 2 19 52 -16 -41 -22 85 24 -22 66 75 78 48 -36
```

**输出：**
```
134
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:22.297240+00:00', '2026-07-02T16:39:43.530441+00:00', 2000, 262144, '算法'),
	(182, '魔法路径', '魔法路径', '美团', 'Medium', 'graphs', '在一个奇幻王国里，有 $n$ 个城市（编号依次为 $1$ 到 $n$）和 $m$ 条双向道路，第 $i$ 条道路连接城市 $u_i$ 和 $v_i$，基础通行时间为正整数 $w_i$。此外，王国中每个城市都存在 $1$ 个中枢魔法石，每个魔法石有一个能量值，非负能量值的魔法石称之为「坏魔法石」，负数能量值的魔法石称之为「好魔法石」，坏魔法石会增加通行所需时间，好魔法石会减少通行所需时间（增加和减少的时间即为能量值的多少），如果好魔法石足够强力，甚至可以实现时间倒流。

坏魔法石将会强制生效，导致基础通行时间增加，无法被控制。

好魔法石可以控制，选择是否生效，但使用好魔法石的总次数存在限制，第 $k$ 次使用好魔法石生效以后，之后将无法利用任何城市的好魔法石来减少通行时间。换句话说，单次行程中好魔法石总使用次数不超过 $k$ 次。

魔法石不会消失，可以多次使用。

当你从城市 $u$ 前往城市 $v$ 时，路径的实际通行时间计算如下：

通行时间 = 城市 $u$ 到城市 $v$ 的道路基础通行时间加上城市 $v$ 生效的魔法石能量值。

请计算从城市 $1$ 到城市 $n$ 的最小实际通行时间，注意，您可以重复经过城市和道路。特别地，如果无论如何都无法到达城市 $n$，直接输出 $\text{NO}$。

## 输入格式

第一行输入三个整数 $n,m,k$ $\Big(2 \leqq n \leqq 10^3;$ $1 \leqq m \leqq \min\left\{2 \times 10^3,\tfrac{n \times (n-1)}{2}\right\};$ $1 \leqq k \leqq 10^3\Big)$。
第二行输入 $n$ 个整数 $a_1,a_2\dots,a_n \left(-10^5 \leqq a_i \leqq 10^5\right)$，其中 $a_i$ 表示第 $i$ 个城市的魔法石能量。
接下来 $m$ 行，第 $i$ 行输入三个整数 $u_i,v_i,w_i$ $\big(1 \leqq u_i,v_i \leqq n;$ $u_i \neq v_i;$ $1 \leqq w_i \leqq 10^5\big)$，表示城市 $u_i$ 与城市 $v_i$ 之间存在一条通行时间为 $w_i$ 的路径。除此之外，保证任意两个城市间至多存在一条道路。

注意，本题不保证图的连通性，即可能存在两个城市无法通过任何路径互相到达的情况。

## 输出格式

如果无论如何都无法到达城市 $n$，直接输出 $\text{NO}$，否则输出一个整数，表示从城市 $1$ 到城市 $n$ 的最小实际通行时间。

## 样例

### 样例 1

**输入：**
```
5 5 2
0 0 0 -10 0
1 2 1
2 3 1
3 5 1
1 4 6
4 5 1
```

**输出：**
```
-13
```

**说明：**
在这个样例中，唯一的最优走法是，$1 \to 2 \to 3 \to 5 \to 4 \to 5 \to 4 \to 5$，实际通行时间为 $1+1+1+(1-10)+1+(1-10)+1$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:22.233696+00:00', '2026-07-02T16:40:01.217362+00:00', 2000, 262144, '算法'),
	(181, '手写实现的二分类预测器', '手写实现的二分类预测器', '美团', 'Medium', 'simulation', '请你在仅使用 numpy / pandas的前提下，手写实现高斯朴素贝叶斯（Gaussian Naive Bayes，GNB），并对给定测试样本输出类别预测。具体流程：

1. 读取数据

-  train 字段：二维列表，每行最后一列为类别标签 y∈{0,1}，其余为数值特征

-  test 字段：二维列表，仅包含与训练集同维度的特征

2. 参数估计

-  对每个类别 c 计算先验$\pi_c = \frac{N_c}{N}$ 

-  对每个特征计算类条件独立假设下的 均值 $\mu_{cj}$与 方差 $\sigma_{cj}^2$（总体方差 ddof=0；若方差为 0，令 $\sigma_{cj}^2 = 1\mathrm{e}{-9}$）

3. 预测

-  使用对数后验：

$\log P(c\mid x)=\log\pi_c+\sum_j

\Bigl[-\tfrac12\log(2\pi\sigma_{cj}^2)

-\frac{(x_j-\mu_{cj})^2}{2\sigma_{cj}^2}\Bigr]$ 

-  取 $\arg\max_c \log P(c\mid x)$ 作为预测标签

4. 结果输出

-  预测值保留整数 0/1，以 JSON 数组形式一次性输出，顺序与输入 test 保持一致

## 输入格式

标准输入为 一行 JSON：
-  n 行训练样本，m 维特征，最后一列为标签
-  所有值均为浮点数 / 整数，无额外空行

## 输出格式

标准输出仅含一行：即测试集中每个样本的预测标签（整数），使用单行 JSON 数组表示。

## 样例

### 样例 1

**输入：**
```
{"train": [[1,1,0],[1.1,0.9,0],[4,4,1],[4.2,3.8,1]], "test": [[1,1],[4,4]]}
```

**输出：**
```
[0, 1]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:22.175991+00:00', '2026-07-02T16:40:12.862056+00:00', 2000, 262144, '算法'),
	(213, '寻找峰值', '寻找峰值', '牛客', 'Medium', 'binary-search', '给定一个长度为n的数组nums，请你找到峰值并返回其索引。数组可能包含多个峰值，在这种情况下，返回任何一个所在位置即可。 
1.峰值元素是指其值严格大于左右相邻值的元素。严格大于即不能有等于 
2.假设 nums[-1] = nums[n] = $-\infty$ 
3.对于所有有效的 i 都有 nums[i] != nums[i + 1] 
4.你可以使用O(logN)的时间复杂度实现此问题吗？ 

数据范围： 
$1 \le nums.length \le 2\times 10^5 \$

$-2^{31}<= nums[i] <= 2^{31} - 1$

如输入[2,4,1,2,7,8,4]时，会形成两个山峰，一个是索引为1，峰值为4的山峰，另一个是索引为5，峰值为8的山峰，如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211014/423483716_1634212356346/9EB9CD58B9EA5E04C890326B5C1F471F)

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[2,4,1,2,7,8,4]
```

**输出：**
```
1
```

**说明：**
4和8都是峰值元素，返回4的索引1或者8的索引5都可以

### 样例 2

**输入：**
```
[1,2,3,1]
```

**输出：**
```
2
```

**说明：**
3 是峰值元素，返回其索引 2', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/fcf87540c4f347bcb4cf720b5b350c76?tpId=295&tqId=2227748&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/fcf87540c4f347bcb4cf720b5b350c76?tpId=295&tqId=2227748&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:24:52.099918+00:00', '2026-07-03T12:26:56.973686+00:00', 2000, 262144, '常见101'),
	(180, '组数制进二-2', '组数制进二', '美团', 'Medium', 'bit-manipulation', '小美有一个长度为 $n$ 的数组 $\{a_1,a_2,\dots,a_n\}$，他希望构造一个非负整数 $x$，满足 $x$ 的二进制位数不超过数组中最大值的二进制位数（特别的 $0$ 二进制位数为 $1$ ）。 

随后，可对数组 $a$ 重复进行以下操作，以使所有元素的总和最大： 

选择一个下标 $i$，同时将 $a_i$ 修改为 $a_i\operatorname{or} x$，将 $x$ 修改为 $a_i\operatorname{and} x$。 

在使元素总和达到最大值的前提下，要求所有操作前初始的 $x$ 尽可能小。请输出最大总和及对应的最小 $x$。

按位或：$\operatorname{or}$ 表示按位或运算，即对两个整数的二进制表示的每一位进行逻辑或操作。 

按位与：$\operatorname{and}$ 表示按位与运算，即对两个整数的二进制表示的每一位进行逻辑与操作。

## 输入格式

每个测试文件均包含多组测试数据。 
第一行输入一个整数 $T\left(1\leqq T\leqq 1000\right)$，代表数据组数； 

对于每组测试数据，输入如下： 
第一行输入一个整数 $n\left(1\leqq n\leqq 500\right)$，表示数组的长度； 
第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n\left(0\leqq a_i<2^{30}\right)$，表示数组 $a$ 的元素。

## 输出格式

对于每组测试数据，新起一行。输出两个整数，用空格分隔：第一个整数为数组可以达到的最大总和；第二个整数为在达到最大总和的前提下初始最小的 $x$。

## 样例

### 样例 1

**输入：**
```
2
2
3 3
3
1 2 3
```

**输出：**
```
6 0
9 3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687724/detail?pid=63316151&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:22.116321+00:00', '2026-07-02T16:40:22.942964+00:00', 2000, 262144, '算法'),
	(177, '单主成分压缩后的均方重建误差', '单主成分压缩后的均方重建误差', '美团', 'Medium', 'matrix-grid', '给定一批训练样本与若干测试样本，请你手写实现主成分分析 (PCA) 并仅保留第一主成分来压缩-重建数据，最后输出每个测试样本在重建后的均方误差 (MSE)。

1. 输入读取

-  train - 二维列表，每行是一个 m 维数值特征向量

-  test - 二维列表，维度同上

2. 去均值 (mean-center)

$X_\text{c} = X - \boldsymbol\mu,\quad

\boldsymbol\mu=\text{mean}(X_\text{train})$

3. 协方差矩阵 (总体方差，ddof=0)

$\Sigma = \tfrac1n X_\text{c}^{\!\top}\,X_\text{c}$

4. 求第一主成分

-  用 numpy.linalg.eigh 得到全部特征对$(\lambda_i,\mathbf{v}_i)$

-  按特征值从大到小选取第一主成分 $\mathbf{v}_{\max}$

-  方向标准化规则 —— 若 $\mathbf{v}_{\max}$首个非零分量为负，则整体乘以 -1；这样方向唯一

5. 投影-重建

$z = (x-\boldsymbol\mu)^\top \mathbf{v}{\max},\quad

\hat x = \boldsymbol\mu + z\,\mathbf{v}{\max}$

6. 输出

-  对每个测试样本计算

$\text{MSE}(x) = \tfrac1m \sum_{j=1}^m (x_j-\hat x_j)^2$

-  结果保留两位小数，使用字符串形式

-  所有测试样本的误差按输入顺序组成 JSON 数组一行输出

## 输入格式

标准输入仅一行，为如下 JSON 对象：
{
"train": [[...], [...], ...],
"test": [[...], [...], ...]
}
其中
-  train 长度 $n\ge2$，每行长度 $m\ge2$
-  test 任意条数，维度同 train
-  所有值为整数或浮点数，无额外空行

## 输出格式

标准输出仅一行 —— 测试集中 每个样本 MSE 的字符串形式（两位小数），用 JSON 数组包裹。

## 样例

### 样例 1

**输入：**
```
{"train": [[0,0],[0,1],[1,0],[1,1]], "test": [[0.5,0.5],[1.5,1.5]]}
```

**输出：**
```
["0.00", "0.50"]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687704/detail?pid=63140456&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:39:21.933583+00:00', '2026-07-02T16:40:57.755136+00:00', 2000, 262144, '算法'),
	(185, '多项特征Naïve Bayes分类器', '多项特征Naïve Bayes分类器', '美团', 'Medium', 'binary-search', '请帮助小美实现一个朴素贝叶斯（Multinomial NB）二分类器，在给定训练集后对测试集输出标签。

小美设计的算法步骤如下： 

1. 输入读取

-  train 字段：二维列表，每行最后一列 y ∈ {0,1}，其余列为非负整数词频

-  test 字段：二维列表，仅含词频特征（维度与训练一致）

2. 平滑：使用拉普拉斯平滑 k = 1

$P(w\mid c)=\frac{n_{c,w}+1}{\sum_{w’}(n_{c,w’}+1)}$，$n_{c,w}$表示在所有训练样本中标签为 c 时第 w 个词的总频次。

3. 先验概率：$\pi_c=\frac{N_c}{N}$，$N_c$为类别 c 的样本数量，N 为总样本数。

4. 对数后验：对样本 x 计算

$\log P(c\mid x)=\log\pi_c+\sum_w x_w\log P(w\mid c)$ 

5. 预测规则：若$log P(1|x) ≥ log P(0|x)$输出 1，否则 0。

## 输入格式

{
"train": [[f11,…,f1m,y1], …, [fn1,…,fnm,yn]],
"test": [[t11,…,t1m], …, [tk1,…,tkm]]
}
行长度必须一致；train[i][:-1] 与 test[j] 均为非负整数词频。

## 输出格式

所有测试样本的预测标签（0/1）按顺序放入 JSON 数组，例如：
[0,1,0]

## 样例

### 样例 1

**输入：**
```
{"train":[[2,0,0,0],[3,1,0,0],[0,0,2,1],[0,1,3,1]],"test":[[1,0,0],[0,1,2]]}
```

**输出：**
```
[0, 1]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:44.828786+00:00', '2026-07-03T10:57:39.351069+00:00', 2000, 262144, '算法'),
	(184, '小美的因子数量-2', '小美的因子数量', '美团', 'Medium', 'intervals', '小美很喜欢因子数量为奇数的数。

现在小芳给了小美一个区间 $\left[l,r\right]$，请你帮小美算出区间内有多少个因子数量为奇数的数。

【名词解释】

因子：对于正整数 $x$，如果存在正整数 $p$ 使得 $x$ 能被 $p$ 整除，则称 $p$ 是 $x$ 的因子。例如，$12$ 的因子有 $1,2,3,4,6,12$。

## 输入格式

第一行输入两个整数 $l,r \left(1 \leqq l\leqq r \leqq 10^{9}\right)$，表示询问的区间。

## 输出格式

输出一个整数，表示区间内因子数量为奇数的数的个数。

## 样例

### 样例 1

**输入：**
```
1 1
```

**输出：**
```
1
```

**说明：**
在这个样例中，区间内唯一可以取到的数字为 $1$，其因子数量只有自身，为奇数。

### 样例 2

**输入：**
```
4 5
```

**输出：**
```
1
```

**说明：**
在这个样例中，区间内只有 $4$ 的因子数量为奇数。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:44.769055+00:00', '2026-07-02T16:44:06.607852+00:00', 2000, 262144, '算法'),
	(191, '小美的01树-2', '小美的01树', '美团', 'Easy', 'tree', '小美有一颗节点编号为 $1 \sim n$ 的树，每个节点只有 $\{0,1\}$ 这两种值之一。

我们设 $u \rightarrow v$ 为节点 $u$ 到节点 $v$ 的简单路径。$g(u \rightarrow v)$ 为从 $u$ 开始到 $v$ 结束的简单路径上经过的所有点（包括 $u,v$）按照先后顺序组成的 $01$ 字符串对应的十进制对 $10^9+7$ 取模的结果。

例如，简单路径 $u \rightarrow v$ 经过所有节点组成的字符串为 $01101$，其对应十进制就是 $13$，因此 $g(u \rightarrow v) = 13 \bmod (10^9+7) = 13$。

小美会进行 $m$ 次以下操作：

操作 $1$：将简单路径 $u \rightarrow v$ 上所有节点的值反置。

操作 $2$：询问 $g(u \rightarrow v)$ 的值。

你需要对小美的每一个操作二进行回答。

【反置】若当前字符为 $\tt 0$ ，反置后为 $\tt 1$ ；若当前字符为 $\tt 1$ ，反置后为 $\tt 0$ 。

## 输入格式

第一行输入两个整数 $n,m(1 \leqq n,m \leqq 2 \times 10^5)$ 表示树的大小以及 小美询问的次数。
第二行输入 $n$ 个整数 $a_i(a_i \in \{0,1\})$ 表示第 $i$ 个节点初始的值。

接下来 $n-1$ 行，每一行输入两个整数 $u_i,v_i(1 \leqq u_i,v_i \leqq n)$ 表示节点 $u_i$ 与 $v_i$ 之间有一条边。

接下来 $m$ 行，每一行输入三个整数 $x,u,v(x \in \{1,2\},1 \leqq u,v \leqq n)$，具体的：
$x = 1$：将简单路径 $u \rightarrow v$ 上所有节点的值反置。
$x = 2$：询问 $g(u \rightarrow v)$ 的值。

## 输出格式

对于每个操作二，在一行上输出一个整数，表示 $g(u \rightarrow v)$ 的值。

## 样例

### 样例 1

**输入：**
```
5 5
0 0 0 0 0
1 2
1 3
2 4
2 5
2 1 4
1 1 3
2 4 1
1 2 5
2 5 1
```

**输出：**
```
0
1
7
```

**说明：**
第一次询问时得到的字符串为 $000$，第二次询问得到的字符串为 $001$，第三次询问得到的字符串为 $111$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:45.221431+00:00', '2026-07-02T16:42:47.691576+00:00', 2000, 262144, '算法'),
	(189, '单层 GRU的隐藏状态', '单层 GRU的隐藏状态', '美团', 'Medium', 'matrix-grid', '小美是一位算法工程师，她正在研究一个用于预测用户下单行为的序列模型。为了更好地理解模型内部的运作机制，她决定亲手实现模型核心组件——单层 GRU 的前向传播过程。请你帮助小美完成这个任务，注意，请仅使用 numpy / pandas / scikit-learn 进行实现。

已知输入序列 $\{x_t\}_{t=1}^{T}$（每步维度 d），权重矩阵 / 偏置、以及初始隐藏向量$h_0$（维度 h），请输出最终隐藏状态 $h_T$。

GRU 公式 

对每一时刻 t = 1…T
$$
\begin{aligned}

r_t &= \sigma\!\bigl(x_t W_{xr} + h_{t-1} W_{hr} + b_r\bigr) \\[2pt]

z_t &= \sigma\!\bigl(x_t W_{xz} + h_{t-1} W_{hz} + b_z\bigr) \\[2pt]

\tilde h_t &= \tanh\!\bigl(x_t W_{xh} + (r_t \odot h_{t-1}) W_{hh} + b_h\bigr) \\[2pt]

h_t &= (1 - z_t) \odot h_{t-1} \;+\; z_t \odot \tilde h_t

\end{aligned}
$$
-  $\sigma(x)=1/(1+e^{-x})$，$\odot$为逐元素乘

-  所有权重均以列拼接形式给出：$W_x = [W_{xr}\;|\;W_{xz}\;|\;W_{xh}] \;\in\; \mathbb R^{d\times 3h},

\quad

W_h = [W_{hr}\;|\;W_{hz}\;|\;W_{hh}] \;\in\; \mathbb R^{h\times 3h},$ 偏置 $b=[b_r\;|\;b_z\;|\;b_h]\in\mathbb R^{3h}$。

-  无需反向传播 / 更新——只计算最终 $h_T$。

-  所有运算请用 float64; 结果保留 6 位小数（四舍五入）。

公式各符号含义：

-  $x_t\in\mathbb{R}^d$：第 t 步输入向量（维度 d）。

-  $h_{t-1},h_t\in\mathbb{R}^h$：分别为上一步与当前步的隐藏状态（维度 h）。

-  $r_t=\sigma(\cdot)\in(0,1)^h$（reset gate 重置门）：控制从旧状态 $h_{t-1}$中“带入多少历史”。$r_t$ 越小，对应维度的历史信息被“清空”得越多。

-  $z_t=\sigma(\cdot)\in(0,1)^h$（update gate 更新门）：在旧状态与候选状态之间做软切换。

-  $\tilde h_t=\tanh(\cdot)\in(-1,1)^h$（candidate hidden 候选状态）

## 输入格式

单行 JSON，字段：
{
"Wx": [[...], ...], // d × 3h
"Wh": [[...], ...], // h × 3h
"b": [...], // 长度 3h
"h0": [...], // 长度 h
"X": [[...], ...] // T × d (按时间顺序)
}
-  d,h,T 皆 ≤ 3
-  所有值为数值；不含缺失
-  "Wx"：二维数组，形状 [d,3h]。即$[W_{xr}\,|\,W_{xz}\,|\,W_{xh}]$。
-  "Wh"：二维数组，形状 [h,3h]。即 $[W_{hr}\,|\,W_{hz}\,|\,W_{hh}]$。
-  "b"：一维数组，长度 3h。依次对应$[b_r,\,b_z,\,b_h]$。
-  "h0"：一维数组，长度 h。初始隐藏状态 $h_0$。
-  "X"：二维数组，形状 [T,d]。按时间顺序存放各步输入$x_t$；即第 t 行就是$x_t$。

## 输出格式

仅一行：
[hT_1, hT_2, …] // 长度 = h
每元素保留 6 位小数（使用round(x,6)即可），顺序与隐藏维度一致。

## 样例

### 样例 1

**输入：**
```
{"Wx":[[0.5,0,0.5,0,1,0],[0,0.5,0,0.5,0,1]],"Wh":[[0,0,0,0,0,0],[0,0,0,0,0,0]],"b":[0,0,0,0,0,0],"h0":[0,0],"X":[[0,0]]}
```

**输出：**
```
[0.0, 0.0]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:45.101565+00:00', '2026-07-02T16:43:09.419336+00:00', 2000, 262144, '算法'),
	(188, '无限循环-2', '无限循环', '美团', 'Medium', 'simulation', '小美有一个长度为 $n$ 的数组 $\{a_1,a_2,\dots,a_n \}$，她为了研究这个数组做出了个大胆的决定。现在，将与初始数组完全相同的数组连续拼接到其末尾，共拼接 $10^9$ 次。设拼接完成后的新数组记为 $a''$，则新数组的长度为 $n \times \left(10^9+1\right)$，并且对于任意的 $n < i \leqq n \times \left(10^9+1\right)$，都有 $a''_i = a''_{i-n}$。 

请你计算新数组 $a''$ 的最长严格递增子序列的长度，并输出这个长度。

【名词解释】

子序列：从原序列中删除任意个（可以为零、可以为全部）元素后按原相对顺序得到的新序列。 

严格递增子序列：子序列中相邻元素的值严格递增，即若子序列为 $\{b_1,b_2,\dots,b_k\}$，则对所有 $1\leqq i<k$，都有 $b_i<b_{i+1}$。

## 输入格式

每个测试文件均包含多组测试数据。第一行输入一个整数 $T\left(1\leqq T\leqq 10^4\right)$ 代表数据组数，每组测试数据描述如下： 
第一行输入一个整数 $n\left(1\leqq n\leqq 2\times 10^5\right)$，表示原数组的长度； 
第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n\left(1\leqq a_i\leqq n\right)$，表示原数组的元素。 
除此之外，保证单个测试文件的 $n$ 之和不超过 $2 \times 10^5$。

## 输出格式

对于每一组测试数据，新起一行，输出一个整数，表示新数组的最长严格递增子序列长度。

## 样例

### 样例 1

**输入：**
```
2
4
1 1 2 3
5
4 5 3 3 4
```

**输出：**
```
3
3
```

**说明：**
在这组测试数据中： 
对于第 $1$ 组，最终最长严格递增子序列为 $\{1,2,3\}$', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687740/detail?pid=66528884&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:45.005519+00:00', '2026-07-02T16:43:23.231175+00:00', 2000, 262144, '算法'),
	(187, '最大节点权值-2', '最大节点权值', '美团', 'Medium', 'graphs', '给你一个由 $n$ 个编号为 $1 \sim n$ 的节点以及 $m$ 条编号为 $1 \sim m$ 的边组成的无向图，我们定义一个节点的权值为它的当前度$^\texttt{[1]}$（即已执行完之前所有操作后的状态）加上它的节点编号。

小美会进行 $q$ 次如下操作：

操作一：断开编号为 $x$ 的边，保证每条边至多被删除一次，即在进行操作一时，该边当前一定存在于图中。

操作二：向你询问编号为 $x$ 的节点所在的连通块$^\texttt{[2]}$中所有节点中最大的权值，你需要将此权值告诉他。

【名词解释】

度$^\texttt{[1]}$：与一个顶点相连接的边的条数称为该顶点的度。

连通块$^\texttt{[2]}$：也称连通分量，满足，

是原图的一个子图；

连通块内的任意两个顶点之间都存在路径相连，且路径上的点也在连通块内；

是极大的，即不能再通过添加原图中的其他顶点而依旧保持连通性；

单独的点也构成一个连通块。连通块的大小即为连通块中顶点的数量。

## 输入格式

第一行输入三个正整数 $n,m,q \left(1 \leqq n,q \leqq 2 \times 10^5;\,0 \leqq m \leqq \min\big\{\tfrac{n \times (n-1)}{2},2 \times 10^5\big\} \right)$ 表示节点个数，边个数，操作次数。
此后 $m$ 行，第 $i$ 行输入两个整数 $u_i$ 和 $v_i\ (1 \leqq u_i, v_i \leqq n;\ u_i \neq v_i)$ 表示图上第 $i$ 条边连接节点 $u_i$ 和 $v_i$。
此后 $q$ 行，第 $i$ 行先输入一个整数 $o_i \left(1 \leqq o_i \leqq 2 \right)$，表示操作编号。编号同题面，随后在同一行：
若 $o_i=1$，输入一个整数 $x_i \left(1 \leqq x_i \leqq m \right)$，表示断掉的边的编号；

若 $o_i=2$，输入一个整数 $x_i \left(1 \leqq x_i \leqq n \right)$，表示询问的节点编号。

保证图没有重边和自环，操作一合法。

## 输出格式

输出若干行，每一行对操作二进行回答。

## 样例

### 样例 1

**输入：**
```
5 5 5
1 2
1 5
3 5
2 4
1 3
2 4
1 1
2 2
1 2
2 1
```

**输出：**
```
7
5
6
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:44.943808+00:00', '2026-07-02T16:43:34.668712+00:00', 2000, 262144, '算法'),
	(186, '别样的树', '别样的树', '美团', 'Easy', 'tree', '给定一棵以根节点 $1$ 为根的无向树，节点编号为 $1,2,\dots,n$，每个节点 $i$ 的权值为 $x_i$。对于每个节点 $i\,(i>1)$： 

沿原树从 $i$ 到根 $1$ 的路径，找到离节点 $i$ 最近的第一个权值严格大于 $x_i$ 的祖先节点 $j$； 

如果 $j$ 存在，在节点 $i$ 与节点 $j$ 之间添加一条额外的无向边；否则，不进行任何操作。

在加入所有额外边之后，计算每个节点到根节点 $1$ 的最短距离（以边数计）。

【名词解释】

祖先节点：在一棵以 $u$ 为根的树中，若点 $x$ 在 $u$ 到 $v$ 的简单路径上，且 $x \ne v$，则称 $x$ 是 $v$ 的祖先节点。根节点没有祖先节点。

## 输入格式

第一行输入整数 $n\left(1\leqq n\leqq2\times10^5\right)$，表示节点数量； 
第二行输入 $n$ 个整数 $x_1,x_2,\dots,x_n\left(1\leqq x_i\leqq10^{11}\right)$，表示各节点权值； 
接下来 $\;n-1\;$ 行，每行输入两个整数 
$u_i,v_i\left(1\leqq u_i,v_i\leqq n;\;u_i\neq v_i\right)$，表示一条无向边。保证边集构成一棵以 $1$ 为根的树。

## 输出格式

在同一行输出 $n$ 个整数 $d_1,d_2,\dots,d_n$ 以空格分隔，其中 $d_i$ 表示在加入额外边之后，节点 $i$ 到根节点 $1$ 的最短距离。

## 样例

### 样例 1

**输入：**
```
7
7 1 2 3 4 5 6
1 2
2 3
3 4
5 4
5 6
6 7
```

**输出：**
```
0 1 1 1 1 1 1
```

**说明：**
![题面配图](https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91)
原树是一条链：$1-2-3-4-5-6-7$，各点权值为$[7,1,2,3,4,5,6]$。 
对于每个节点$i>1$，沿原树从$i$到$1$的路径，找到第一个权值严格大于$x_i$的祖先并添加额外边： 
节点2：路径$2\to1$，找到祖先$1$（$7>1$），添加边$2-1$； 
节点3：路径$3\to2\to1$，找到祖先$1$（$7>2$），添加边$3-1$； 
节点4：路径$4\to3\to2\to1$，找到祖先$1$（$7>3$），添加边$4-1$； 
… 
添加所有额外边后，节点$2,\dots,7$均可通过新边直接到达根$1$，距离均为$1$；根节点$1$距离为$0$。

### 样例 2

**输入：**
```
5
9 6 3 5 4
1 2
1 3
3 4
4 5
```

**输出：**
```
0 1 1 1 2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2026, 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97687779/detail?pid=66371994&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D179&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-02T16:41:44.886405+00:00', '2026-07-02T16:43:45.820138+00:00', 2000, 262144, '算法'),
	(235, '输出二叉树的右视图', '输出二叉树的右视图', '牛客', 'Medium', 'tree', '请根据二叉树的前序遍历，中序遍历恢复二叉树，并打印出二叉树的右视图 

数据范围： $0 \le n \le 10000$
要求： 空间复杂度 $O(n)$，时间复杂度 $O(n)$

如输入[1,2,4,5,3],[4,2,5,1,3]时，通过前序遍历的结果[1,2,4,5,3]和中序遍历的结果[4,2,5,1,3]可重建出以下二叉树： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211014/423483716_1634208293748/10FB15C77258A991B0028080A64FB42D)

所以对应的输出为[1,3,5]。 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,2,4,5,3],[4,2,5,1,3]
```

**输出：**
```
[1,3,5]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c9480213597e45f4807880c763ddd5f0?tpId=295&tqId=1073834&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c9480213597e45f4807880c763ddd5f0?tpId=295&tqId=1073834&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:34.187371+00:00', '2026-07-03T16:38:54.208815+00:00', 2000, 262144, '常见101'),
	(315, '国际交流会', '国际交流会', '阿里', 'Medium', 'simulation', '最近小强主办了一场国际交流会，大家在会上以一个圆桌围坐在一起。由于大会的目的就是让不同国家的人感受一下不同的异域气息，为了更好地达到这个目的，小强希望最大化邻座两人之间的差异程度和。为此，他找到了你，希望你能给他安排一下座位，达到邻座之间的差异之和最大。

## 输入格式

输入总共两行。
第一行一个正整数$\mathit n$，代表参加国际交流会的人数(即圆桌上所坐的总人数，不单独对牛牛进行区分）
第二行包含$\mathit n$个正整数，第$\mathit i$个正整数$a_i$代表第$\mathit i$个人的特征值。
其中$3\leq n\leq10^5,\ 1\leq a_i\leq10^9$
注意：
邻座的定义为: 第$\text 1$人$(\text 1\mathit <i<n)$的邻座为$\mathit i-1,i+1$，第$\text 1$人的邻座是$\text 2,n$，第$\mathit n$人的邻座是$\text 1,n-1$。
邻座$\mathit i,j$的差异值计算方法为$|a_i-a_j|$。
每对邻座差异值只计算一次。

## 输出格式

输出总共两行。
第一行输出最大的差异值。
第二行输出用空格隔开的$\mathit n$个数，为重新排列过的特征值。
（注意：不输出编号）
如果最大差异值情况下有多组解，输出任意一组即可。

## 样例

### 样例 1

**输入：**
```
4
3 6 2 9
```

**输出：**
```
20
6 2 9 3
```

**说明：**
这么坐的话
差异和为$\text |6-2|+|2-9|+|9-3|+|3-6|=20$为最大的情况。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.833882+00:00', '2026-07-04T03:08:20.712663+00:00', 2000, 262144, '技术'),
	(215, '旋转数组的最小数字', '旋转数组的最小数字', '牛客', 'Easy', 'binary-search', '有一个长度为 n 的非降序数组，比如[1,2,3,4,5]，将它进行旋转，即把一个数组最开始的若干个元素搬到数组的末尾，变成一个旋转数组，比如变成了[3,4,5,1,2]，或者[4,5,1,2,3]这样的。请问，给定这样一个旋转数组，求数组中的最小值。

数据范围：$1 \le n \le 10000$，数组中任意元素的值: $0 \le val \le 10000$ 
要求：空间复杂度：$O(1)$ ，时间复杂度：$O(logn)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[3,4,5,1,2]
```

**输出：**
```
1
```

### 样例 2

**输入：**
```
[3,100,200,3]
```

**输出：**
```
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/9f3231a991af4f55b95579b44b7a01ba?tpId=295&tqId=23269&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/9f3231a991af4f55b95579b44b7a01ba?tpId=295&tqId=23269&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:24:52.201923+00:00', '2026-07-03T12:26:12.608374+00:00', 2000, 262144, '常见101'),
	(217, '二叉树的前序遍历', '二叉树的前序遍历', '牛客', 'Easy', 'tree', '给你二叉树的根节点 root ，返回它节点值的 前序 遍历。 

数据范围：二叉树的节点数量满足 $1 \le n \le 100 \$ ，二叉树节点的值满足 $1 \le val \le 100 \$ ，树的各节点的值各不相同 

示例 1： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211111/392807_1636599059575/FE67E09E9BA5661A7AB9DF9638FB1FAC)

难度提示：简单

## 样例

### 样例 1

**输入：**
```
{1,#,2,3}
```

**输出：**
```
[1,2,3]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/5e2135f4d2b14eb8a5b06fab4c938635?tpId=295&tqId=2291302&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/5e2135f4d2b14eb8a5b06fab4c938635?tpId=295&tqId=2291302&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T12:31:22.003735+00:00', '2026-07-03T16:39:11.040752+00:00', 2000, 262144, '常见101'),
	(221, '按之字形顺序打印二叉树', '按之字形顺序打印二叉树', '牛客', 'Medium', 'tree', '给定一个二叉树，返回该二叉树的之字形层序遍历，（第一层从左向右，下一层从右向左，一直这样交替） 

数据范围：$0 \le n \le 1500$,树上每个节点的val满足 $|val| <= 1500$
要求：空间复杂度：$O(n)$，时间复杂度：$O(n)$ 
例如：
给定的二叉树是{1,2,3,#,#,4,5}

![题面配图](https://uploadfiles.nowcoder.com/images/20210717/557336_1626492068888/41FDD435F0BA63A57E274747DE377E05)

该二叉树之字形层序遍历的结果是 
[ 
[1], 
[3,2], 
[4,5] 
] 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
{1,2,3,#,#,4,5}
```

**输出：**
```
[[1],[3,2],[4,5]]
```

**说明：**
如题面解释，第一层是根节点，从左到右打印结果，第二层从右到左，第三层从左到右。

### 样例 2

**输入：**
```
{8,6,10,5,7,9,11}
```

**输出：**
```
[[8],[10,6],[5,7,9,11]]
```

### 样例 3

**输入：**
```
{1,2,3,4,5}
```

**输出：**
```
[[1],[3,2],[4,5]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/91b69814117f4e8097390d107d2efbe0?tpId=295&tqId=23454&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/91b69814117f4e8097390d107d2efbe0?tpId=295&tqId=23454&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:38:33.487947+00:00', '2026-07-03T16:41:41.143736+00:00', 2000, 262144, '常见101'),
	(242, '表达式求值', '表达式求值', '牛客', 'Medium', 'stack-queue', '请写一个整数计算器，支持加减乘三种运算和括号。 

数据范围：$0\le |s| \le 100$，保证计算结果始终在整型范围内 

要求：空间复杂度： $O(n)$，时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"1+2"
```

**输出：**
```
3
```

### 样例 2

**输入：**
```
"(2*(3-4))*5"
```

**输出：**
```
-10
```

### 样例 3

**输入：**
```
"3+2*3*4-1"
```

**输出：**
```
26
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c215ba61c8b1443b996351df929dc4d4?tpId=295&tqId=1076787&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c215ba61c8b1443b996351df929dc4d4?tpId=295&tqId=1076787&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.618971+00:00', '2026-07-03T16:51:15.358724+00:00', 2000, 262144, '常见101'),
	(240, '寻找第K大', '寻找第K大', '牛客', 'Medium', 'stack-queue', '有一个整数数组，请你根据快速排序的思路，找出数组中第 k 大的数。 
给定一个整数数组 a ,同时给定它的大小n和要找的 k ，请返回第 k 大的数(包括重复的元素，不用去重)，保证答案存在。 
要求：时间复杂度 $O(nlogn)$，空间复杂度 $O(1)$ 
数据范围：$0\le n \le 1000$， $1 \le K \le n$，数组中每个元素满足 $0 \le val \le 10000000$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,3,5,2,2],5,3
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
[10,10,9,9,8,7,5,6,4,3,4,2],12,3
```

**输出：**
```
9
```

**说明：**
去重后的第3大是8，但本题要求包含重复的元素，不用去重，所以输出9', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/e016ad9b7f0b45048c58a9f27ba618bf?tpId=295&tqId=44581&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/e016ad9b7f0b45048c58a9f27ba618bf?tpId=295&tqId=44581&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.521969+00:00', '2026-07-03T16:51:56.578889+00:00', 2000, 262144, '常见101'),
	(239, '最小的K个数', '最小的K个数', '牛客', 'Medium', 'stack-queue', '给定一个长度为 n 的可能有重复值的数组，找出其中不去重的最小的 k 个数。例如数组元素是4,5,1,6,2,7,3,8这8个数字，则最小的4个数字是1,2,3,4(任意顺序皆可)。

数据范围：$0\le k,n \le 10000$，数组中每个数的大小$0 \le val \le 1000$

要求：空间复杂度 $O(n)$ ，时间复杂度 $O(nlogk)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[4,5,1,6,2,7,3,8],4
```

**输出：**
```
[1,2,3,4]
```

**说明：**
返回最小的4个数即可，返回[1,3,2,4]也可以

### 样例 2

**输入：**
```
[1],0
```

**输出：**
```
[]
```

### 样例 3

**输入：**
```
[0,1,2,1,2],3
```

**输出：**
```
[0,1,1]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/6a296eb82cf844ca8539b57c23e6e9bf?tpId=295&tqId=23263&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/6a296eb82cf844ca8539b57c23e6e9bf?tpId=295&tqId=23263&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.470598+00:00', '2026-07-03T16:52:07.953352+00:00', 2000, 262144, '常见101'),
	(241, '数据流中的中位数', '数据流中的中位数', '牛客', 'Medium', 'stack-queue', '如何得到一个数据流中的中位数？如果从数据流中读出奇数个数值，那么中位数就是所有数值排序之后位于中间的数值。如果从数据流中读出偶数个数值，那么中位数就是所有数值排序之后中间两个数的平均值。我们使用Insert()方法读取数据流，使用GetMedian()方法获取当前读取数据的中位数。 

数据范围：数据流中数个数满足 $1 \le n \le 1000 \$ ，大小满足 $1 \le val \le 1000 \$

进阶： 空间复杂度 $O(n) \$ ， 时间复杂度 $O(nlogn) \$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[5,2,3,4,1,6,7,0,8]
```

**输出：**
```
"5.00 3.50 3.00 3.50 3.00 3.50 4.00 3.50 4.00 "
```

**说明：**
数据流里面不断吐出的是5,2,3...,则得到的平均数分别为5,(5+2)/2,3...

### 样例 2

**输入：**
```
[1,1,1]
```

**输出：**
```
"1.00 1.00 1.00 "
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/9be0172896bd43948f8a32fb954e1be1?tpId=295&tqId=23457&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/9be0172896bd43948f8a32fb954e1be1?tpId=295&tqId=23457&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.571988+00:00', '2026-07-03T16:51:26.686899+00:00', 2000, 262144, '常见101'),
	(238, '滑动窗口的最大值', '滑动窗口的最大值', '牛客', 'Medium', 'stack-queue', '给定一个长度为 n 的数组 num 和滑动窗口的大小 size ，找出所有滑动窗口里数值的最大值。 

例如，如果输入数组{2,3,4,2,6,2,5,1}及滑动窗口的大小3，那么一共存在6个滑动窗口，他们的最大值分别为{4,4,6,6,6,5}； 针对数组{2,3,4,2,6,2,5,1}的滑动窗口有以下6个： {[2,3,4],2,6,2,5,1}， {2,[3,4,2],6,2,5,1}， {2,3,[4,2,6],2,5,1}， {2,3,4,[2,6,2],5,1}， {2,3,4,2,[6,2,5],1}， {2,3,4,2,6,[2,5,1]}。 

窗口大于数组长度或窗口长度为0的时候，返回空。

数据范围： $1 \le n \le 10000$，$0 \le size \le 10000$，数组中每个元素的值满足 $|val| \le 10000$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$

## 样例

### 样例 1

**输入：**
```
[2,3,4,2,6,2,5,1],3
```

**输出：**
```
[4,4,6,6,6,5]
```

### 样例 2

**输入：**
```
[9,10,9,-7,-3,8,2,-6],5
```

**输出：**
```
[10,10,9,8]
```

### 样例 3

**输入：**
```
[1,2,3,4],5
```

**输出：**
```
[]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/1624bc35a45c42c0bc17d17fa0cba788?tpId=295&tqId=23458&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/1624bc35a45c42c0bc17d17fa0cba788?tpId=295&tqId=23458&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.421300+00:00', '2026-07-03T16:52:23.255660+00:00', 2000, 262144, '常见101'),
	(237, '有效括号序列', '有效括号序列', '牛客', 'Easy', 'stack-queue', '给出一个仅包含字符仅由括号字符 $\texttt{`[''}$、$\texttt{`]''}$、$\texttt{`(''}$、$\texttt{`)''}$、$\texttt{`\{''}$、$\texttt{`\}''}$ 的括号序列字符串 $s$（$0 \leqq |s| \leqq 10^4$），你需要判断给出的括号序列字符串 $s$ 是否是有效的括号序列。

有效括号序列的定义如下：

空序列是有效括号序列；

如果 $A$ 是有效括号序列，则 $\texttt{(A)}$、$\texttt{[A]}$ 和 $\texttt{{A}}$ 都是有效括号序列；

如果 $A$ 和 $B$ 都是有效括号序列，则它们的拼接 $AB$ 也是有效括号序列。

如果括号序列字符串 $s$ 是有效的括号序列，返回一个布尔值 $\texttt{true}$；否则返回一个布尔值 $\texttt{false}$。

难度提示：简单

## 样例

### 样例 1

**输入：**
```
"["
```

**输出：**
```
false
```

### 样例 2

**输入：**
```
"[]"
```

**输出：**
```
true
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/37548e94a270412c8b9fb85643c8ccc2?tpId=295&tqId=726&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/37548e94a270412c8b9fb85643c8ccc2?tpId=295&tqId=726&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.370020+00:00', '2026-07-03T16:52:34.348151+00:00', 2000, 262144, '常见101'),
	(236, '用两个栈实现队列', '用两个栈实现队列', '牛客', 'Easy', 'stack-queue', '用两个栈来实现一个队列，使用n个元素来完成 n 次在队列尾部插入整数(push)和n次在队列头部删除整数(pop)的功能。 队列中的元素为int类型。保证操作合法，即保证pop操作时队列内已有元素。 

数据范围： $n\le1000$ 
要求：存储n个元素的空间复杂度为 $O(n)$ ，插入与删除的时间复杂度都是 $O(1)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
["PSH1","PSH2","POP","POP"]
```

**输出：**
```
1,2
```

**说明：**
"PSH1":代表将1插入队列尾部
"PSH2":代表将2插入队列尾部
"POP“:代表删除一个元素，先进先出=>返回1
"POP“:代表删除一个元素，先进先出=>返回2

### 样例 2

**输入：**
```
["PSH2","POP","PSH1","POP"]
```

**输出：**
```
2,1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/54275ddae22f475981afa2244dd448c6?tpId=295&tqId=23281&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/54275ddae22f475981afa2244dd448c6?tpId=295&tqId=23281&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:49:55.306454+00:00', '2026-07-03T16:52:45.865161+00:00', 2000, 262144, '常见101'),
	(244, '数组中出现次数超过一半的数字', '数组中出现次数超过一半的数字', '牛客', 'Easy', 'hashing', '给一个长度为 n 的数组，数组中有一个数字出现的次数超过数组长度的一半，请找出这个数字。 
例如输入一个长度为9的数组[1,2,3,2,2,2,5,4,2]。由于数字2在数组中出现了5次，超过数组长度的一半，因此输出2。 

数据范围：$n \le 50000$，数组中元素的值 $0 \le val \le 10000$ 
要求：空间复杂度：$O(1)$，时间复杂度 $O(n)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[1,2,3,2,2,2,5,4,2]
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
[3,3,3,3,2,2,2]
```

**输出：**
```
3
```

### 样例 3

**输入：**
```
[1]
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/e8a1b01a2df14cb2b228b30ee6a92163?tpId=295&tqId=23271&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/e8a1b01a2df14cb2b228b30ee6a92163?tpId=295&tqId=23271&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:55:05.429689+00:00', '2026-07-03T16:56:15.885339+00:00', 2000, 262144, '常见101'),
	(247, '三数之和', '三数之和', '牛客', 'Medium', 'hashing', '给出一个有n个元素的数组S，S中是否有元素a,b,c满足a+b+c=0？找出数组S中所有满足条件的三元组。 

数据范围：$0 \le n \le 1000$，数组中各个元素值满足 $|val | \le 100$ 
空间复杂度：$O(n^2)$，时间复杂度 $O(n^2)$ 

注意：

- 三元组（a、b、c）中的元素必须按非降序排列。（即a≤b≤c） 
- 解集中不能包含重复的三元组。 
例如，给定的数组 S = {-10 0 10 20 -10 -40},解集为(-10, -10, 20),(-10, 0, 10) 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[0]
```

**输出：**
```
[]
```

### 样例 2

**输入：**
```
[-2,0,1,1,2]
```

**输出：**
```
[[-2,0,2],[-2,1,1]]
```

### 样例 3

**输入：**
```
[-10,0,10,20,-10,-40]
```

**输出：**
```
[[-10,-10,20],[-10,0,10]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/345e2ed5f81d4017bbb8cc6055b0b711?tpId=295&tqId=731&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/345e2ed5f81d4017bbb8cc6055b0b711?tpId=295&tqId=731&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:55:05.584950+00:00', '2026-07-03T16:55:30.512672+00:00', 2000, 262144, '常见101');
INSERT INTO public.problems VALUES
	(245, '数组中只出现一次的两个数字', '数组中只出现一次的两个数字', '牛客', 'Medium', 'hashing', '一个整型数组里除了两个数字只出现一次，其他的数字都出现了两次。请写程序找出这两个只出现一次的数字。 

数据范围：数组长度 $2\le n \le 1000$，数组中每个数的大小 $0 < val \le 1000000$
要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$

提示：输出时按非降序排列。 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,4,1,6]
```

**输出：**
```
[4,6]
```

**说明：**
返回的结果中较小的数排在前面

### 样例 2

**输入：**
```
[1,2,3,3,2,9]
```

**输出：**
```
[1,9]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/389fc1c3d3be4479a154f63f495abff8?tpId=295&tqId=1375231&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/389fc1c3d3be4479a154f63f495abff8?tpId=295&tqId=1375231&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:55:05.479075+00:00', '2026-07-03T16:56:04.114322+00:00', 2000, 262144, '常见101'),
	(243, '两数之和', '两数之和', '牛客', 'Easy', 'hashing', '给出一个整型数组 numbers 和一个目标值 target，请在数组中找出两个加起来等于目标值的数的下标，返回的下标按升序排列。 
（注：返回的数组下标从1开始算起，保证target一定可以由数组里面2个数字相加得到） 

数据范围：$2\leq len(numbers) \leq 10^5$，$-10 \leq numbers_i \leq 10^9$，$0 \leq target \leq 10^9$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(nlogn)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[3,2,4],6
```

**输出：**
```
[2,3]
```

**说明：**
因为 2+4=6 ，而 2的下标为2 ， 4的下标为3 ，又因为 下标2 < 下标3 ，所以返回[2,3]

### 样例 2

**输入：**
```
[20,70,110,150],90
```

**输出：**
```
[1,2]
```

**说明：**
20+70=90', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/20ef0972485e41019e39543e8e895b7f?tpId=295&tqId=745&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/20ef0972485e41019e39543e8e895b7f?tpId=295&tqId=745&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T16:55:05.373713+00:00', '2026-07-03T16:56:31.896832+00:00', 2000, 262144, '常见101'),
	(249, '有重复项数字的全排列', '有重复项数字的全排列', '牛客', 'Medium', 'backtracking', '给出一组可能包含重复项的数字，返回该组数字的所有排列。结果以字典序升序排列。 

数据范围： $0 < n \le 8$ ，数组中的值满足 $-1 \le val \le 5$

要求：空间复杂度 $O(n!)$，时间复杂度 $O(n!)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,1,2]
```

**输出：**
```
[[1,1,2],[1,2,1],[2,1,1]]
```

### 样例 2

**输入：**
```
[0,1]
```

**输出：**
```
[[0,1],[1,0]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/a43a2b986ef34843ac4fdd9159b69863?tpId=295&tqId=700&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/a43a2b986ef34843ac4fdd9159b69863?tpId=295&tqId=700&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.271879+00:00', '2026-07-03T17:43:48.931791+00:00', 2000, 262144, '常见101'),
	(248, '没有重复项数字的全排列', '没有重复项数字的全排列', '牛客', 'Medium', 'backtracking', '给出一组数字，返回该组数字的所有排列 
例如： 
[1,2,3]的所有排列如下
[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2], [3,2,1].
（以数字在数组中的位置靠前为优先级，按字典序排列输出。） 

数据范围：数字个数 $0 < n \le 6$ 
要求：空间复杂度 $O(n!)$ ，时间复杂度 $O(n!）$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,2,3]
```

**输出：**
```
[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
```

### 样例 2

**输入：**
```
[1]
```

**输出：**
```
[[1]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/4bcf3081067a4d028f95acee3ddcd2b1?tpId=295&tqId=701&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/4bcf3081067a4d028f95acee3ddcd2b1?tpId=295&tqId=701&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.208085+00:00', '2026-07-03T17:44:05.770520+00:00', 2000, 262144, '常见101'),
	(253, '括号生成', '括号生成', '牛客', 'Medium', 'backtracking', '给出n对括号，请编写一个函数来生成所有的由n对括号组成的合法组合。

例如，给出n=3，解集为：

"((()))", "(()())", "(())()", "()()()", "()(())"

数据范围：$0 \le n \le 10$

要求：空间复杂度 $O(n)$，时间复杂度 $O(2^n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
1
```

**输出：**
```
["()"]
```

### 样例 2

**输入：**
```
2
```

**输出：**
```
["(())","()()"]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c9addb265cdf4cdd92c092c655d164ca?tpId=295&tqId=725&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c9addb265cdf4cdd92c092c655d164ca?tpId=295&tqId=725&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.459170+00:00', '2026-07-03T17:42:45.226800+00:00', 2000, 262144, '常见101'),
	(252, 'N皇后问题', 'N皇后问题', '牛客', 'Medium', 'backtracking', 'N 皇后问题是指在 n * n 的棋盘上要摆 n 个皇后，

要求：任何两个皇后不同行，不同列也不在同一条斜线上，

求给一个整数 n ，返回 n 皇后的摆法数。

数据范围: $1 \le n \le 9$

要求：空间复杂度 $O(N)$ ，时间复杂度 $O(n!)$

例如当输入4时，对应的返回值为2，

对应的两种四皇后摆位如下图所示：

![题面配图](https://uploadfiles.nowcoder.com/images/20211204/423483716_1638606211798/CFE342EBEEFB9E6839E6ED216B889F16)

## 样例

### 样例 1

**输入：**
```
1
```

**输出：**
```
1
```

### 样例 2

**输入：**
```
8
```

**输出：**
```
92
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c76408782512486d91eea181107293b6?tpId=295&tqId=1008753&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c76408782512486d91eea181107293b6?tpId=295&tqId=1008753&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.410739+00:00', '2026-07-03T17:43:02.488664+00:00', 2000, 262144, '常见101'),
	(251, '字符串的排列', '字符串的排列', '牛客', 'Medium', 'backtracking', '输入一个长度为 n 字符串，打印出该字符串中字符的所有排列，你可以以任意顺序返回这个字符串数组。

例如输入字符串ABC,则输出由字符A,B,C所能排列出来的所有字符串ABC,ACB,BAC,BCA,CBA和CAB。

![题面配图](https://uploadfiles.nowcoder.com/images/20211008/557336_1633676660853/6226390B4185DB132AFFDB10F09F8BEB)

数据范围：$n < 10$

要求：空间复杂度 $O(n!)$，时间复杂度 $O(n!)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"ab"
```

**输出：**
```
["ab","ba"]
```

**说明：**
返回["ba","ab"]也是正确的

### 样例 2

**输入：**
```
"aab"
```

**输出：**
```
["aab","aba","baa"]
```

### 样例 3

**输入：**
```
"abc"
```

**输出：**
```
["abc","acb","bac","bca","cab","cba"]
```

### 样例 4

**输入：**
```
""
```

**输出：**
```
[""]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/fe6b651b66ae47d7acce78ffdd9a96c7?tpId=295&tqId=23291&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/fe6b651b66ae47d7acce78ffdd9a96c7?tpId=295&tqId=23291&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.362448+00:00', '2026-07-03T17:43:15.437166+00:00', 2000, 262144, '常见101'),
	(259, '最长公共子串', '最长公共子串', '牛客', 'Medium', 'dynamic-programming', '给定两个字符串str1和str2,输出两个字符串的最长公共子串 
题目保证str1和str2的最长公共子串存在且唯一。 

数据范围： $1 \le |str1|,|str2| \le 5000$
要求： 空间复杂度 $O(n^2)$，时间复杂度 $O(n^2)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"1AB2345CD","12345EF"
```

**输出：**
```
"2345"
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/f33f5adc55f444baa0e0ca87ad8a6aac?tpId=295&tqId=991150&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/f33f5adc55f444baa0e0ca87ad8a6aac?tpId=295&tqId=991150&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.243270+00:00', '2026-07-03T18:07:26.726645+00:00', 2000, 262144, '常见101'),
	(254, '矩阵最长递增路径', '矩阵最长递增路径', '牛客', 'Medium', 'backtracking', '给定一个 n 行 m 列矩阵 matrix ，矩阵内所有数均为非负整数。 你需要在矩阵中找到一条最长路径，使这条路径上的元素是递增的。并输出这条最长路径的长度。 
这个路径必须满足以下条件：

1. 对于每个单元格，你可以往上，下，左，右四个方向移动。 你不能在对角线方向上移动或移动到边界外。

2. 你不能走重复的单元格。即每个格子最多只能走一次。

数据范围：$1 \le n,m \le 1000$，$0 \le matrix[i][j] \le 1000$ 
进阶：空间复杂度 $O(nm)$ ，时间复杂度 $O(nm)$ 

例如：当输入为[[1,2,3],[4,5,6],[7,8,9]]时，对应的输出为5， 
其中的一条最长递增路径如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20211201/423483716_1638350164758/A6B05D015D3BE3C77C34DDF224044A1F)

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[[1,2,3],[4,5,6],[7,8,9]]
```

**输出：**
```
5
```

**说明：**
1->2->3->6->9即可。当然这种递增路径不是唯一的。

### 样例 2

**输入：**
```
[[1,2],[4,3]]
```

**输出：**
```
4
```

**说明：**
1->2->3->4', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/7a71a88cdf294ce6bdf54c899be967a2?tpId=295&tqId=1076860&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/7a71a88cdf294ce6bdf54c899be967a2?tpId=295&tqId=1076860&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.506566+00:00', '2026-07-03T17:42:24.569056+00:00', 2000, 262144, '常见101'),
	(250, '岛屿数量', '岛屿数量', '牛客', 'Medium', 'backtracking', '给一个01矩阵，1代表是陆地，0代表海洋， 如果两个1相邻，那么这两个1属于同一个岛。我们只考虑上下左右为相邻。

岛屿: 相邻陆地可以组成一个岛屿（相邻:上下左右） 判断岛屿个数。 
例如： 
输入 
[ 
[1,1,0,0,0], 
[0,1,0,1,1], 
[0,0,0,1,1], 
[0,0,0,0,0], 
[0,0,1,1,1] 
] 
对应的输出为3

(注：存储的01数据其实是字符''0'',''1'') 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[[1,1,0,0,0],[0,1,0,1,1],[0,0,0,1,1],[0,0,0,0,0],[0,0,1,1,1]]
```

**输出：**
```
3
```

### 样例 2

**输入：**
```
[[0]]
```

**输出：**
```
0
```

### 样例 3

**输入：**
```
[[1,1],[1,1]]
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/0c9664d1554e466aa107d899418e814e?tpId=295&tqId=1024684&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/0c9664d1554e466aa107d899418e814e?tpId=295&tqId=1024684&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T17:38:55.318045+00:00', '2026-07-03T17:43:32.883905+00:00', 2000, 262144, '常见101'),
	(255, '斐波那契数列', '斐波那契数列', '牛客', 'Medium', 'dynamic-programming', '大家都知道斐波那契数列，现在要求输入一个正整数 n ，请你输出斐波那契数列的第 n 项。 
斐波那契数列是一个满足 $fib(x)=\left\{ \begin{array}{rcl} 1 & {x=1,2}\\ fib(x-1)+fib(x-2) &{x>2}\\ \end{array} \right.$ 的数列 
数据范围：$1\leq n\leq 40$ 
要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$ ，本题也有时间复杂度 $O(logn)$ 的解法

## 样例

### 样例 1

**输入：**
```
4
```

**输出：**
```
3
```

**说明：**
根据斐波那契数列的定义可知，fib(1)=1,fib(2)=1,fib(3)=fib(3-1)+fib(3-2)=2,fib(4)=fib(4-1)+fib(4-2)=3，所以答案为3。

### 样例 2

**输入：**
```
1
```

**输出：**
```
1
```

### 样例 3

**输入：**
```
2
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c6c7742f5ba7442aada113136ddea0c3?tpId=295&tqId=23255&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c6c7742f5ba7442aada113136ddea0c3?tpId=295&tqId=23255&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.048987+00:00', '2026-07-03T18:08:33.494590+00:00', 2000, 262144, '常见101'),
	(260, '不同路径的数目(一)', '不同路径的数目(一)', '牛客', 'Easy', 'dynamic-programming', '一个机器人在m×n大小的地图的左上角（起点）。 
机器人每次可以向下或向右移动。机器人要到达地图的右下角（终点）。 
可以有多少种不同的路径从起点走到终点？ 

![题面配图](https://uploadfiles.nowcoder.com/images/20201210/999991351_1607596327517/873CB1F2327F70DA0CA0FDC797F894A7)

备注：m和n小于等于100,并保证计算结果在int范围内 

数据范围：$0 < n,m \le 100$，保证计算结果在32位整型范围内 
要求：空间复杂度 $O(nm)$，时间复杂度 $O(nm)$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(min(n,m))$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
2,1
```

**输出：**
```
1
```

### 样例 2

**输入：**
```
2,2
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/166eaff8439d4cd898e3ba933fbc6358?tpId=295&tqId=685&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/166eaff8439d4cd898e3ba933fbc6358?tpId=295&tqId=685&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.287735+00:00', '2026-07-03T18:07:10.805275+00:00', 2000, 262144, '常见101'),
	(257, '最小花费爬楼梯', '最小花费爬楼梯', '牛客', 'Easy', 'dynamic-programming', '给定一个整数数组 $cost \$ ，其中 $cost[i]\$ 是从楼梯第$i \$个台阶向上爬需要支付的费用，下标从0开始。一旦你支付此费用，即可选择向上爬一个或者两个台阶。

你可以选择从下标为 0 或下标为 1 的台阶开始爬楼梯。

请你计算并返回达到楼梯顶部的最低花费。 

数据范围：数组长度满足 $1 \le n \le 10^5 \$ ，数组中的值满足 $1 \le cost_i \le 10^4 \$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[2,5,20]
```

**输出：**
```
5
```

**说明：**
你将从下标为1的台阶开始，支付5 ，向上爬两个台阶，到达楼梯顶部。总花费为5

### 样例 2

**输入：**
```
[1,100,1,1,1,90,1,1,80,1]
```

**输出：**
```
6
```

**说明：**
你将从下标为 0 的台阶开始。
1.支付 1 ，向上爬两个台阶，到达下标为 2 的台阶。
2.支付 1 ，向上爬两个台阶，到达下标为 4 的台阶。
3.支付 1 ，向上爬两个台阶，到达下标为 6 的台阶。
4.支付 1 ，向上爬一个台阶，到达下标为 7 的台阶。
5.支付 1 ，向上爬两个台阶，到达下标为 9 的台阶。
6.支付 1 ，向上爬一个台阶，到达楼梯顶部。
总花费为 6 。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/6fe0302a058a4e4a834ee44af88435c7?tpId=295&tqId=2366451&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/6fe0302a058a4e4a834ee44af88435c7?tpId=295&tqId=2366451&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.151194+00:00', '2026-07-03T18:08:03.141905+00:00', 2000, 262144, '常见101'),
	(264, '最长上升子序列(一)', '最长上升子序列(一)', '牛客', 'Medium', 'dynamic-programming', '给定一个长度为 n 的数组 arr，求它的最长严格上升子序列的长度。 
所谓子序列，指一个数组删掉一些数（也可以不删）之后，形成的新数组。例如 [1,5,3,7,3] 数组，其子序列有：[1,3,3]、[7] 等。但 [1,6]、[1,3,5] 则不是它的子序列。 
我们定义一个序列是 严格上升 的，当且仅当该序列不存在两个下标 $i$ 和 $j$ 满足 $i<j$ 且 $arr_i \geq arr_j$。

数据范围： $0\leq n \leq 1000$ 
要求：时间复杂度 $O(n^2)$， 空间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[6,3,1,5,2,3,7]
```

**输出：**
```
4
```

**说明：**
该数组最长上升子序列为 [1,2,3,7] ，长度为4', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/5164f38b67f846fb8699e9352695cd2f?tpId=295&tqId=2281434&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/5164f38b67f846fb8699e9352695cd2f?tpId=295&tqId=2281434&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.474815+00:00', '2026-07-03T18:06:17.127940+00:00', 2000, 262144, '常见101'),
	(262, '把数字翻译成字符串', '把数字翻译成字符串', '牛客', 'Medium', 'dynamic-programming', '有一种将字母编码成数字的方式：''a''->1, ''b->2'', ... , ''z->26''。

现在给一串数字，返回有多少种可能的译码结果

数据范围：字符串长度满足 $0 < n \leq 90$

进阶：空间复杂度 $O(n)$，时间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"12"
```

**输出：**
```
2
```

**说明：**
2种可能的译码结果（”ab” 或”l”）

### 样例 2

**输入：**
```
"31717126241541717"
```

**输出：**
```
192
```

**说明：**
192种可能的译码结果', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/046a55e6cd274cffb88fc32dba695668?tpId=295&tqId=1024831&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/046a55e6cd274cffb88fc32dba695668?tpId=295&tqId=1024831&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.377232+00:00', '2026-07-03T18:06:38.365370+00:00', 2000, 262144, '常见101'),
	(268, '编辑距离(一)', '编辑距离(一)', '牛客', 'Medium', 'dynamic-programming', '给定两个字符串 str1 和 str2 ，请你算出将 str1 转为 str2 的最少操作数。 
你可以对字符串进行3种操作： 
1.插入一个字符 
2.删除一个字符 
3.修改一个字符。 

字符串长度满足 $1 \le n \le 1000 \$ ，保证字符串中只出现小写英文字母。

## 样例

### 样例 1

**输入：**
```
"nowcoder","new"
```

**输出：**
```
6
```

**说明：**
"nowcoder"=>"newcoder"(将''o''替换为''e'')，修改操作1次
"nowcoder"=>"new"(删除"coder")，删除操作5次

### 样例 2

**输入：**
```
"intention","execution"
```

**输出：**
```
5
```

**说明：**
一种方案为:
因为2个长度都是9，后面的4个后缀的长度都为"tion"，于是从"inten"到"execu"逐个修改即可

### 样例 3

**输入：**
```
"now","nowcoder"
```

**输出：**
```
5
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/6a1483b5be1547b1acd7940f867be0da?tpId=295&tqId=2294660&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/6a1483b5be1547b1acd7940f867be0da?tpId=295&tqId=2294660&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.656392+00:00', '2026-07-03T18:05:31.942959+00:00', 2000, 262144, '常见101'),
	(272, '打家劫舍(二)', '打家劫舍(二)', '牛客', 'Medium', 'dynamic-programming', '你是一个经验丰富的小偷，准备偷沿湖的一排房间，每个房间都存有一定的现金，为了防止被发现，你不能偷相邻的两家，即，如果偷了第一家，就不能再偷第二家，如果偷了第二家，那么就不能偷第一家和第三家。沿湖的房间组成一个闭合的圆形，即第一个房间和最后一个房间视为相邻。 
给定一个长度为n的整数数组nums，数组中的元素表示每个房间存有的现金数额，请你计算在不被发现的前提下最多的偷窃金额。 

数据范围：数组长度满足 $1 \le n \le 2\times10^5 \$，数组中每个值满足 $1 \le nums[i] \le 5000 \$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,2,3,4]
```

**输出：**
```
6
```

**说明：**
最优方案是偷第 2 4 个房间

### 样例 2

**输入：**
```
[1,3,6]
```

**输出：**
```
6
```

**说明：**
由于 1 和 3 是相邻的，因此最优方案是偷第 3 个房间', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/a5c127769dd74a63ada7bff37d9c5815?tpId=295&tqId=2285837&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/a5c127769dd74a63ada7bff37d9c5815?tpId=295&tqId=2285837&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.842750+00:00', '2026-07-03T18:04:46.228238+00:00', 2000, 262144, '常见101'),
	(270, '最长的括号子串', '最长的括号子串', '牛客', 'Medium', 'dynamic-programming', '给出一个长度为 n 的，仅包含字符 ''('' 和 '')'' 的字符串，计算最长的格式正确的括号子串的长度。 

例1: 对于字符串 "(()" 来说，最长的格式正确的子串是 "()" ，长度为 2 .

例2：对于字符串 ")()())" , 来说, 最长的格式正确的子串是 "()()" ，长度为 4 .

字符串长度：$0 \le n \le 5*10^5$

要求时间复杂度 $O(n)$ ,空间复杂度 $O(n)$.

## 样例

### 样例 1

**输入：**
```
"(()"
```

**输出：**
```
2
```

### 样例 2

**输入：**
```
"(())"
```

**输出：**
```
4
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/45fd68024a4c4e97a8d6c45fc61dc6ad?tpId=295&tqId=715&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/45fd68024a4c4e97a8d6c45fc61dc6ad?tpId=295&tqId=715&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.750879+00:00', '2026-07-03T18:05:10.959982+00:00', 2000, 262144, '常见101'),
	(275, '买卖股票的最好时机(三)', '买卖股票的最好时机(三)', '牛客', 'Medium', 'dynamic-programming', '假设你有一个数组prices，长度为n，其中prices[i]是某只股票在第i天的价格，请根据这个价格数组，返回买卖股票能获得的最大收益
1. 你最多可以对该股票有两笔交易操作，一笔交易代表着一次买入与一次卖出，但是再次购买前必须卖出之前的股票
2. 如果不能获取收益，请返回0
3. 假设买入卖出均无手续费

数据范围：$1 \le n \le 10^5$，股票的价格满足 $1 \le val\le 10^4$ 
要求: 空间复杂度 $O(n)$，时间复杂度 $O(n)$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(n)$

## 样例

### 样例 1

**输入：**
```
[8,9,3,5,1,3]
```

**输出：**
```
4
```

**说明：**
第三天(股票价格=3)买进，第四天(股票价格=5)卖出，收益为2
第五天(股票价格=1)买进，第六天(股票价格=3)卖出，收益为2
总收益为4。

### 样例 2

**输入：**
```
[9,8,4,1]
```

**输出：**
```
0
```

### 样例 3

**输入：**
```
[1,2,8,3,8]
```

**输出：**
```
12
```

**说明：**
第一笔股票交易在第一天买进，第三天卖出；第二笔股票交易在第四天买进，第五天卖出；总收益为12。
因最多只可以同时持有一只股票，所以不能在第一天进行第一笔股票交易的买进操作，又在第二天进行第二笔股票交易的买进操作（此时第一笔股票交易还没卖出），最后两笔股票交易同时在第三天卖出，也即以上操作不满足题目要求。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/4892d3ff304a4880b7a89ba01f48daf9?tpId=295&tqId=1073487&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/4892d3ff304a4880b7a89ba01f48daf9?tpId=295&tqId=1073487&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:15.000116+00:00', '2026-07-03T18:04:13.832188+00:00', 2000, 262144, '常见101'),
	(274, '买卖股票的最好时机(二)', '买卖股票的最好时机(二)', '牛客', 'Medium', 'dynamic-programming', '假设你有一个数组prices，长度为n，其中prices[i]是某只股票在第i天的价格，请根据这个价格数组，返回买卖股票能获得的最大收益 
1. 你可以多次买卖该只股票，但是再次购买前必须卖出之前的股票 
2. 如果不能获取收益，请返回0 
3. 假设买入卖出均无手续费 

数据范围： $1 \le n \le 1 \times 10^5$ ， $1 \le prices[i] \le 10^4$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$

进阶：空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[8,9,2,5,4,7,1]
```

**输出：**
```
7
```

**说明：**
在第1天(股票价格=8)买入，第2天(股票价格=9)卖出，获利9-8=1
在第3天(股票价格=2)买入，第4天(股票价格=5)卖出，获利5-2=3
在第5天(股票价格=4)买入，第6天(股票价格=7)卖出，获利7-4=3
总获利1+3+3=7，返回7

### 样例 2

**输入：**
```
[5,4,3,2,1]
```

**输出：**
```
0
```

**说明：**
由于每天股票都在跌，因此不进行任何交易最优。最大收益为0。

### 样例 3

**输入：**
```
[1,2,3,4,5]
```

**输出：**
```
4
```

**说明：**
第一天买进，最后一天卖出最优。中间的当天买进当天卖出不影响最终结果。最大收益为4。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/9e5e3c2603064829b0a0bbfca10594e9?tpId=295&tqId=1073471&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/9e5e3c2603064829b0a0bbfca10594e9?tpId=295&tqId=1073471&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.951470+00:00', '2026-07-03T18:04:24.595890+00:00', 2000, 262144, '常见101'),
	(267, '数字字符串转化成IP地址', '数字字符串转化成IP地址', '牛客', 'Medium', 'dynamic-programming', '现在有一个只包含数字的字符串，将该字符串转化成IP地址的形式，返回所有可能的情况。

例如：

给出的字符串为"25525522135",

返回["255.255.22.135", "255.255.221.35"]. (顺序没有关系)

数据范围：字符串长度 $0 \leq n \leq 12$

要求：空间复杂度 $O(n!)$,时间复杂度 $O(n!)$

注意：ip地址是由四段数字组成的数字序列，格式如 "x.x.x.x"，其中 x 的范围应当是 [0,255]。

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"25525522135"
```

**输出：**
```
["255.255.22.135","255.255.221.35"]
```

### 样例 2

**输入：**
```
"1111"
```

**输出：**
```
["1.1.1.1"]
```

### 样例 3

**输入：**
```
"000256"
```

**输出：**
```
[]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/ce73540d47374dbe85b3125f57727e1e?tpId=295&tqId=653&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/ce73540d47374dbe85b3125f57727e1e?tpId=295&tqId=653&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.612908+00:00', '2026-07-03T18:05:43.124141+00:00', 2000, 262144, '常见101'),
	(265, '连续子数组的最大和', '连续子数组的最大和', '牛客', 'Easy', 'dynamic-programming', '输入一个长度为n的整型数组array，数组中的一个或连续多个整数组成一个子数组，子数组最小长度为1。求所有子数组的和的最大值。 
数据范围: 
$1 <= n <= 2\times10^5$

$-100 <= a[i] <= 100$

要求:时间复杂度为 $O(n)$，空间复杂度为 $O(n)$ 
进阶:时间复杂度为 $O(n)$，空间复杂度为 $O(1)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[1,-2,3,10,-4,7,2,-5]
```

**输出：**
```
18
```

**说明：**
经分析可知，输入数组的子数组[3,10,-4,7,2]可以求得最大和为18

### 样例 2

**输入：**
```
[2]
```

**输出：**
```
2
```

### 样例 3

**输入：**
```
[-10]
```

**输出：**
```
-10
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/459bd355da1549fa8a49e350bf3df484?tpId=295&tqId=23259&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/459bd355da1549fa8a49e350bf3df484?tpId=295&tqId=23259&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.521322+00:00', '2026-07-03T18:06:06.542958+00:00', 2000, 262144, '常见101'),
	(284, '反转字符串', '反转字符串', '牛客', 'Medium', 'two-pointers', '写出一个程序，接受一个字符串，然后输出该字符串反转后的字符串。（字符串长度不超过1000） 

数据范围： $0 \le n \le 1000$ 
要求：空间复杂度 $O(n)$，时间复杂度 $O(n)$

## 样例

### 样例 1

**输入：**
```
"abcd"
```

**输出：**
```
"dcba"
```

### 样例 2

**输入：**
```
""
```

**输出：**
```
""
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c3a6afee325e472386a1c4eb1ef987f3?tpId=295&tqId=1024337&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c3a6afee325e472386a1c4eb1ef987f3?tpId=295&tqId=1024337&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.159781+00:00', '2026-07-03T18:37:51.468050+00:00', 2000, 262144, '常见101'),
	(273, '买卖股票的最好时机(一)', '买卖股票的最好时机(一)', '牛客', 'Easy', 'dynamic-programming', '假设你有一个数组prices，长度为n，其中prices[i]是股票在第i天的价格，请根据这个价格数组，返回买卖股票能获得的最大收益 
1.你可以买入一次股票和卖出一次股票，并非每天都可以买入或卖出一次，总共只能买入和卖出一次，且买入必须在卖出的前面的某一天 
2.如果不能获取到任何利润，请返回0 
3.假设买入卖出均无手续费

数据范围： $0 \le n \le 10^5 , 0 \le val \le 10^4$

要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[8,9,2,5,4,7,1]
```

**输出：**
```
5
```

**说明：**
在第3天(股票价格 = 2)的时候买入，在第6天(股票价格 = 7)的时候卖出，最大利润 = 7-2 = 5 ，不能选择在第2天买入，第3天卖出，这样就亏损7了；同时，你也不能在买入前卖出股票。

### 样例 2

**输入：**
```
[2,4,1]
```

**输出：**
```
2
```

### 样例 3

**输入：**
```
[3,2,1]
```

**输出：**
```
0
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/64b4262d4e6d4f6181cd45446a5821ec?tpId=295&tqId=625&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/64b4262d4e6d4f6181cd45446a5821ec?tpId=295&tqId=625&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.890051+00:00', '2026-07-03T18:04:36.068851+00:00', 2000, 262144, '常见101'),
	(271, '打家劫舍(一)', '打家劫舍(一)', '牛客', 'Medium', 'dynamic-programming', '你是一个经验丰富的小偷，准备偷沿街的一排房间，每个房间都存有一定的现金，为了防止被发现，你不能偷相邻的两家，即，如果偷了第一家，就不能再偷第二家；如果偷了第二家，那么就不能偷第一家和第三家。 
给定一个整数数组nums，数组中的元素表示每个房间存有的现金数额，请你计算在不被发现的前提下最多的偷窃金额。

数据范围：数组长度满足 $1 \le n \le 2\times 10^5\$ ，数组中每个值满足 $1 \le num[i] \le 5000 \$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,2,3,4]
```

**输出：**
```
6
```

**说明：**
最优方案是偷第 2，4 个房间

### 样例 2

**输入：**
```
[1,3,6]
```

**输出：**
```
7
```

**说明：**
最优方案是偷第 1，3个房间

### 样例 3

**输入：**
```
[2,10,5]
```

**输出：**
```
10
```

**说明：**
最优方案是偷第 2 个房间', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c5fbf7325fbd4c0ea3d0c3ea6bc6cc79?tpId=295&tqId=2285793&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c5fbf7325fbd4c0ea3d0c3ea6bc6cc79?tpId=295&tqId=2285793&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.796953+00:00', '2026-07-03T18:04:57.542330+00:00', 2000, 262144, '常见101'),
	(269, '正则表达式匹配', '正则表达式匹配', '牛客', 'Medium', 'dynamic-programming', '请实现一个函数用来匹配包括''.''和''*''的正则表达式。 
1.模式中的字符''.''表示任意一个字符 
2.模式中的字符''*''表示它前面的字符可以出现任意次（包含0次）。 
在本题中，匹配是指字符串的所有字符匹配整个模式。例如，字符串"aaa"与模式"a.a"和"ab*ac*a"匹配，但是与"aa.a"和"ab*a"均不匹配 

数据范围: 
1.str 只包含从 a-z 的小写字母。 
2.pattern 只包含从 a-z 的小写字母以及字符 . 和 *，无连续的 ''*''。 
3. $0 \le str.length \le 26 \$
4. $0 \le pattern.length \le 26 \$

## 样例

### 样例 1

**输入：**
```
"aaa","a*a"
```

**输出：**
```
true
```

**说明：**
中间的*可以出现任意次的a，所以可以出现1次a，能匹配上

### 样例 2

**输入：**
```
"aad","c*a*d"
```

**输出：**
```
true
```

**说明：**
因为这里 c 为 0 个，a被重复一次， * 表示零个或多个a。因此可以匹配字符串 "aad"。

### 样例 3

**输入：**
```
"a",".*"
```

**输出：**
```
true
```

**说明：**
".*" 表示可匹配零个或多个（''*''）任意字符（''.''）

### 样例 4

**输入：**
```
"aaab","a*a*a*c"
```

**输出：**
```
false
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/28970c15befb4ff3a264189087b99ad4?tpId=295&tqId=1375406&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/28970c15befb4ff3a264189087b99ad4?tpId=295&tqId=1375406&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.702727+00:00', '2026-07-03T18:05:22.298959+00:00', 2000, 262144, '常见101'),
	(263, '兑换零钱(一)', '兑换零钱(一)', '牛客', 'Medium', 'dynamic-programming', '给定数组arr，arr中所有的值都为正整数且不重复。每个值代表一种面值的货币，每种面值的货币可以使用任意张，再给定一个aim，代表要找的钱数，求组成aim的最少货币数。 
如果无解，请返回-1. 

数据范围：数组大小满足 $0 \le n \le 10000$ ， 数组中每个数字都满足 $0 < val \le 10000$，$0 \le aim \le 5000$ 

要求：时间复杂度 $O(n \times aim)$ ，空间复杂度 $O(aim)$。 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[5,2,3],20
```

**输出：**
```
4
```

### 样例 2

**输入：**
```
[5,2,3],0
```

**输出：**
```
0
```

### 样例 3

**输入：**
```
[3,5],2
```

**输出：**
```
-1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/3911a20b3f8743058214ceaa099eeb45?tpId=295&tqId=988994&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/3911a20b3f8743058214ceaa099eeb45?tpId=295&tqId=988994&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.423130+00:00', '2026-07-03T18:06:27.947722+00:00', 2000, 262144, '常见101'),
	(261, '矩阵的最小路径和', '矩阵的最小路径和', '牛客', 'Medium', 'dynamic-programming', '给定一个 n * m 的矩阵 a，从左上角开始每次只能向右或者向下走，最后到达右下角的位置，路径上所有的数字累加起来就是路径和，输出所有的路径中最小的路径和。 

数据范围: $1 \le n,m\le 500$，矩阵中任意值都满足 $0 \le a_{i,j} \le 100$

要求：时间复杂度 $O(nm)$ 

例如：当输入[[1,3,5,9],[8,1,3,4],[5,0,6,1],[8,8,4,0]]时，对应的返回值为12， 
所选择的最小累加和路径如下图所示： 

![题面配图](https://uploadfiles.nowcoder.com/images/20220122/423483716_1642823916509/06EB123C153852AF55ED51448BEAD1BA)

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[[1,3,5,9],[8,1,3,4],[5,0,6,1],[8,8,4,0]]
```

**输出：**
```
12
```

### 样例 2

**输入：**
```
[[1,2,3],[1,2,3]]
```

**输出：**
```
7
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/7d21b6be4c6b429bb92d219341c4f8bb?tpId=295&tqId=1009012&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/7d21b6be4c6b429bb92d219341c4f8bb?tpId=295&tqId=1009012&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.333675+00:00', '2026-07-03T18:06:52.608576+00:00', 2000, 262144, '常见101'),
	(258, '最长公共子序列(二)', '最长公共子序列(二)', '牛客', 'Medium', 'dynamic-programming', '给定两个字符串str1和str2，输出两个字符串的最长公共子序列。如果最长公共子序列为空，则返回"-1"。目前给出的数据，仅仅会存在一个最长的公共子序列 

数据范围：$0 \le |str1|,|str2| \le 2000$ 
要求：空间复杂度 $O(n^2)$ ，时间复杂度 $O(n^2)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"1A2C3D4B56","B1D23A456A"
```

**输出：**
```
"123456"
```

### 样例 2

**输入：**
```
"abc","def"
```

**输出：**
```
"-1"
```

### 样例 3

**输入：**
```
"abc","abc"
```

**输出：**
```
"abc"
```

### 样例 4

**输入：**
```
"ab",""
```

**输出：**
```
"-1"
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/6d29638c85bb4ffd80c020fe244baf11?tpId=295&tqId=991075&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/6d29638c85bb4ffd80c020fe244baf11?tpId=295&tqId=991075&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.196585+00:00', '2026-07-03T18:07:38.303280+00:00', 2000, 262144, '常见101'),
	(266, '最长回文子串', '最长回文子串', '牛客', 'Medium', 'dynamic-programming', '对于长度为n的一个字符串A（仅包含数字，大小写英文字母），请设计一个高效算法，计算其中最长回文子串的长度。 

数据范围： $1 \le n \le 1000$ 
要求：空间复杂度 $O(1)$，时间复杂度 $O(n^2)$ 
进阶: 空间复杂度 $O(n)$，时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"ababc"
```

**输出：**
```
3
```

**说明：**
最长的回文子串为"aba"与"bab"，长度都为3

### 样例 2

**输入：**
```
"abbba"
```

**输出：**
```
5
```

### 样例 3

**输入：**
```
"b"
```

**输出：**
```
1
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/b4525d1d84934cf280439aeecc36f4af?tpId=295&tqId=25269&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/b4525d1d84934cf280439aeecc36f4af?tpId=295&tqId=25269&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.567439+00:00', '2026-07-03T18:07:48.653100+00:00', 2000, 262144, '常见101'),
	(256, '跳台阶', '跳台阶', '牛客', 'Easy', 'dynamic-programming', '一只青蛙一次可以跳上1级台阶，也可以跳上2级。求该青蛙跳上一个 n 级的台阶总共有多少种跳法（先后次序不同算不同的结果）。 

数据范围：$1 \leq n \leq 40$ 
要求：时间复杂度：$O(n)$ ，空间复杂度： $O(1)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
2
```

**输出：**
```
2
```

**说明：**
青蛙要跳上两级台阶有两种跳法，分别是：先跳一级，再跳一级或者直接跳两级。因此答案为2

### 样例 2

**输入：**
```
7
```

**输出：**
```
21
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/8c82a5b80378478f9484d87d1c5f12a4?tpId=295&tqId=23261&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/8c82a5b80378478f9484d87d1c5f12a4?tpId=295&tqId=23261&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:02:14.104269+00:00', '2026-07-03T18:08:18.382807+00:00', 2000, 262144, '常见101'),
	(279, '大数加法', '大数加法', '牛客', 'Medium', 'string', '以字符串的形式读入两个数字，编写一个函数计算它们的和，以字符串形式返回。 

数据范围：$s.length,t.length \le 100000$，字符串仅由''0''~‘9’构成 
要求：时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"1","99"
```

**输出：**
```
"100"
```

**说明：**
1+99=100

### 样例 2

**输入：**
```
"114514",""
```

**输出：**
```
"114514"
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/11ae12e8c6fe48f883cad618c2e81475?tpId=295&tqId=1061819&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/11ae12e8c6fe48f883cad618c2e81475?tpId=295&tqId=1061819&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:17:34.663859+00:00', '2026-07-03T18:26:52.276085+00:00', 2000, 262144, '常见101'),
	(278, '验证IP地址', '验证IP地址', '牛客', 'Medium', 'string', '【本题对于IPv4、IPv6的描述若和真实情况有出入，以本题描述为准】

编写一个函数来验证输入的字符串是否是有效的 IPv4 或 IPv6 地址

IPv4 地址由十进制数和点来表示，每个地址包含4个十进制数，其范围为 0 - 255， 用(".")分割。比如，172.16.254.1；

同时，IPv4 地址内的数不会以 0 开头。比如，地址 172.16.254.01 是不合法的。

IPv6 地址由8组16进制的数字来表示，每组表示 16 比特。这些组数字通过 (":")分割。比如, 2001:0db8:85a3:0000:0000:8a2e:0370:7334 是一个有效的地址。而且，我们可以加入一些以 0 开头的数字，字母可以使用大写，也可以是小写。所以， 2001:db8:85a3:0:0:8A2E:0370:7334 也是一个有效的 IPv6 address地址 (即，忽略 0 开头，忽略大小写)。

然而，我们不能因为某个组的值为 0，而使用一个空的组，以至于出现 (::) 的情况。 比如， 2001:0db8:85a3::8A2E:0370:7334 是无效的 IPv6 地址。

同时，在 IPv6 地址中，多余的 0 也是不被允许的。比如， 02001:0db8:85a3:0000:0000:8a2e:0370:7334 是无效的。

说明: 你可以认为给定的字符串里没有空格或者其他特殊字符。

数据范围：字符串长度满足 $5 \leq n \leq 50$

进阶：空间复杂度 $O(n)$，时间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
"172.16.254.1"
```

**输出：**
```
"IPv4"
```

**说明：**
这是一个有效的 IPv4 地址, 所以返回 "IPv4"

### 样例 2

**输入：**
```
"2001:0db8:85a3:0:0:8A2E:0370:7334"
```

**输出：**
```
"IPv6"
```

**说明：**
这是一个有效的 IPv6 地址, 所以返回 "IPv6"

### 样例 3

**输入：**
```
"256.256.256.256"
```

**输出：**
```
"Neither"
```

**说明：**
这个地址既不是 IPv4 也不是 IPv6 地址', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/55fb3c68d08d46119f76ae2df7566880?tpId=295&tqId=1024725&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/55fb3c68d08d46119f76ae2df7566880?tpId=295&tqId=1024725&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:17:34.606058+00:00', '2026-07-03T18:27:09.589272+00:00', 2000, 262144, '常见101'),
	(277, '最长公共前缀', '最长公共前缀', '牛客', 'Easy', 'string', '给你一个大小为 n 的字符串数组 strs ，其中包含n个字符串 , 编写一个函数来查找字符串数组中的最长公共前缀，返回这个公共前缀。

数据范围： $0 \le n \le 5000$， $0 \le len(strs_i) \le 5000$

进阶：空间复杂度 $O(1)$，时间复杂度 $O(n*len)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
["abca","abc","abca","abc","abcc"]
```

**输出：**
```
"abc"
```

### 样例 2

**输入：**
```
["abc"]
```

**输出：**
```
"abc"
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/28eb3175488f4434a4a6207f6f484f47?tpId=295&tqId=732&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/28eb3175488f4434a4a6207f6f484f47?tpId=295&tqId=732&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:17:34.554411+00:00', '2026-07-03T18:27:27.694189+00:00', 2000, 262144, '常见101'),
	(276, '字符串变形', '字符串变形', '牛客', 'Easy', 'string', '对于一个长度为 n 字符串，我们需要对它做一些变形。 

首先这个字符串中包含着一些空格，就像"Hello World"一样，然后我们要做的是把这个字符串中由空格隔开的单词反序，同时反转每个字符的大小写。 

比如"Hello World"变形后就变成了"wORLD hELLO"。 

数据范围: $1\le n \le 10^6$ , 字符串中包括大写英文字母、小写英文字母、空格。

进阶：空间复杂度 $O(n)$ ， 时间复杂度 $O(n)$ 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
"This is a sample",16
```

**输出：**
```
"SAMPLE A IS tHIS"
```

### 样例 2

**输入：**
```
"nowcoder",8
```

**输出：**
```
"NOWCODER"
```

### 样例 3

**输入：**
```
"iOS",3
```

**输出：**
```
"Ios"
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c3120c1c1bc44ad986259c0cf0f0b80e?tpId=295&tqId=44664&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c3120c1c1bc44ad986259c0cf0f0b80e?tpId=295&tqId=44664&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:17:34.490707+00:00', '2026-07-03T18:27:42.249964+00:00', 2000, 262144, '常见101'),
	(283, '最小覆盖子串', '最小覆盖子串', '牛客', 'Medium', 'two-pointers', '给出两个字符串 s 和 t，要求在 s 中找出最短的包含 t 中所有字符的连续子串。 

数据范围：$0 \le |S|,|T| \le10000$，保证s和t字符串中仅包含大小写英文字母 
要求：进阶：空间复杂度 $O(n)$ ， 时间复杂度 $O(n)$ 
例如： $S ="XDOYEZODEYXNZ"$
$T ="XYZ"$
找出的最短子串为$"YXNZ"$. 
注意：
如果 s 中没有包含 t 中所有字符的子串，返回空字符串 “”；
满足条件的子串可能有很多，但是题目保证满足条件的最短的子串唯一。

## 样例

### 样例 1

**输入：**
```
"XDOYEZODEYXNZ","XYZ"
```

**输出：**
```
"YXNZ"
```

### 样例 2

**输入：**
```
"abcAbA","AA"
```

**输出：**
```
"AbA"
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/c466d480d20c4c7c9d322d12ca7955ac?tpId=295&tqId=670&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/c466d480d20c4c7c9d322d12ca7955ac?tpId=295&tqId=670&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.108158+00:00', '2026-07-03T18:38:08.215089+00:00', 2000, 262144, '常见101'),
	(281, '判断是否为回文字符串', '判断是否为回文字符串', '牛客', 'Medium', 'two-pointers', '给定一个长度为 n 的字符串，请编写一个函数判断该字符串是否回文。如果是回文请返回true，否则返回false。 

字符串回文指该字符串正序与其逆序逐字符一致。 

数据范围：$0 < n \le 1000000$

要求：空间复杂度 $O(1)$，时间复杂度 $O(n)$

## 样例

### 样例 1

**输入：**
```
"absba"
```

**输出：**
```
true
```

### 样例 2

**输入：**
```
"ranko"
```

**输出：**
```
false
```

### 样例 3

**输入：**
```
"yamatomaya"
```

**输出：**
```
false
```

### 样例 4

**输入：**
```
"a"
```

**输出：**
```
true
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/e297fdd8e9f543059b0b5f05f3a7f3b2?tpId=295&tqId=1089616&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/e297fdd8e9f543059b0b5f05f3a7f3b2?tpId=295&tqId=1089616&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.008369+00:00', '2026-07-03T18:38:34.252779+00:00', 2000, 262144, '常见101'),
	(294, '设计LFU缓存结构', '设计LFU缓存结构', '牛客', 'Medium', 'simulation', '一个缓存结构需要实现如下功能。 

- set(key, value)：将记录(key, value)插入该结构 
- get(key)：返回key对应的value值 
但是缓存结构中最多放K条记录，如果新的第K+1条记录要加入，就需要根据策略删掉一条记录，然后才能把新记录加入。这个策略为：在缓存结构的K条记录中，哪一个key从进入缓存结构的时刻开始，被调用set或者get的次数最少，就删掉这个key的记录； 
如果调用次数最少的key有多个，上次调用发生最早的key被删除 
这就是LFU缓存替换算法。实现这个结构，K作为参数给出

数据范围：$0 < k \le 10^5$，$|val| \le 2 \times 10^9$ 
要求：get和set的时间复杂度都是 $O(logn)$，空间复杂度是 $O(n)$ 

若opt=1，接下来两个整数x, y，表示set(x, y)
若opt=2，接下来一个整数x，表示get(x)，若x未出现过或已被移除，则返回-1

对于每个操作2，返回一个答案

## 样例

### 样例 1

**输入：**
```
[[1,1,1],[1,2,2],[1,3,2],[1,2,4],[1,3,5],[2,2],[1,4,4],[2,1]],3
```

**输出：**
```
[4,-1]
```

**说明：**
在执行"1 4 4"后，"1 1 1"被删除。因此第二次询问的答案为-1', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/93aacb4a887b46d897b00823f30bfea1?tpId=295&tqId=1006014&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/93aacb4a887b46d897b00823f30bfea1?tpId=295&tqId=1006014&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:42:49.706411+00:00', '2026-07-03T18:43:02.362459+00:00', 2000, 262144, '常见101'),
	(307, '方案数量', '方案数量', '阿里', 'Medium', 'simulation', '有这样的一个方格游戏：这个游戏是这样的： 
1.有$n*m$个方格，方格内每一个位置都有一个数，代表到达这个点后拥有的能量。 
2.初始的时候在左上角，并将左上角的值作为初始能量，终点为右下角的点。 
3.每一步只能往下或者往右走，且走一步需要消耗$\text 1$点能量。不能在原地停留，即不会获得中间节点的能量并且能量不累计。 
4.当你选择了一条可行的路径（这条路径消耗的能量不超过现有能量），你可以走到终点。 
例如：
![题面配图](https://uploadfiles.nowcoder.com/images/20200216/323896_1581815049936_6E783F810A505810A34F4EE25ED2FD40)

最开始在$(1,1)$点，拥有的是$4$点能量，蓝色的方格代表从起点出发$\text 4$步以内所能走到的点，假设我们第一次走到$\text (3,2)$,则到达后能量变为$1$点，那么接下来可以达到的点为$\text (3, 3)$和$\text (4, 2)$。 
现在想问你有多少条不同的路径（两条路径如果按顺序依次到达的点有一个不同，则认为是不同的路径方式）可以从左上角的点走到右下角的点，由于答案很大，请答案对$10000$取余。

## 输入格式

输入第一行有一个整数$T$，代表接下来有$T$组测试数据。
对于每一组测试数据第一行输入两个整数$n$和$m$，
代表方格的大小。接下来$n$行，每一行输入$m$个数，代表这个方格内的能量。
$1\le T\le 100$
$1\le\ n,m\le100$
$0\le\ A[i][j]\le20$
保证每一个文件内$\mathit n$和$\mathit m$的总和不超过$10^3$

## 输出格式

对于每组数据输出一行，代表可以走到的方案数量。

## 样例

### 样例 1

**输入：**
```
2
3 3
2 1 1
1 1 1
1 1 1
6 6
4 5 6 6 4 3
2 2 3 1 7 2
1 1 4 6 2 7
5 8 4 3 9 5
7 6 6 2 1 5
3 1 1 3 7 2
```

**输出：**
```
10
3948
```

**说明：**
对于样例一的十条路径如下：
$((1,1)->(1,2)->(1,3)->(2,3)->(3,3))$
$((1,1)->(1,2)->(1,3)->(2,3)->(3,3))$
$((1,1)->(1,2)->(2,2)->(2,3)->(3,3))$
$((1,1)->(1,2)->(2,2)->(3,2)->(3,3))$
$((1,1)->(2,2)->(2,3)->(3,3))$
$((1,1)->(2,2)->(3,2)->(3,3))$
$((1,1)->(2,1)->(3,1)->(3,2)->(3,3))$
$((1,1)->(2,1)->(2,2)->(3,2)->(3,3))$
$((1,1)->(2,1)->(2,2)->(2,3)->(3,3))$
$((1,1)->(3,1)->(3,2)->(3,3)$', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.439343+00:00', '2026-07-04T03:09:48.693978+00:00', 2000, 262144, '技术'),
	(287, '接雨水问题', '接雨水问题', '牛客', 'Medium', 'two-pointers', '给定一个整形数组arr，已知其中所有的值都是非负的，将这个数组看作一个柱子高度图，计算按此排列的柱子，下雨之后能接多少雨水。(数组以外的区域高度视为0) 

![题面配图](https://uploadfiles.nowcoder.com/images/20210416/999991351_1618541247169/26A2E295DEE51749C45B5E8DD671E879)

数据范围：数组长度 $0 \le n \le 2\times10^5$，数组中每个值满足 $0 < val \le 10^9$ ，保证返回结果满足 $0 \le val \le 10^9 \$ 
要求：时间复杂度 $O(n)$

## 样例

### 样例 1

**输入：**
```
[3,1,2,5,2,4]
```

**输出：**
```
5
```

**说明：**
数组 [3,1,2,5,2,4] 表示柱子高度图，在这种情况下，可以接 5个单位的雨水，蓝色的为雨水 ，如题面图。

### 样例 2

**输入：**
```
[4,5,1,3,2]
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/31c1aed01b394f0b8b7734de0324e00f?tpId=295&tqId=1002045&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/31c1aed01b394f0b8b7734de0324e00f?tpId=295&tqId=1002045&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.306239+00:00', '2026-07-03T18:37:10.280098+00:00', 2000, 262144, '常见101'),
	(286, '盛水最多的容器', '盛水最多的容器', '牛客', 'Medium', 'two-pointers', '给定一个数组height，长度为n，每个数代表坐标轴中的一个点的高度，height[i]是在第i点的高度，请问，从中选2个高度与x轴组成的容器最多能容纳多少水 
1.你不能倾斜容器 
2.当n小于2时，视为不能形成容器，请返回0 
3.数据保证能容纳最多的水不会超过整形范围，即不会超过231-1 

数据范围: 
$0<=height.length<=10^5$

$0<=height[i]<=10^4$ 

如输入的height为[1,7,3,2,4,5,8,2,7]，那么如下图: 

![题面配图](https://uploadfiles.nowcoder.com/images/20211105/301499_1636104759021/B9F3EB6BBC1EE9A63532E7EB494A11A7)

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[1,7,3,2,4,5,8,2,7]
```

**输出：**
```
49
```

### 样例 2

**输入：**
```
[2,2]
```

**输出：**
```
2
```

### 样例 3

**输入：**
```
[5,4,3,2,1,5]
```

**输出：**
```
25
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/3d8d6a8e516e4633a2244d2934e5aa47?tpId=295&tqId=2284579&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/3d8d6a8e516e4633a2244d2934e5aa47?tpId=295&tqId=2284579&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.257490+00:00', '2026-07-03T18:37:20.764005+00:00', 2000, 262144, '常见101'),
	(285, '最长无重复子数组', '最长无重复子数组', '牛客', 'Medium', 'two-pointers', '给定一个长度为n的数组arr，返回arr的最长无重复元素子数组的长度，无重复指的是所有数字都不相同。 
子数组是连续的，比如[1,3,5,7,9]的子数组有[1,3]，[3,5,7]等等，但是[1,3,7]不是子数组 

数据范围：$0\le arr.length \le 10^5$，$0 < arr[i] \le 10^5$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[2,3,4,5]
```

**输出：**
```
4
```

**说明：**
[2,3,4,5]是最长子数组

### 样例 2

**输入：**
```
[2,2,3,4,3]
```

**输出：**
```
3
```

**说明：**
[2,3,4]是最长子数组

### 样例 3

**输入：**
```
[9]
```

**输出：**
```
1
```

### 样例 4

**输入：**
```
[1,2,3,1,2,3,2,2]
```

**输出：**
```
3
```

**说明：**
最长子数组为[1,2,3]

### 样例 5

**输入：**
```
[2,2,3,4,8,99,3]
```

**输出：**
```
5
```

**说明：**
最长子数组为[2,3,4,8,99]', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/b56799ebfd684fb394bd315e89324fb4?tpId=295&tqId=1008889&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/b56799ebfd684fb394bd315e89324fb4?tpId=295&tqId=1008889&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.209080+00:00', '2026-07-03T18:37:34.773515+00:00', 2000, 262144, '常见101'),
	(293, '设计LRU缓存结构', '设计LRU缓存结构', '牛客', 'Medium', 'simulation', '设计LRU(最近最少使用)缓存结构，该结构在构造时确定大小，假设大小为 capacity ，操作次数是 n ，并有如下功能:
1. Solution(int capacity) 以正整数作为容量 capacity 初始化 LRU 缓存
2. get(key)：如果关键字 key 存在于缓存中，则返回key对应的value值，否则返回 -1 。
3. set(key, value)：将记录(key, value)插入该结构，如果关键字 key 已经存在，则变更其数据值 value，如果不存在，则向缓存中插入该组 key-value ，如果key-value的数量超过capacity，弹出最久未使用的key-value

提示:
1.某个key的set或get操作一旦发生，则认为这个key的记录成了最常使用的，然后都会刷新缓存。
2.当缓存的大小超过capacity时，移除最不经常使用的记录。
3.返回的value都以字符串形式表达，如果是set，则会输出"null"来表示(不需要用户返回，系统会自动输出)，方便观察
4.函数set和get必须以O(1)的方式运行
5.为了方便区分缓存里key与value，下面说明的缓存里key用""号包裹 
数据范围: 
$1\leq capacity<=10^5$
$0\leq key,val \leq 2\times 10^9 \$
$1\leq n\leq 10^5$

## 样例

### 样例 1

**输入：**
```
["set","set","get","set","get","set","get","get","get"],[[1,1],[2,2],[1],[3,3],[2],[4,4],[1],[3],[4]],2
```

**输出：**
```
["null","null","1","null","-1","null","-1","3","4"]
```

**说明：**
我们将缓存看成一个队列，最后一个参数为2代表capacity，所以
Solution s = new Solution(2);
s.set(1,1); //将(1,1)插入缓存，缓存是{"1"=1}，set操作返回"null"
s.set(2,2); //将(2,2)插入缓存，缓存是{"2"=2，"1"=1}，set操作返回"null"
output=s.get(1);// 因为get(1)操作，缓存更新，缓存是{"1"=1，"2"=2}，get操作返回"1"
s.set(3,3); //将(3,3)插入缓存，缓存容量是2，故去掉某尾的key-value，缓存是{"3"=3，"1"=1}，set操作返回"null" 
output=s.get(2);// 因为get(2)操作，不存在对应的key，故get操作返回"-1"
s.set(4,4); //将(4,4)插入缓存，缓存容量是2，故去掉某尾的key-value，缓存是{"4"=4，"3"=3}，set操作返回"null" 
output=s.get(1);// 因为get(1)操作，不存在对应的key，故get操作返回"-1"
output=s.get(3);//因为get(3)操作，缓存更新，缓存是{"3"=3，"4"=4}，get操作返回"3"
output=s.get(4);//因为get(4)操作，缓存更新，缓存是{"4"=4，"3"=3}，get操作返回"4"', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/5dfded165916435d9defb053c63f1e84?tpId=295&tqId=2427094&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/5dfded165916435d9defb053c63f1e84?tpId=295&tqId=2427094&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:42:49.662072+00:00', '2026-07-03T18:43:19.213969+00:00', 2000, 262144, '常见101'),
	(282, '合并区间', '合并区间', '牛客', 'Medium', 'two-pointers', '给出一组区间，请合并所有重叠的区间。

请保证合并后的区间按区间起点升序排列。

//"区间"定义
class Interval {
int start; //起点
int end; //终点
}

数据范围：区间组数 $0 \le n \le 2 \times 10^5$，区间内 的值都满足 $0 \le val \le 2 \times 10^5$

要求：空间复杂度 $O(n)$，时间复杂度 $O(nlogn)$

进阶：空间复杂度 $O(val)$，时间复杂度$O(val)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[[10,30],[20,60],[80,100],[150,180]]
```

**输出：**
```
[[10,60],[80,100],[150,180]]
```

### 样例 2

**输入：**
```
[[0,10],[10,20]]
```

**输出：**
```
[[0,20]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/69f4e5b7ad284a478777cb2a17fb5e6a?tpId=295&tqId=691&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/69f4e5b7ad284a478777cb2a17fb5e6a?tpId=295&tqId=691&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:52.059245+00:00', '2026-07-03T18:38:21.054757+00:00', 2000, 262144, '常见101'),
	(280, '合并两个有序的数组', '合并两个有序的数组', '牛客', 'Easy', 'two-pointers', '给出一个有序的整数数组 A 和有序的整数数组 B ，请将数组 B 合并到数组 A 中，变成一个有序的升序数组 

数据范围： $0 \le n,m \le 100$，$|A_i| <=100$， $|B_i| <= 100$ 

注意：
1.保证 A 数组有足够的空间存放 B 数组的元素， A 和 B 中初始的元素数目分别为 m 和 n，A的数组空间大小为 m+n 
2.不要返回合并的数组，将数组 B 的数据合并到 A 里面就好了，且后台会自动将合并后的数组 A 的内容打印出来，所以也不需要自己打印 
3. A 数组在[0,m-1]的范围也是有序的 

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[4,5,6],[1,2,3]
```

**输出：**
```
[1,2,3,4,5,6]
```

**说明：**
A数组为[4,5,6]，B数组为[1,2,3]，后台程序会预先将A扩容为[4,5,6,0,0,0]，B还是为[1,2,3]，m=3，n=3，传入到函数merge里面，然后请同学完成merge函数，将B的数据合并A里面，最后后台程序输出A数组

### 样例 2

**输入：**
```
[1,2,3],[2,5,6]
```

**输出：**
```
[1,2,2,3,5,6]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/89865d4375634fc484f3a24b7fe65665?tpId=295&tqId=658&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/89865d4375634fc484f3a24b7fe65665?tpId=295&tqId=658&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:36:51.945165+00:00', '2026-07-03T18:38:49.337774+00:00', 2000, 262144, '常见101'),
	(288, '分糖果问题', '分糖果问题', '牛客', 'Medium', 'greedy', '一群孩子做游戏，现在请你根据游戏得分来发糖果，要求如下： 

1. 每个孩子不管得分多少，起码分到一个糖果。

2. 任意两个相邻的孩子之间，得分较多的孩子必须拿多一些糖果。(若相同则无此限制)

给定一个数组 $arr$ 代表得分数组，请返回最少需要多少糖果。 

要求: 时间复杂度为 $O(n)$ 空间复杂度为 $O(n)$ 

数据范围： $1 \le n \le 100000$ ，$1 \le a_i \le 1000$

## 样例

### 样例 1

**输入：**
```
[1,1,2]
```

**输出：**
```
4
```

**说明：**
最优分配方案为1,1,2

### 样例 2

**输入：**
```
[1,1,1]
```

**输出：**
```
3
```

**说明：**
最优分配方案是1,1,1', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/76039109dd0b47e994c08d8319faa352?tpId=295&tqId=1008104&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/76039109dd0b47e994c08d8319faa352?tpId=295&tqId=1008104&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:40:47.642678+00:00', '2026-07-03T18:41:16.972069+00:00', 2000, 262144, '常见101'),
	(289, '主持人调度（二）', '主持人调度（二）', '牛客', 'Medium', 'greedy', '有 n 个活动即将举办，每个活动都有开始时间与活动的结束时间，第 i 个活动的开始时间是 starti ,第 i 个活动的结束时间是 endi ,举办某个活动就需要为该活动准备一个活动主持人。

一位活动主持人在同一时间只能参与一个活动。并且活动主持人需要全程参与活动，换句话说，一个主持人参与了第 i 个活动，那么该主持人在 (starti,endi) 这个时间段不能参与其他任何活动。求为了成功举办这 n 个活动，最少需要多少名主持人。

数据范围: $1 \le n \le 10^5$ ， $-2^{32} \le start_i\le end_i \le 2^{31}-1$

复杂度要求：时间复杂度 $O(n \log n)$ ，空间复杂度 $O(n)$

难度提示：中等

## 样例

### 样例 1

**输入：**
```
2,[[1,2],[2,3]]
```

**输出：**
```
1
```

**说明：**
只需要一个主持人就能成功举办这两个活动

### 样例 2

**输入：**
```
2,[[1,3],[2,4]]
```

**输出：**
```
2
```

**说明：**
需要两个主持人才能成功举办这两个活动', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/4edf6e6d01554870a12f218c94e8a299?tpId=295&tqId=1267319&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/4edf6e6d01554870a12f218c94e8a299?tpId=295&tqId=1267319&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:40:47.696805+00:00', '2026-07-03T18:41:03.632137+00:00', 2000, 262144, '常见101'),
	(292, '顺时针旋转矩阵', '顺时针旋转矩阵', '牛客', 'Medium', 'simulation', '有一个NxN整数矩阵，请编写一个算法，将矩阵顺时针旋转90度。 
给定一个NxN的矩阵，和矩阵的阶数N,请返回旋转后的NxN矩阵。 

数据范围：$0 < n < 300$，矩阵中的值满足 $0 \le val \le 1000$ 

要求：空间复杂度 $O(N^2)$，时间复杂度 $O(N^2)$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(N^2)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
[[1,2,3],[4,5,6],[7,8,9]],3
```

**输出：**
```
[[7,4,1],[8,5,2],[9,6,3]]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/2e95333fbdd4451395066957e24909cc?tpId=295&tqId=25283&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/2e95333fbdd4451395066957e24909cc?tpId=295&tqId=25283&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:42:49.615678+00:00', '2026-07-03T18:43:32.734488+00:00', 2000, 262144, '常见101'),
	(291, '螺旋矩阵', '螺旋矩阵', '牛客', 'Easy', 'simulation', '给定一个m x n大小的矩阵（m行，n列），按螺旋的顺序返回矩阵中的所有元素。

数据范围：$0 \le n,m \le 10$，矩阵中任意元素都满足 $|val| \le 100$ 
要求：空间复杂度 $O(nm)$ ，时间复杂度 $O(nm)$

难度提示：简单

## 样例

### 样例 1

**输入：**
```
[[1,2,3],[4,5,6],[7,8,9]]
```

**输出：**
```
[1,2,3,6,9,8,7,4,5]
```

### 样例 2

**输入：**
```
[]
```

**输出：**
```
[]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/7edf70f2d29c4b599693dc3aaeea1d31?tpId=295&tqId=693&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/7edf70f2d29c4b599693dc3aaeea1d31?tpId=295&tqId=693&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:42:49.568296+00:00', '2026-07-03T18:43:46.250846+00:00', 2000, 262144, '常见101'),
	(290, '旋转数组', '旋转数组', '牛客', 'Medium', 'simulation', '一个数组A中存有 n 个整数，在不允许使用另外数组的前提下，将每个整数循环向右移 M（ M >=0）个位置，即将A中的数据由（A0 A1 ……AN-1 ）变换为（AN-M …… AN-1 A0 A1 ……AN-M-1 ）（最后 M 个数循环移至最前面的 M 个位置）。如果需要考虑程序移动数据的次数尽量少，要如何设计移动的方法？ 

数据范围：$0 < n \le 100$，$0 \le m \le 1000$ 
进阶：空间复杂度 $O(1)$，时间复杂度 $O(n)$ 

难度提示：中等

## 样例

### 样例 1

**输入：**
```
6,2,[1,2,3,4,5,6]
```

**输出：**
```
[5,6,1,2,3,4]
```

### 样例 2

**输入：**
```
4,0,[1,2,3,4]
```

**输出：**
```
[1,2,3,4]
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', NULL, 'https://www.nowcoder.com/practice/e19927a8fd5d477794dac67096862042?tpId=295&tqId=1024689&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', 'https://www.nowcoder.com/practice/e19927a8fd5d477794dac67096862042?tpId=295&tqId=1024689&sourceUrl=%2Fexam%2Foj%3FquestionJobId%3D10%26subTabName%3Donline_coding_page', '未开始', '2026-07-03T18:42:49.515399+00:00', '2026-07-03T18:43:57.351220+00:00', 2000, 262144, '常见101');
INSERT INTO public.problems VALUES
	(298, '安排超市', '安排超市', '腾讯', 'Medium', 'string', '给定一个n*n的地图。地图是上下左右四联通的，不能斜向行走：
*代表障碍，不可通行。
.代表路，可以通行。
#代表房子。房子也是可以通行的。

小红现在需要在一些地方安排一些超市（不能安排在障碍物上，可以安排在路上或者房子上。超市也是可以通行的）。
小红希望每个房子至少可以到达一个超市。同时由于成本原因，小红希望超市的数量尽可能少。
在超市数量最少的情况下，小红希望每个房子到达最近的超市的距离之和尽可能小。
她想知道超市最少的数量，以及最小的距离之和。你能帮帮她吗？

## 输入格式

第一行一个正整数n，代表地图的大小。( 1<=n<=50 )
接下来的n行，每行一个长度为n的字符串，表示整个地图。保证输入合法。

## 输出格式

输出两个整数，用空格隔开。分别代表超市的最小数量、最小的距离之和。

## 样例

### 样例 1

**输入：**
```
3
#.#
.**
*.#
```

**输出：**
```
2 2
```

**说明：**
下标从1开始，第一个超市安排的位置是(1,2)，第二个超市安排的位置是(3,3)。三个房子到超市的距离分别为1,1,0。

### 样例 2

**输入：**
```
3
#*#
.**
*.#
```

**输出：**
```
3 0
```

**说明：**
分别在三个房子上建3个超市即可。

### 样例 3

**输入：**
```
2
.*
*.
```

**输出：**
```
0 0
```

**说明：**
没有房子，所以不用造超市', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T02:26:03.050106+00:00', '2026-07-04T02:27:39.904115+00:00', 2000, 262144, '技术'),
	(299, '滚动加载', '滚动加载', '腾讯', 'Medium', 'graphs', '页面上存在class=container的节点A
请阅读给定javascript代码，为节点A实现滚动加载功能，具体效果参考以下图片
请在TODO处补全说明的代码
请不要手动修改html和css
请不要修改javascript代码中已经给定的参数
不要使用第三方插件

![题面配图](https://static.nowcoder.com/fe/file/oss/1611802065745WOSKK.gif)', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T02:26:03.094716+00:00', '2026-07-04T02:27:22.643680+00:00', 2000, 262144, '技术'),
	(296, '抽奖-', '抽奖', '腾讯', 'Medium', 'simulation', '小A在玩一个网络游戏。这个游戏有个抽装备环节。装备池总共有n+m件装备，分别为n件普通装备和m件ssr装备。抽一次装备的费用按你抽中的装备决定。 
抽中每一件装备的概率都为1/(n+m)。如果你抽中了ssr装备。这次的抽装备费用为2金币，否则这次的费用为1金币。如果你抽中了ssr装备，得到奖励，并且装备不会放回。如果你抽中了普通装备。得到奖励，但是这件装备会放回装备池。现在小A希望抽中所有的ssr装备，请你计算一下：需要花费金币的期望值。

## 输入格式

输入一行：n,m(1<=n,m<=106)

## 输出格式

抽中所有的ssr装备，需要花费金币的期望值。输出保留2位有效小数。

## 样例

### 样例 1

**输入：**
```
2 1
```

**输出：**
```
4.00
```

### 样例 2

**输入：**
```
2 2
```

**输出：**
```
7.00
```

### 样例 3

**输入：**
```
5 6
```

**输出：**
```
24.25
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T02:26:02.959189+00:00', '2026-07-04T02:28:02.983395+00:00', 2000, 262144, '技术'),
	(297, '有效序列的数量', '有效序列的数量', '腾讯', 'Medium', 'simulation', '我们定义一个有效序列为：该序列两端的数一个为最小值，另一个为次小值。（即序列两端以外的数一定大于等于最左边的数且大于等于最右边的数）

现在给你一个序列 a ，想让你找到它的连续子序列中有多少个有效序列(比如 ，1 2 ，2 3，1 2 3 是序列 1 2 3 的连续子序列，但是 1 3 不是) 

注：长度为 2 的子序列，一定为有效序列，长度为 1 的子序列，一定不是有效序列

## 输入格式

第一行输入一个整数 n 代表这个序列的长度
接下来输入 n 个整数，a[i] 代表系列中第 i 个元素

对于 20% 的数据, 1 ≤ n ≤ 100
对于 70% 的数据, 1 ≤ n ≤ 3,000
对于 100% 的数据, 1 ≤ n ≤ 100,000

对于 100% 的数据, 1 ≤ a[i] ≤ 1,000,000,000

## 输出格式

输出一个正整数表示有效序列的数量。

## 样例

### 样例 1

**输入：**
```
4
1 3 1 2
```

**输出：**
```
4
```

**说明：**
一共有 4 组有效序列，分别为：
子序列[1,3] 因为长度为 2，一定为有效序列
子序列[1,3,1] 因为第2个数 “3” 大于第 1 个数和第 3 个数
子序列[3,1] 因为长度为 2，一定为有效序列
子序列[1,2] 因为长度为 2，一定为有效序列

### 样例 2

**输入：**
```
4
1 1 2 1
```

**输出：**
```
5
```

**说明：**
一共有6个长度不小于2的连续子序列，除了[1,1,2]以外，其他5个都是有效子序列

### 样例 3

**输入：**
```
7
1 4 2 5 7 1 3
```

**输出：**
```
10
```

**说明：**
一共有10组，分别为：
[1,4], [1,4,2], [1,4,2,5,7,1], [4,2], [2,5], [2,5,7,1], [5,7], [5,7,1], [7,1], [1,3]', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T02:26:03.005208+00:00', '2026-07-04T02:27:52.477449+00:00', 2000, 262144, '技术'),
	(295, '01串的价值', '01串的价值', '腾讯', 'Medium', 'string', '给出一个只包含 0 和 1 的 01 串 s ，下标从 1 开始，设第 i 位的价值为 vali ，则价值定义如下： 

1. i=1时:val1 = 1 
2. i>1时： 
2.1 若 si ≠ si-1 , vali = 1 
2.2 若 si = si-1 , vali = vali-1 + 1

字符串的价值等于 val1 + val2 + val3 + ... + valn

你可以删除 s 的任意个字符，问这个串的最大价值是多少。

## 输入格式

第一行一个正整数 n ，代表串长度。
接下来一行一个 01 串 s 。
1 ≤ n ≤ 5,000

## 输出格式

输出一个整数代表答案

## 样例

### 样例 1

**输入：**
```
6
010101
```

**输出：**
```
7
```

**说明：**
删除后的串为0001或0111时有最大价值

### 样例 2

**输入：**
```
20
11111000111011101100
```

**输出：**
```
94
```

### 样例 3

**输入：**
```
4
1100
```

**输出：**
```
6
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705331/detail?pid=38431372&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D138&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T02:26:02.907993+00:00', '2026-07-04T02:28:16.230991+00:00', 2000, 262144, '技术'),
	(300, '子集-', '子集', '阿里', 'Medium', 'simulation', '小强现在有$n$个物品,每个物品有两种属性$x_i$和$y_i$.他想要从中挑出尽可能多的物品满足以下条件:对于任意两个物品$i$和$j$,满足$x_i < x_j且y_i < y_j$或者$x_i > x_j 且 y_i > y_j$.问最多能挑出多少物品. 

进阶：时间复杂度$O(nlogn)\$，空间复杂度$O(n)\$

## 输入格式

第一行输入一个正整数$T$.表示有$T$组数据.
对于每组数据,第一行输入一个正整数$n$.表示物品个数.
接下来两行,每行有$n$个整数.
第一行表示$n$个节点的$x$属性.
第二行表示$n$个节点的$y$属性.
$1\leq T \leq 10$
$2\leq n \leq 100000$
$0 \leq x,y \leq 1000000000$

## 输出格式

输出$T$行,每一行对应每组数据的输出.

## 样例

### 样例 1

**输入：**
```
2
3
1 3 2
0 2 3
4
1 5 4 2 
10 32 19 21
```

**输出：**
```
2
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.083433+00:00', '2026-07-04T03:11:20.241147+00:00', 2000, 262144, '技术'),
	(305, '树上最短链', '树上最短链', '阿里', 'Medium', 'tree', '在一个地区有 $\mathit n$ 个城市以及 $\mathit n-1$ 条无向边，每条边的时间边权都是 $\text 1$，并且这些城市是联通的，即这个地区形成了一个树状结构。每个城市有一个等级。
现在小强想从一个城市走到另一个不同的城市，并且每条边经过至多一次，同时他还有一个要求，起点和终点城市可以任意选择，但是等级必须是相同的。
但是小强不喜欢走特别远的道路，所以他想知道时间花费最小是多少。 

进阶：时间复杂度$O(n^2logn)\$，空间复杂度$O(n)\$

## 输入格式

第一行一个正整数 $\mathit n$，含义如题面所述。
第二行 $\mathit n$ 个正整数 $A_{i}$，代表每个城市的等级。
接下来 $\mathit n-1$ 行每行两个正整数 $\mathit u,v$，代表一条无向边。
保证给出的图是一棵树。
$1 \leq n \leq 5000$ 。
$1 \leq u,v \leq n$ 。
$1 \leq A_{i} \leq 10^{9}$。

## 输出格式

仅一行一个整数代表答案，如果无法满足要求，输出 $\mathit -1$ 。

## 样例

### 样例 1

**输入：**
```
3
1 2 1
1 2
2 3
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.338778+00:00', '2026-07-04T03:10:14.623789+00:00', 2000, 262144, '技术'),
	(303, '对称飞行器', '对称飞行器', '阿里', 'Medium', 'string', '小强在玩一个走迷宫的游戏，他操控的人物现在位于迷宫的起点，他的目标是尽快的到达终点。
每一次他可以选择花费一个时间单位向上或向下或向左或向右走一格，或是使用自己的对称飞行器花费一个时间单位瞬移到关于当前自己点中心对称的格子，且每一次移动的目的地不能存在障碍物。
具体来说，设当前迷宫有 $\mathit n$ 行 $\mathit m$ 列，如果当前小强操控的人物位于点 $\mathit A(x,y)$，那么关于点 $\mathit A$ 中心对称的格子 $\mathit B(x'',y'')$ 满足 $\mathit x+x''=n+1$ 且 $\mathit y+y''=m+1$ 。 
需要注意的是，对称飞行器最多使用$\text 5$次。

## 输入格式

第一行两个空格分隔的正整数 $\mathit n,m$ ，分别代表迷宫的行数和列数。
接下来 $\mathit n$ 行 每行一个长度为 $\mathit m$ 的字符串来描述这个迷宫。
其中
$\mathit .$ 代表通路。
$\text #$ 代表障碍。
$\mathit S$ 代表起点。
$\mathit E$ 代表终点。
保证只有一个 $\mathit S$ 和 一个 $\mathit E$ 。
$2 \leq n,m \leq 500$

## 输出格式

仅一行一个整数表示从起点最小花费多少时间单位到达终点。
如果无法到达终点，输出 $\text -1$ 。

## 样例

### 样例 1

**输入：**
```
4 4
#S..
E#..
#...
....
```

**输出：**
```
4
```

**说明：**
一种可行的路径是用对称飞行器到达 $\text (4,3)$ 再向上走一步，再向右走一步，然后使用一次对称飞行器到达终点。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.237680+00:00', '2026-07-04T03:10:42.687645+00:00', 2000, 262144, '技术'),
	(309, '两个序列', '两个序列', '阿里', 'Medium', 'simulation', '小强有两个序列$\mathit a$和$\mathit b$，这两个序列都是由相同的无重复数字集合组成的，现在小强想把$\mathit a$序列变成$\mathit b$序列，他只能进行以下的操作：
从序列$\mathit a$中选择第一个或者最后一个数字并把它插入$\mathit a$中的任意位置。
问小强至少需要几次操作可以将序列$\mathit a$变为序列$\mathit b$。

## 输入格式

一行一个整数$\mathit n$表示序列的长度。
接下来两行每行$\mathit n$个整数。
第一行表示序列$\mathit a$，第二行表示序列$\mathit b$。

$1 \leq n \leq 10^5$
$1 \leq a_i,b_i \leq 10^9$
保证给出的序列符合题意。

## 输出格式

输出一行一个整数表示答案。

## 样例

### 样例 1

**输入：**
```
4
4 2 3 1
1 2 3 4
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.541216+00:00', '2026-07-04T03:09:25.859714+00:00', 2000, 262144, '技术'),
	(308, '合法连续子段', '合法连续子段', '阿里', 'Medium', 'intervals', '小强有一个长度为$n$的数组$a$和正整数$m$.
他想请你帮他计算数组$a$中有多少个连续子区间[l,r],其区间内存在某个元素出现的次数不小于$m$次?
例如数组$a=[1,2,1,2,3]$且$m =2$,那么区间[1,3],[1,4],[1,5],[2,4],[2,5]都是满足条件的区间,但区间[3,4]等都是不满足条件的.

## 输入格式

第一行输入两个正整数$n$和$m$.
第二行输入n个正整数$a[i]​$.
$1\leq m \leq n \leq 400000$
$1 \leq a[i] \leq n$

## 输出格式

输出一个整数表示答案.

## 样例

### 样例 1

**输入：**
```
5 2
1 2 1 2 3
```

**输出：**
```
5
```

**说明：**
满足条件的区间为[1,3],[1,4],[1,5],[2,4],[2,5].', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.491367+00:00', '2026-07-04T03:09:36.155869+00:00', 2000, 262144, '技术'),
	(316, '小强的神奇矩阵', '小强的神奇矩阵', '阿里', 'Medium', 'matrix-grid', '小强有一个$3\times n$的矩阵$\mathit a$，他将$\mathit a$中每列的三个数字中取出一个按顺序组成一个长度为$\mathit n$的数组$\mathit b$，即$b_i$可以是$a_{1,i},a_{2,i},a_{3,i}$其中任意一个。问$\sum_{i=1}^{n-1}\left|b_i-b_{i+1}\right|$的最小值是多少。

## 输入格式

第一行，一个正整数$\mathit n$。
第二行到第四行输入一个$3\times n$的矩阵$\mathit a$，每行输入$\mathit n$个正整数。
$2<=n<=10^5,1<=a_{i,j}<=10^9$。

## 输出格式

一行一个正整数表示答案。

## 样例

### 样例 1

**输入：**
```
5
5 9 5 4 4
4 7 4 10 3
2 10 9 2 3
```

**输出：**
```
5
```

**说明：**
数组$\mathit b$可以为$\left[5,7,5,4,4\right]$，答案为$\text 5$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.887542+00:00', '2026-07-04T03:08:07.954462+00:00', 2000, 262144, '技术'),
	(313, '比例问题', '比例问题', '阿里', 'Medium', 'simulation', '小强想要从$[1,A]$中选出一个整数$x$,从$[1,B]$中选出一个整数$y$ .使得满足$\frac{x}{y}$ = $\frac{a}{b}$的同时且$x$和$y$的乘积最大。如果不存在这样的$x$和$y$,请输出“ 0 0”.

## 输入格式

输入一行包含四个整数$A$,$B$,$a$和$b$.
$1 \leq A,B,a,b \leq 2e9$

## 输出格式

输出两个整数表示满足条件的$x$和$y$.若不存在，则输出"0 0".

## 样例

### 样例 1

**输入：**
```
1 1 2 1
```

**输出：**
```
0 0
```

### 样例 2

**输入：**
```
1000 500 4 2
```

**输出：**
```
1000 500
```

### 样例 3

**输入：**
```
1000 500 3 1
```

**输出：**
```
999 333
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.739840+00:00', '2026-07-04T03:08:43.228506+00:00', 2000, 262144, '技术'),
	(321, '讨厌鬼的数组拼接', '讨厌鬼的数组拼接', '阿里', 'Medium', 'prefix-sum', '定义一个所有元素互不相等的数组的权值为：”最大值所在位置”的下标和”最小值所在位置“的下标的差值。

例如，若最大值为$a_i$，最小值为$a_j$，则该数组的权值为$|i - j|$。

讨厌鬼现在有一个长度为$n$互不相等的数组$a$，以及一个有$m$个元素的集合$s$。

你需要选取集合中的任意个元素（每个元素最多只能用一次），将其按任意顺序拼接至数组的前缀或后缀。

例如数组为[2,3,4,6]，集合为{5,7,11}。则合法的拼接可能是[2,3,4,6,7,11,5]或[7,5,2,3,4,6,11]或[7,2,3,4,6]。

请你找到所有可能的拼接中权值的最大值。

## 输入格式

第一行两个整数$n,m(1 \leq n,m \leq 10^5)$。
第二行$n$个整数$a_i(1 \leq a_i \leq 10^9)$，保证数组元素互不相同。
第三行$m$个整数$s_i(1 \leq s_i \leq 10^9)$，保证集合元素与数组元素互不相同。

## 输出格式

输出一个整数表示权值的最大值。

## 样例

### 样例 1

**输入：**
```
4 3
3 2 4 6
5 7 11
```

**输出：**
```
5
```

**说明：**
权值最大的拼接为[3,2,4,6,5,7,11]。权值为 7 - 2 = 5。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705812/detail?pid=55429228&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705812/detail?pid=55429228&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:37.122141+00:00', '2026-07-04T03:07:09.476625+00:00', 2000, 262144, '技术'),
	(320, '小红的水滴', '小红的水滴', '阿里', 'Medium', 'graphs', '小红在二维平面上有 $n$ 滴水滴，水滴的坐标为 $(x_i, y_i)$，水滴每秒会向四个方向扩散，如果 $(x, y)$ 有一滴水滴，那么在下一秒，$(x+1, y), (x-1, y), (x, y+1), (x, y-1)$ 也会有一滴水滴，现在小红想知道，最少需要多少秒，所有水滴都在一个连通块内。

## 输入格式

第一行一个整数 $n$，表示水滴的数量。
接下来 $n$ 行，每行两个整数 $x_i, y_i$，表示第 $i$ 滴水滴的坐标。
$1 \leq n \leq 1000$
$1 \leq x_i, y_i \leq 10^8$

## 输出格式

输出一个整数，表示最少需要多少秒，所有水滴都在一个连通块内。

## 样例

### 样例 1

**输入：**
```
3
1 1
2 2
4 3
```

**输出：**
```
2
```

**说明：**
最少需要 2 秒
第 1 秒：$(1, 2)$ 出现一滴水滴，第 1 滴水滴和第 2 滴水滴连通
第 2 秒：$(2, 3), (3, 3)$ 处都有水滴，第 3 滴水滴和第 2 滴水滴连通', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705812/detail?pid=55429228&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705812/detail?pid=55429228&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:37.075863+00:00', '2026-07-04T03:07:21.576622+00:00', 2000, 262144, '技术'),
	(319, '视力表', '视力表', '阿里', 'Medium', 'simulation', '小强今天体检，其中有一个环节是测视力 
小强看到的视力表是一张$N \times N$的表格，但是由于小强视力太差，他无法看清表格中的符号。不过热爱数学的他给自己出了这样一个问题：假设现在有a个向上的符号，b个向下的符号，c个向左的符号，d个向右的符号，把这些符号填到视力表中，总共有多少种可能的情况呢？

## 输入格式

第一行输入五个数N, a, b, c, d
保证$a + b + c + d = N \times N$

## 输出格式

输出一个数字，表示答案
由于结果可能很大，只需输出对998244353取模之后的结果即可

## 样例

### 样例 1

**输入：**
```
2 3 1 0 0
```

**输出：**
```
4
```

**说明：**
共有如下四种情况

上上 上上
上下 下上

上下 下上
上上 上上

### 样例 2

**输入：**
```
2 2 1 1 0
```

**输出：**
```
12
```

### 样例 3

**输入：**
```
2 1 1 1 1
```

**输出：**
```
24
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:37.027298+00:00', '2026-07-04T03:07:33.531860+00:00', 2000, 262144, '技术'),
	(322, '小红的取数平均', '小红的取数平均', '阿里', 'Medium', 'string', '小红拿到了一个数组，她每次操作可以选择两个元素，将它们变成它们的平均数（当且仅当这两个元素的平均数为整数时才可操作）。小红想知道，自己能否通过一次操作，使得所有元素的乘积为偶数？

## 输入格式

第一行输入一个正整数$t$，代表询问次数。
每组询问输入两行，第一行为一个正整数$n$，代表数组的大小；第二行为$n$个正整数$a_i$，代表数组的元素。
$1\leq t \leq 10$
$1\leq n \leq 100000$
$1\leq a_i \leq 10^9$
保证所有数据中，$n$ 的总和不超过 100000。

## 输出格式

输出$t$行，每行输出一个字符串代表询问的结果。
如果有解，则输出"Yes"。否则输出"No"。

## 样例

### 样例 1

**输入：**
```
3
2
1 2
3
1 3 5
3
3 3 3
```

**输出：**
```
Yes
Yes
No
```

**说明：**
第一组：1和2的平均数不是整数，因此不能操作，乘积是偶数。
第二组：选中1和3，然后数组变成2 2 5，乘积是偶数。
第三组：无论怎么操作都不能变成偶数。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705812/detail?pid=55429228&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705812/detail?pid=55429228&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:37.164557+00:00', '2026-07-04T03:06:58.773724+00:00', 2000, 262144, '技术'),
	(318, '删除字符', '删除字符', '阿里', 'Medium', 'string', '有一个长度为$\mathit n$的字符串 $\mathit s$，你可以删除其中的 $\mathit m$个字符，使剩余字符串的字典序最小，输出这个剩余字符串。

## 输入格式

第一行输入一个整数$\mathit T$，代表接下来有$\mathit T$组测试数据。
对于每一组测试数据，第一行输入两个数$\mathit n,m$代表字符串的长度和可以删除的字符数量。
接下来输入长度为$\mathit n$字符串。
$1\le T\le 5$
$2\le n\le 100000$
$1\le m<n$

## 输出格式

对于每一组数据，输出一个答案

## 样例

### 样例 1

**输入：**
```
2
5 2
abcab
10 4
lkqijxsnny
```

**输出：**
```
aab
ijsnny
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.979659+00:00', '2026-07-04T03:07:44.892421+00:00', 2000, 262144, '技术'),
	(317, '蚂蚁森林之王', '蚂蚁森林之王', '阿里', 'Medium', 'simulation', '很久很久以前，在蚂蚁森林里住着 $\mathit n$ 只小动物，编号从 $\text 1$ 到 $\mathit n$ 。编号越小的动物能力值越大。现在他们想投票选出一只小动物当森林之王，对于每只小动物来说，如果他有崇拜的对象，那么他可能投票选择自己，或与自己崇拜的对象投相同票；如果他没有崇拜的对象，那么他投票只可能选择自己。
每只小动物只会崇拜能力值比自己大的小动物。
记者小强拜访了这 $\mathit n$ 只小动物，了解到每只小动物是否有崇拜的对象以及具体是谁。现在他想知道每个人能得到的最高票数是多少。

## 输入格式

第一行一个正整数 $\mathit n$ ，代表小动物的数量。
第二行 $\mathit n$ 个以空格分隔的正整数 $A_{i}$ ，代表每只小动物崇拜的小动物。 
若 $A_{i}=0$，则代表第 $\mathit i$ 只小动物没有崇拜的对象。
$1 \leq n \leq 2×10^{5}$ 。
保证 $0 \leq A_{i} < i$。

## 输出格式

共 $\mathit n$ 行，第 $\mathit i$ 行代表第 $\mathit i$ 只小动物可能得到的最多票数。

## 样例

### 样例 1

**输入：**
```
4
0 1 1 1
```

**输出：**
```
4
1
1
1
```

**说明：**
如果第 $\text 2,3,4$ 只小动物均和第一只投一样的票，则第一只小动物可以获得四票。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.932128+00:00', '2026-07-04T03:07:55.441450+00:00', 2000, 262144, '技术'),
	(314, '小强修水渠', '小强修水渠', '阿里', 'Medium', 'graphs', '在一张$2D$地图上小强有$n$座房子,因为地理位置的原因没有办法给每座房子提供水源,所以小强打算修建一条平行$y$轴的水渠.因为这条水渠无限长.所以能够看做是一条平行于$y$轴的直线. 现在小强想确定修建水渠的位置,能够使得这$n$座房子到水渠的垂直距离和最小,请你输出最小的距离和.

## 输入格式

第一行输入一个正整数$n$.
接下来$n$行,每行输入两个正整数$x_i$,$y_i$,分别表示每个房子所在的二维坐标.
$0 \leq x_i,y_i\leq 100000$
$1\leq n \leq 100000$

## 输出格式

输出一个整数表示答案

## 样例

### 样例 1

**输入：**
```
4
0 0
0 50
50 50
50 0
```

**输出：**
```
100
```

**说明：**
当修建水渠位置的直线方程为$\mathit x=0$或者$\mathit x=50$时,都能获得最小距离和.', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.785068+00:00', '2026-07-04T03:08:32.516627+00:00', 2000, 262144, '技术'),
	(312, '小强去春游', '小强去春游', '阿里', 'Medium', 'simulation', '小强作为强班的班长.决定带着包含他在内的$n$个同学去春游.路程走到一半,发现前面有一条河流.且只有一条小船.经过实验后发现,这个小船一次最多只能运送两个人.而且过河的时间是等于两个人中体重较大的那个人的体重.如果只有一个人,那么过河时间就是这个人的体重.现在小强想请你帮他分析如何安排才能在最短时间内使所有人都通过这条河流.小强很懒,他并不想知道具体怎么过河,只要你告诉他最短的时间.

## 输入格式

第一行输入一个整数$T$.表示有$T$组测试数据.
每组数据,第一行输入一个整数$n$.表示人数.
接下来一行输入$n$个整数$a[i]$,表示第$i$个人的体重是$a[i]$.
$1\leq T \leq 10$
$1\leq n \leq 10^{5}$
$1\leq a[i] \leq 10^{4}$

## 输出格式

每组测试数据输出一个答案.

## 样例

### 样例 1

**输入：**
```
2
4
2 10 12 11
4
2 3 7 8
```

**输出：**
```
37
19
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.691181+00:00', '2026-07-04T03:08:53.507491+00:00', 2000, 262144, '技术'),
	(311, '选择物品', '选择物品', '阿里', 'Medium', 'hashing', '有$n$个物品可供选择，必须选择其中$m$个物品，请按字典序顺序输出所有选取方案的物品编号 
$1 2 3$与$312$与$321$等被认为是同一种方案，输出字典序最小的$123$即可 

数据范围：$1\le m\le n \le 10\$

进阶：时间复杂度$O(n!)\$，空见复杂度$O(n)\$

## 输入格式

对于每一组测试数据， 每行输入$2$个数$n$和$m$。
$1 \le m \le n \le 10$

## 输出格式

对于每组输入样例，按字典序输出所有方案选择物品的编号，每种方案占一行

## 样例

### 样例 1

**输入：**
```
4 1
```

**输出：**
```
1
2
3
4
```

### 样例 2

**输入：**
```
5 2
```

**输出：**
```
1 2
1 3
1 4
1 5
2 3
2 4
2 5
3 4
3 5
4 5
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.644592+00:00', '2026-07-04T03:09:03.953312+00:00', 2000, 262144, '技术'),
	(310, '完美对', '完美对', '阿里', 'Medium', 'simulation', '有$\ n$个物品，每个物品有$\ k$个属性，第$\ i$件物品的第$\ j$个属性用一个正整数表示记为$a_{i,j}$，两个不同的物品$\ i,j$被称为是完美对的当且仅当$a_{i,1}+a_{j,1} = a_{i,2}+a_{j,2}=\dots=a_{i,k}+a_{j,k}$，求完美对的个数。 

进阶：时间复杂度$O(nlogn)\$，空间复杂度$O(n)\$

## 输入格式

第一行两个数字$\ n,k$。

接下来$\ n$行，第$\ i$行$\ k$个数字表示$a_{i,1}, a_{i,2},\dots,a_{i,k}$。

$1 \leq n \leq 10^5, 2 \leq k \leq 10, 1 \leq a_i \leq 100$

## 输出格式

一行一个数字表示答案

## 样例

### 样例 1

**输入：**
```
5 3
2 11 21
19 10 1
20 11 1
6 15 24
18 27 36
```

**输出：**
```
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705796/detail?pid=30440590&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.595733+00:00', '2026-07-04T03:09:14.754262+00:00', 2000, 262144, '技术'),
	(306, '牛牛们吃糖果', '牛牛们吃糖果', '阿里', 'Medium', 'simulation', '有$\mathit n$个牛牛一起去朋友家吃糖果，第$\mathit i$个牛牛一定要吃$a_i$块糖果. 
而朋友家一共只有$\mathit m$块糖果，可能不会满足所有的牛牛都吃上糖果。 
同时牛牛们有$\mathit k$个约定，每一个约定为一个牛牛的编号对$(i,j)$，表示第$\mathit i$个和第$\mathit j$个牛牛是好朋友，他俩要么一起都吃到糖果，要么一起都不吃。 
保证每个牛牛最多只出现在一个编号对中。 
您可以安排让一些牛牛吃糖果，一些牛牛不吃。 
要求使能吃上糖果的牛牛数量最多（吃掉的糖果总量要小于等于$\mathit m$），并要满足不违反牛牛们的$\mathit k$个约定。

## 输入格式

第一行$\text 2$个正整数 $n,m$，$1\leq n\leq 10^3,1\leq m \leq 10^3$
第二行$\mathit n$个正整数$a_1,a_2,\dots,a_n$ ,$1\leq a_i \leq 10^6$
第三行$\text 1$个整数$k,0 \leq k \leq \frac{n}{2}$
接下来$\mathit k$行，每行两个正整数$i,j$ ，表示第$\mathit i$个牛牛与第$\mathit j$个牛牛有约定。

## 输出格式

一行一个数字表示最多能吃上糖果的牛牛个数

## 样例

### 样例 1

**输入：**
```
3 10
5 1 5
1
1 3
```

**输出：**
```
2
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.389415+00:00', '2026-07-04T03:10:02.465969+00:00', 2000, 262144, '技术'),
	(304, '知识竞赛', '知识竞赛', '阿里', 'Medium', 'simulation', '最近部门要选两个员工去参加一个需要合作的知识竞赛，每个员工均有一个推理能力值 $A_{i}$，以及一个阅读能力值 $B_{i}$。如果选择第 $\mathit i$ 个人和第 $\mathit j$ 个人去参加竞赛，那么他们在阅读方面所表现出的能力为 $X=\frac{(B_{i}+B_{j})}{2}$，他们在推理方面所表现出的能力为 $Y=\frac{(A_{i}+A_{j})}{2}$。
现在需要最大化他们表现较差一方面的能力，即让 $\mathit min(X,Y)$ 尽可能大，问这个值最大是多少。 

进阶：时间复杂度$O(nlogn)\$，空间复杂度$O(n)\$

## 输入格式

第一行一个正整数 $\mathit n$，代表员工数。
接下来 $\mathit n$ 行每行两个正整数 $A_{i},B_{i}$，分别用来描述第 $\mathit i$ 个员工的推理和阅读能力。
$2 \leq n \leq 2×10^{5}$
$1 \leq A_{i},B_{i} \leq 10^{8}$

## 输出格式

仅一行一个一位小数用来表示答案。

## 样例

### 样例 1

**输入：**
```
3
2 2
3 1
1 3
```

**输出：**
```
2.0
```

**说明：**
选择第一个和第二个员工或第一个和第三个时，较差方面的能力都是 $\text 1.5$，选择第二个和第三个时较差方面能力是 $\text 2$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.291125+00:00', '2026-07-04T03:10:28.002768+00:00', 2000, 262144, '技术'),
	(302, '二叉树', '二叉树', '阿里', 'Medium', 'tree', '小强现在有$n$个节点,他想请你帮他计算出有多少种不同的二叉树满足节点个数为$n$且树的高度不超过$m$的方案.因为答案很大,所以答案需要模上1e9+7后输出.
树的高度: 定义为所有叶子到根路径上节点个数的最大值.
例如: 当n=3,m=3时,有如下5种方案: 

![题面配图](https://uploadfiles.nowcoder.com/images/20200222/323898_1582380379452_4307F24263E8D6DF6C530DCC7C2FBC2A)

![题面配图](https://uploadfiles.nowcoder.com/images/20200222/323898_1582380410065_6C4156E83BE0BF4165D6BF44B4A4D874)

![题面配图](https://uploadfiles.nowcoder.com/images/20200222/323898_1582380459547_AAD255AB35FBF4E12ED1705B84560864)

![题面配图](https://uploadfiles.nowcoder.com/images/20200222/323898_1582380472187_4F717C8F147F72C750CD641AF752AF9C)

![题面配图](https://uploadfiles.nowcoder.com/images/20200222/323898_1582380484183_8FED80FB3442628AAACA8E903B817D1C)

数据范围：$1\le n,m\le 50\$ 
进阶：时间复杂度$O(mn^2)\$，空间复杂度$O(nm)\$

## 输入格式

第一行输入两个正整数$n$和$m$.
$1\leq m \leq n \leq 50$

## 输出格式

输出一个答案表示方案数.

## 样例

### 样例 1

**输入：**
```
3 3
```

**输出：**
```
5
```

### 样例 2

**输入：**
```
3 2
```

**输出：**
```
1
```

### 样例 3

**输入：**
```
4 3
```

**输出：**
```
6
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.185963+00:00', '2026-07-04T03:10:56.135273+00:00', 2000, 262144, '技术'),
	(301, '小强爱数学', '小强爱数学', '阿里', 'Medium', 'simulation', '小强发现当已知$xy = B$以及$x+y = A$时,能很轻易的算出$x^2+y^2$的值.但小强想请你在已知$A$ 和$B$的情况下,计算出$x^n+y^n$的值.因为这个结果可能很大,所以所有的运算都在模1e9+7下进行.

## 输入格式

第一行输入一个正整数$T$.表示有$T$组数据
接下来$T$行,每行输入三个整数$A$,$B$和$n$.
$1\leq T \leq 100$
$0\leq A,B < 1e9+7$
$1\leq n \leq 1e5$

## 输出格式

输出$T$行,每一行表示每组数据的结果.

## 样例

### 样例 1

**输入：**
```
3
4 4 3
2 3 4
5 2 6
```

**输出：**
```
16
999999993
9009
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705766/detail?pid=30440638&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D28910,11200,11240,142700,28909,28908,134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:06:36.138543+00:00', '2026-07-04T03:11:08.973220+00:00', 2000, 262144, '技术'),
	(325, '小红的取数平均-2', '小红的取数平均', '阿里', 'Medium', 'string', '小红拿到了一个数组，她每次操作可以选择两个元素，将它们变成它们的平均数（当且仅当这两个元素的平均数为整数时才可操作）。小红想知道，自己能否通过一次操作，使得所有元素的乘积为偶数？

## 输入格式

第一行输入一个正整数$t$，代表询问次数。
每组询问输入两行，第一行为一个正整数$n$，代表数组的大小；第二行为$n$个正整数$a_i$，代表数组的元素。
$1\leq t \leq 10$
$1\leq n \leq 100000$
$1\leq a_i \leq 10^9$
保证所有数据中，$n$ 的总和不超过 100000。

## 输出格式

输出$t$行，每行输出一个字符串代表询问的结果。
如果有解，则输出"Yes"。否则输出"No"。

## 样例

### 样例 1

**输入：**
```
3
2
1 2
3
1 3 5
3
3 3 3
```

**输出：**
```
Yes
Yes
No
```

**说明：**
第一组：1和2的平均数不是整数，因此不能操作，乘积是偶数。
第二组：选中1和3，然后数组变成2 2 5，乘积是偶数。
第三组：无论怎么操作都不能变成偶数。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705825/detail?pid=55429313&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705825/detail?pid=55429313&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:11:43.183839+00:00', '2026-07-04T03:11:57.940545+00:00', 2000, 262144, '算法'),
	(324, '讨厌鬼的数组拼接-2', '讨厌鬼的数组拼接', '阿里', 'Medium', 'prefix-sum', '定义一个所有元素互不相等的数组的权值为：”最大值所在位置”的下标和”最小值所在位置“的下标的差值。

例如，若最大值为$a_i$，最小值为$a_j$，则该数组的权值为$|i - j|$。

讨厌鬼现在有一个长度为$n$互不相等的数组$a$，以及一个有$m$个元素的集合$s$。

你需要选取集合中的任意个元素（每个元素最多只能用一次），将其按任意顺序拼接至数组的前缀或后缀。

例如数组为[2,3,4,6]，集合为{5,7,11}。则合法的拼接可能是[2,3,4,6,7,11,5]或[7,5,2,3,4,6,11]或[7,2,3,4,6]。

请你找到所有可能的拼接中权值的最大值。

## 输入格式

第一行两个整数$n,m(1 \leq n,m \leq 10^5)$。
第二行$n$个整数$a_i(1 \leq a_i \leq 10^9)$，保证数组元素互不相同。
第三行$m$个整数$s_i(1 \leq s_i \leq 10^9)$，保证集合元素与数组元素互不相同。

## 输出格式

输出一个整数表示权值的最大值。

## 样例

### 样例 1

**输入：**
```
4 3
3 2 4 6
5 7 11
```

**输出：**
```
5
```

**说明：**
权值最大的拼接为[3,2,4,6,5,7,11]。权值为 7 - 2 = 5。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705825/detail?pid=55429313&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705825/detail?pid=55429313&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:11:43.138701+00:00', '2026-07-04T03:12:07.631231+00:00', 2000, 262144, '算法'),
	(323, '小红的水滴-2', '小红的水滴', '阿里', 'Medium', 'graphs', '小红在二维平面上有 $n$ 滴水滴，水滴的坐标为 $(x_i, y_i)$，水滴每秒会向四个方向扩散，如果 $(x, y)$ 有一滴水滴，那么在下一秒，$(x+1, y), (x-1, y), (x, y+1), (x, y-1)$ 也会有一滴水滴，现在小红想知道，最少需要多少秒，所有水滴都在一个连通块内。

## 输入格式

第一行一个整数 $n$，表示水滴的数量。
接下来 $n$ 行，每行两个整数 $x_i, y_i$，表示第 $i$ 滴水滴的坐标。
$1 \leq n \leq 1000$
$1 \leq x_i, y_i \leq 10^8$

## 输出格式

输出一个整数，表示最少需要多少秒，所有水滴都在一个连通块内。

## 样例

### 样例 1

**输入：**
```
3
1 1
2 2
4 3
```

**输出：**
```
2
```

**说明：**
最少需要 2 秒
第 1 秒：$(1, 2)$ 出现一滴水滴，第 1 滴水滴和第 2 滴水滴连通
第 2 秒：$(2, 3), (3, 3)$ 处都有水滴，第 3 滴水滴和第 2 滴水滴连通', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2023, 'https://www.nowcoder.com/exam/test/97705825/detail?pid=55429313&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705825/detail?pid=55429313&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:11:43.090711+00:00', '2026-07-04T03:12:17.525709+00:00', 2000, 262144, '算法'),
	(328, '小苯的魔法染色', '小苯的魔法染色', '阿里', 'Medium', 'string', '小红面前有一堵长度为 $n$ 的墙，用一个只由 $\tt W$（白色）和 $\tt R$（红色）组成的字符串 $a_1a_2\dots a_n$ 表示。她希望最终将整面墙全部染成红色。

为此她请来了魔法师小苯。一次施法的流程如下：

小苯选择一个闭区间 $[l,r]\ (1\leqq l\leqq r\leqq n)$；

立刻将区间内的所有格子染成红色。

小苯至多施法 $m$ 次，且每次施法的区间长度 $\left(r-l+1\right)$ 不得超过 $k$。

现在小苯想知道，将整堵墙染成红色所需的最小 $k$ 是多少。请你求出这个 $k$ 的最小可能值。

## 输入格式

输入包含两行。

第一行输入两个正整数 $n,m\ \left(1\leqq m\leqq n\leqq 2\times10^5\right)$——墙的长度与小苯允许施法的最大次数。

第二行输入一个长度为 $n$ 的字符串 $s$，保证 $s$ 仅由字符 $\tt W$ 与 $\tt R$ 组成。

## 输出格式

输出一个正整数，表示满足要求的最小 $k$。

## 样例

### 样例 1

**输入：**
```
5 2
WRWWR
```

**输出：**
```
2
```

**说明：**
小苯可以进行 $m = 2$ 次操作，每次操作的长度必须在 $2$ 以内。
一种可能的染色方式是：选择 $[1, 2]$ 再选择 $[3,4]$，操作后整面墙都会被染红，可以证明不存在单次操作比 $2$ 更小的长度。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705956/detail?pid=60164044&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705956/detail?pid=60164044&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:16:42.417699+00:00', '2026-07-04T03:17:25.879997+00:00', 2000, 262144, '技术'),
	(327, '小苯的比赛上分', '小苯的比赛上分', '阿里', 'Medium', 'simulation', '有一款著名的大型多人电子竞技游戏网站“喜爱福”，通常会举办一些比赛。选手通常只有一个账号，但一些人会“开小号”以提高最高分数。

小苯是一名忠实玩家，他拥有 $n$ 个账号，每个账号当前的分数为 $a_i$。

st****lk 的名言是：“只要你永远使用分数最低的账号参赛，那么你的 $\max \mathrm{Rating}$ 将单调不降。”这里的 $\max \mathrm{Rating}$ 指玩家所有账号中最高分的值。

已知小苯会牢记此名言，并且在记录的 $m$ 场比赛中，每次都使用当前分数最低的账号参赛。假设第 $j$ 场比赛会让该账号分数增加 $b_j$，请你计算每场比赛结束后，小苯的 $\max \mathrm{Rating}$。

## 输入格式

第一行输入两个正整数 $n, m\left(1 \leqq n, m \leqq 10^5\right)$，分别表示账号数量和比赛场次。

第二行输入 $n$ 个整数 $a_1, a_2, \dots, a_n\left(0 \leqq a_i \leqq 10^9\right)$，表示各账号初始分数。

第三行输入 $m$ 个整数 $b_1, b_2, \dots, b_m\left(0 \leqq b_j \leqq 10^9\right)$，其中第 $j$ 个数表示第 $j$ 场比赛结束后账号分数的增加值。

## 输出格式

输出 $m$ 行，第 $j$ 行输出第 $j$ 场比赛结束后，小苯的 $\max \mathrm{Rating}$。

## 样例

### 样例 1

**输入：**
```
5 6
1145 1500 1600 1538 1222
10 400 500 1000 2000 10000
```

**输出：**
```
1600
1600
1722
2500
3538
11555
```

**说明：**
共比赛了 6 场，每场结束后均输出小苯所有账号中的最高分。

初始分数最低的账号分数为 1145，第一场比赛后其分数变为 $1145 + 10 = 1155$，最高分依旧为 1600，故输出 1600。

第二场比赛使用当前最低分账号 1155 参赛，分数增加 400 变为 1555，最高分仍为 1600，故输出 1600。

第三场比赛使用当前最低分 1222 参赛，分数增加 500 变为 1722，此时最高分为 1722，故输出 1722。

以此类推，得到后续输出。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705956/detail?pid=60164044&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705956/detail?pid=60164044&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:16:42.363618+00:00', '2026-07-04T03:17:34.910891+00:00', 2000, 262144, '技术'),
	(326, '小苯的区间删除', '小苯的区间删除', '阿里', 'Medium', 'intervals', '小苯有一个长度为 $n$ 的数组 $a$，他想要使得数组 $a$ 有序（单调不降）。

为此，他必须选择一段区间 $[l, r], (1\leq l \leq r \leq n)$，将数组的这一段删除，其他的部分（如果存在的话）就按顺序拼在一起。

现在他想知道有多少种不同的选择区间的方案。

注：小苯认为，空数组也满足有序，即你可以选择 $[1,n]$ 这个区间。

## 输入格式

输入包含两行。
第一行一个正整数 $n, (1 \leq n \leq 2 \times 10^5)$，表示数组的长度。
第二行 $n$ 个正整数 $a_i, (1 \leq a_i \leq 10^9)$，表示数组 $a$。

## 输出格式

输出一行一个正整数表示答案。

## 样例

### 样例 1

**输入：**
```
3
1 2 3
```

**输出：**
```
6
```

**说明：**
可以选择：
$[1, 1], [2,2],[3,3],[1,2],[2,3],[1,3]$
这六个区间。

### 样例 2

**输入：**
```
5
1 3 2 2 5
```

**输出：**
```
10
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705956/detail?pid=60164044&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705956/detail?pid=60164044&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:16:42.306976+00:00', '2026-07-04T03:17:45.764471+00:00', 2000, 262144, '技术'),
	(331, '小红的完全平方数', '小红的完全平方数', '阿里', 'Medium', 'simulation', '$\,\,\,\,\,\,\,\,\,\,$小红有一个长度为 $n$ 的整数数组 $\{a_1,a_2\dots,a_n\}$ ，如果从数组中任选两个数 $a_i, a_j (i \neq j)$，他们的乘积都是完全平方数，那么这个数组就是好数组。

$\,\,\,\,\,\,\,\,\,\,$如果现在的数组不是一个好数组，小红可以执行任意多次操作：

$\,\,\,\,\,\,\,\,\,\,\,\,\,\,$从数组里选择一个数，将其乘以一个正整数 $x$ ；

$\,\,\,\,\,\,\,\,\,\,$她想知道，最少需要多少次操作才能使数组变成好数组。

$\,\,\,\,\,\,\,\,\,\,$如果一个数可以被表示为一个整数的平方，那么这个数就是完全平方数。

## 输入格式

$\,\,\,\,\,\,\,\,\,\,$第一行输入一个整数 $n\left(1 \leq n \leq 10^5\right)$ 代表数组中元素的数量。
$\,\,\,\,\,\,\,\,\,\,$第二行输入 $n$ 个整数 $a_1, a_2, \dots, a_n\left(1 \leq a_i \leq 10^6\right)$ 代表数组中的元素。

## 输出格式

$\,\,\,\,\,\,\,\,\,\,$在一行上输出一个整数，代表最少需要的操作次数。

## 样例

### 样例 1

**输入：**
```
4
1 1 4 2
```

**输出：**
```
1
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$将第四个数乘 $2$ 即可，获得 $[1, 1, 4, 4]$ ，其中任意两个数的和乘积为完全平方数。

### 样例 2

**输入：**
```
5
1 2 3 4 5
```

**输出：**
```
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705968/detail?pid=60928596&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705968/detail?pid=60928596&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:16:42.600089+00:00', '2026-07-04T03:16:55.701448+00:00', 2000, 262144, '技术'),
	(330, '小苯的子串删除', '小苯的子串删除', '阿里', 'Medium', 'string', '$\,\,\,\,\,\,\,\,\,\,$小苯有一个长度为 $n$ 的数字串 $s$，他想要将 $s$ 变为 $3$ 的倍数。为此，他可以进行最多一次操作：

$\,\,\,\,\,\,\,\,\,\,\,\,\,\,$选择一段区间 $[l, r]\ (1 \leq l \leq r \leq n)$，删除 $s_l, s_{l+1}, \dots, s_r$ 这一段数位。

$\,\,\,\,\,\,\,\,\,\,$他想知道有多少种不同的删除区间方案，使得 $s$ 是 $3$ 的倍数。请你帮帮他吧。

## 输入格式

$\,\,\,\,\,\,\,\,\,\,$第一行输入一个整数 $n\left(1 \leq n \leq 2\times 10^5\right)$，表示字符串长度。
$\,\,\,\,\,\,\,\,\,\,$第二行输入一个长度为 $n$ 且仅包含数字的字符串 $s$ 。

## 输出格式

$\,\,\,\,\,\,\,\,\,\,$在一行上输出输出一个整数，表示不同的删除方案数。

## 样例

### 样例 1

**输入：**
```
4
1233
```

**输出：**
```
7
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$如果选择进行操作，则可能删除的区间有：
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● $[1, 2]$，则剩余 "$\tt 33$" ，满足是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● $[3, 3]$，剩余 "$\tt 123$" ，满足是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● $[1, 3]$，剩余 "$\tt 3$" ，满足是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● $[4, 4]$，剩余 "$\tt 123$" ，满足是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● $[3, 4]$，剩余 "$\tt 12$" ，满足是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● $[1, 4]$（全部删除）则剩余 "$\tt 0$" ，也满足是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 不进行操作，则剩余 "$\tt 1233$" ，也是 $3$ 的倍数。
$\,\,\,\,\,\,\,\,\,\,$则共有七种删除方案（注意，不删除/全删除也是删除方案）。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705968/detail?pid=60928596&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705968/detail?pid=60928596&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:16:42.540620+00:00', '2026-07-04T03:17:06.536412+00:00', 2000, 262144, '技术'),
	(329, '小红闯关', '小红闯关', '阿里', 'Medium', 'simulation', '$\,\,\,\,\,\,\,\,\,\,$小红在玩一个游戏，这个游戏有 $n$ 个关卡，通过第 $i$ 个关卡需要消耗 $a_i$ 个单位时间，小红必须按从前往后的顺序通过每一个关卡。

$\,\,\,\,\,\,\,\,\,\,$每通过 $k$ 个关卡，小红会获得一个跳关道具，跳关道具可以在任意一个关卡使用，使用跳关道具后可以不消耗时间直接通过关卡。

$\,\,\,\,\,\,\,\,\,\,$小红想知道她通过这 $n$ 个关卡，最少需要多少时间。

## 输入格式

$\,\,\,\,\,\,\,\,\,\,$第一行输入两个整数 $n, k\left(1 \leq n, k \leq 10^5\right)$ 代表关卡数量和获得跳关道具的条件。
$\,\,\,\,\,\,\,\,\,\,$第二行输入 $n$ 个整数 $a_1, a_2, \dots, a_n\left(1 \leq a_i \leq 10^5\right)$ 代表通过每个关卡需要消耗的时间。

## 输出格式

$\,\,\,\,\,\,\,\,\,\,$在一行上输出一个整数，表示小红通过这 $n$ 个关卡所需的最少时间。

## 样例

### 样例 1

**输入：**
```
3 2
1 3 2
```

**输出：**
```
4
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$小红通过第二个关卡后获得跳关道具，此时消耗 $1+3$ 单位时间；在第三个关卡使用跳关道具，不再消耗时间。

### 样例 2

**输入：**
```
6 2
1 1 4 5 1 4
```

**输出：**
```
7
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$小红通过第二个关卡后获得第一个跳关道具；
$\,\,\,\,\,\,\,\,\,\,$在第四个关卡使用第一个跳关道具后得到第二个跳关道具；
$\,\,\,\,\,\,\,\,\,\,$在第六个关卡使用第二个跳关道具。

### 样例 3

**输入：**
```
5 1
2 4 5 1 3
```

**输出：**
```
2
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$通过第一关后，后面的关卡都可以使用跳关道具。跳关也算一次成功的闯关。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705968/detail?pid=60928596&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705968/detail?pid=60928596&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:16:42.467280+00:00', '2026-07-04T03:17:15.888783+00:00', 2000, 262144, '技术'),
	(333, '小红的函数最大值', '小红的函数最大值', '阿里', 'Medium', 'simulation', '小红希望你求出函数 $f(x)=log_a x-bx$ 在定义域上的最大值。你能帮帮她吗？

## 输入格式

两个正整数$a,b$，用空格隔开
$2\leq a \leq 1000$
$1\leq b \leq 1000$

## 输出格式

该函数在定义域上的最大值。你只需要保证和标准答案的相对误差不超过$10^{-7}$即可通过本题。

## 样例

### 样例 1

**输入：**
```
2 1
```

**输出：**
```
-0.9139286679
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705978/detail?pid=60164024&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705978/detail?pid=60164024&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:19:07.138796+00:00', '2026-07-04T03:19:59.426325+00:00', 2000, 262144, '算法'),
	(337, '信用评分模型优化', '信用评分模型优化', '阿里', 'Medium', 'tree', '某银行希望优化其信用卡申请者的信用评分模型，以更准确地预测申请者的信用风险。为此，银行决定使用机器学习方法对申请者的特征数据进行分析。在这个任务中，你需要使用决策树算法中的信息增益比来选择最佳的特征，以进行信用风险分类。

## 输入格式

- 输入数据为一个二维列表，每个子列表代表一个申请者的记录，其中包含申请者的特征和信用评分结果（良好或不良）。最后一个元素为信用评分结果，其中 ''G'' 表示信用良好，''B'' 表示信用不良。其余元素代表申请者的不同特征值，例如年龄、年收入、信用卡余额等。

## 输出格式

- 输出信息增益比最高的特征的索引（从0开始计数），如果信息增益比最高的特征是第一个，则输出0，如果是第二个，则输出1，以此类推。

## 样例

### 样例 1

**输入：**
```
[[25, 50000, 2000, ''G''],[30, 55000, 3000, ''G''],[35, 60000, 0, ''B''],[40, 65000, 4000, ''B''],[28, 48000, 1000, ''G'']]
```

**输出：**
```
0
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705992/detail?pid=60928816&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705992/detail?pid=60928816&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:19:07.328916+00:00', '2026-07-04T03:19:18.983795+00:00', 2000, 262144, '算法'),
	(336, '小歪和大富翁2.0', '小歪和大富翁2.0', '阿里', 'Medium', 'simulation', '$\,\,\,\,\,\,\,\,\,\,$小歪在玩《大富翁》游戏，游戏中 $n$ 个城市围成一圈，编号从 $0$ 到 $n-1$ ，即第 $n-1$ 个城市的下一个城市是第 $0$ 个城市。第 $i$ 个城市上有一个数字 $a_i$ ，表示第一次到达第 $i$ 个城市可以获得 $a_i$ 枚金币。

$\,\,\,\,\,\,\,\,\,\,$每一轮开始时小歪会获得 $4$ 张卡牌，分别可以跳跃 1、2、3、4 个城市，例如小歪可以从城市一跳跃 $3$ 个城市到达城市四。当小歪使用完这 $4$ 张卡牌后，会开启新的一轮。

$\,\,\,\,\,\,\,\,\,\,$初始时，小歪拥有 $0$ 枚金币，小歪想知道她从第零个城市出发（出发时不会获得金币），经过 $k$ 轮后最多可以获得多少枚金币。

## 输入格式

$\,\,\,\,\,\,\,\,\,\,$第一行输入两个整数 $n$ 和 $k\ (10 \leq n \leq 10^5;\ 1 \leq k \leq 10^9)$ 代表城市个数、游戏轮数，数据保证 $n$ 一定是 10 的倍数。
$\,\,\,\,\,\,\,\,\,\,$第二行输入 $n$ 个整数 $a_1,a_2,\dots,a_n\ (-10^9 \leq a_i \leq 10^9)$ 表示第一次到达城市 $0$ 到 $n-1$ 可以获得的金币数量。

## 输出格式

$\,\,\,\,\,\,\,\,\,\,$在一行上输出一个整数，代表小歪能获得的最多金币数量。

## 样例

### 样例 1

**输入：**
```
10 1
-1 -1 2 3 4 -9 -9 -1 3 -1
```

**输出：**
```
9
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$最优的方法是：
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 1 步：使用跳跃 3 的卡牌，从 0 跳到 3 ，获得 3 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 2 步：使用跳跃 1 的卡牌，从 3 跳到 4 ，获得 4 枚金币，共有 7 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 3 步：使用跳跃 4 的卡牌，从 4 跳到 8 ，获得 3 枚金币，共有 10 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 4 步：使用跳跃 2 的卡牌，从 8 跳到 0 ，获得 -1 枚金币，共有 9 枚金币。

### 样例 2

**输入：**
```
10 2
-1 -1 2 3 4 -9 -9 -1 3 -1
```

**输出：**
```
10
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$最优的方法是：
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 1 步：使用跳跃 3 的卡牌，从 0 跳到 3 ，获得 3 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 2 步：使用跳跃 1 的卡牌，从 3 跳到 4 ，获得 4 枚金币，共有 7 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 3 步：使用跳跃 4 的卡牌，从 4 跳到 8 ，获得 3 枚金币，共有 10 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 4 步：使用跳跃 2 的卡牌，从 8 跳到 0 ，获得 -1 枚金币，共有 9 枚金币。
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 5 步：使用跳跃 2 的卡牌，从 0 跳到 2 ，获得 2 枚金币，共有 11 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 6 步：使用跳跃 1 的卡牌，从 2 跳到 3 ，获得 0 枚金币（不是第一次到达），共有 11 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 7 步：使用跳跃 4 的卡牌，从 3 跳到 7 ，获得 -1 枚金币，共有 10 枚金币；
$\,\,\,\,\,\,\,\,\,\,\,\,\,\,\,$● 第 8 步：使用跳跃 3 的卡牌，从 7 跳到 0 ，获得 0 枚金币（不是第一次到达），共有 10 枚金币。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705992/detail?pid=60928816&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705992/detail?pid=60928816&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:19:07.283769+00:00', '2026-07-04T03:19:31.096243+00:00', 2000, 262144, '算法'),
	(340, '小苯的美丽区间', '小苯的美丽区间', '阿里', 'Medium', 'intervals', '小苯认为一个数 $x$ 是美丽数，当且仅当：如果将 $x$ 不停除以 $2$，直到 $x$ 不整除 $2$ 时停止，此时 $x$ 恰好等于 $1$。

如果一个数美丽，则其美丽值为：以上操作中除以 $2$ 的次数。

否则一个数不美丽，则其美丽值为 $0$。

现在小苯有一个长度为 $n$ 的数组 $a$，他想知道 $a$ 中所有连续子数组的和的美丽值之和是多少，请你帮他算一算吧。

形式化的：记数字 $x$ 的美丽值为 $f(x)$，则请你求出 $\sum_{l=1}^n\sum_{r=l}^n f(a_l+a_{l+1}+\dots+a_r)$。

（其中 $a_l+ a_{l+1}+\dots+a_r$ 表示 $a$ 数组在 $[l,r]$ 这一段区间的所有元素之和。）

## 输入格式

每个测试文件均包含多组测试数据。第一行输入一个整数 $T\left(1\leq T\leq 10^4 \right)$ 代表数据组数，每组测试数据描述如下：
第一行输入一个正整数 $n\ (1 \leq n \leq 3 \times 10^5)$，表示数组 $a$ 的长度。
第二行 $n$ 个正整数 $a_1\ a_2\dots a_n\ (0 \leq a_i < 2^{30})$，表示数组 $a$。
（保证同一个测试文件中的测试数据里，$n$ 的总和不超过 $3 \times 10^5$。）

## 输出格式

对于每个测试数据，在单独的一行输出一个整数表示答案。

## 样例

### 样例 1

**输入：**
```
2
5
2 4 4 3 5
4
2 2 2 2
```

**输出：**
```
15
13
```

**说明：**
对于第二组测试数据：$\{2,2,2,2\}$；
所有长度为 $1$ 的子区间和都是美丽的，因为 $2$ 的二进制中只有一个 $1$，其美丽值为 $1$，因此总美丽值为 $1 \times 4=4$；
所有长度为 $2$ 的子区间和都是美丽的，因为他们的和都是 $4$，$4$ 的美丽值为 $2$，其总美丽值为 $2 \times 3=6$。
所有长度为 $3$ 的子区间和都不是美丽的，因此美丽值总和为 $0$。
唯一一个长度为 $4$ 的子区间和是美丽的，其总和为 $8$，美丽值为 $3$；
综上，所有区间的总美丽值之和为：$4+6+0+3=13$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706047/detail?pid=62105698&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706047/detail?pid=62105698&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:20:38.850909+00:00', '2026-07-04T03:20:49.224100+00:00', 2000, 262144, '技术'),
	(346, '和为p点游戏', '和为p点游戏', '阿里', 'Medium', 'simulation', '一个骰子由六个面组成，每一个面上的数字分别是 $1,2,3,4,5,6$。投出骰子后，顶上面的数字即为投掷结果。可以视作投出每一个数字的概率都是相等的，为 $\tfrac{1}{6}$。

小歪有 $k$ 个骰子，每一轮他会投掷所有骰子，然后记录下所有骰子投掷结果的和。

小歪可以投掷若干轮，并累加投掷结果，他想知道，投掷任意多轮，总点数之和为 $p$ 的概率是多少。你需要将答案对 $(10^9+7)$ 取模后输出。

提示：本题中，在进行除法的取模时，即计算 $\left(p \times q^{-1} \bmod M\right)$，其中，$q^{-1}$ 可以使用公式 $\left(q^{M-2} \bmod M \right)$ 得到：例如，在计算 $\tfrac{5}{4} \bmod M$ 时，根据公式 $4^{-1} = \left(4^{M-2} \bmod M\right) = 250\,000\,002$，得到 $\left(p \times q^{-1} \bmod M\right) = 5 \times 250\,000\,002 \bmod M = 250\,000\,003$。

## 输入格式

第一行输入两个正整数 $k,p\left(1\leqq k, p \leqq 10^3\right)$ 代表骰子数量、目标点数。

## 输出格式

输出一个整数，代表小歪投出总点数之和为 $p$ 的概率。

可以证明答案可以表示为一个不可约分数 $\tfrac{p}{q}$，为了避免精度问题，请直接输出整数 $\left(p \cdot q^{-1} \bmod M\right)$ 作为答案，其中 $M = 10^9+7$ ，$q^{-1}$ 是满足 $q\times q^{-1} \equiv 1 \pmod{M}$ 的整数。
更具体地，你需要找到一个整数 $x \in [0, 10^9+7)$ 满足 $x \times q$ 对 $10^9+7$ 取模等于 $p$，您可以查看样例解释得到更具体的说明。

## 样例

### 样例 1

**输入：**
```
5 5
```

**输出：**
```
490869345
```

**说明：**
在这个样例中，唯一一种可以投掷出 $5$ 点的情况为，投掷一轮，且每一个骰子的点数均为 $1$，因此概率为 $\tfrac{1}{6^5}=\tfrac{1}{7776}$。
我们可以找到，$490\,869\,345 \times 7776 = 3\,817\,000\,026\,720$，对 $M$ 取模后为 $1$。所以输出即为 $490\,869\,345$。

### 样例 2

**输入：**
```
1 3
```

**输出：**
```
893518525
```

**说明：**
在这个样例中，有且仅有以下四种投掷方法：
投掷一轮，且投出 $3$ 点；
投掷两轮，第一轮投出 $1$ 点，第二轮投出 $2$ 点；
投掷两轮，第一轮投出 $2$ 点，第二轮投出 $1$ 点；
投掷三轮，第一轮投出 $1$ 点，第二轮投出 $1$ 点，第三轮投出 $1$ 点。
总概率为 $\tfrac{1}{6} + \tfrac{1}{6^2} + \tfrac{1}{6^2} + \tfrac{1}{6^3}$。

### 样例 3

**输入：**
```
2 3
```

**输出：**
```
55555556
```

**说明：**
在这个样例中，有且仅有以下两种投掷方法：
投掷一轮，第一个筛子投出 $1$ 点，第二个筛子投出 $2$ 点；
投掷一轮，第一个筛子投出 $2$ 点，第二个筛子投出 $1$ 点。
总概率为 $\tfrac{1}{6} + \tfrac{1}{6}$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706104/detail?pid=62105810&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706104/detail?pid=62105810&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:25:02.876512+00:00', '2026-07-04T03:25:13.752182+00:00', 2000, 262144, '算法'),
	(335, '小红的字符串修改', '小红的字符串修改', '阿里', 'Medium', 'string', '$\,\,\,\,\,\,\,\,\,\,$小红有一个由小写字母构成的字符串 $s$，每次她可以把其中一个任意一个字母替换成其在字母表中相邻的字母，例如把 ''$a$'' 替换成 ''$b$'' 或者 ''$z$''。现在小红想知道，最少需要替换多少次，使得 $s$ 成为 $t$ 的子串。

$\,\,\,\,\,\,\,\,\,\,$如果字符串 $t$ 可以通过从字符串 $s$ 的开头删除若干（可能为零或全部）字符以及从结尾删除若干（可能为零或全部）字符得到，则字符串 $t$ 是字符串 $s$ 的子串。

## 输入格式

$\,\,\,\,\,\,\,\,\,\,$第一行输入一个长度不超过 $10^3$ ，且仅由小写字母构成的字符串 $s$ 代表小红手中待替换的串。
$\,\,\,\,\,\,\,\,\,\,$第二行输入一个长度不小于 $s$ 但不超过 $10^3$ ，且仅由小写字母构成的字符串 $t$ 代表目标串。

## 输出格式

$\,\,\,\,\,\,\,\,\,\,$在一行上输出一个整数，代表最少需要替换的次数。

## 样例

### 样例 1

**输入：**
```
abc
abbc
```

**输出：**
```
1
```

**说明：**
$\,\,\,\,\,\,\,\,\,\,$需要进行一次替换，将 ''$\tt c$'' 替换成 ''$\tt b$'' ，此时得到 "$\tt abb$" ，是 "$\tt abbc$" 的子串，因为本质上是由 "$\tt abbc$" 末尾删除了一个字符得到的。

### 样例 2

**输入：**
```
zzzzzz
xyzabc
```

**输出：**
```
9
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705992/detail?pid=60928816&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705992/detail?pid=60928816&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:19:07.231484+00:00', '2026-07-04T03:19:40.249251+00:00', 2000, 262144, '算法'),
	(334, '小红的最大中位数', '小红的最大中位数', '阿里', 'Medium', 'simulation', '小红拿到了一个数组，她准备选择一个子序列，使得该子序列的中位数尽可能大。小红想知道，一共有多少种方案？

奇数长度的子序列中位数为中间的那个数，偶数长度的子序列中位数为中间两个数的平均数。

## 输入格式

第一行输入一个正整数$n$，代表数组大小、待选择的子序列长度。
第二行输入$n$个正整数$a_i$。代表小红拿到的数组。
$1\leq n \leq 10^5$
$1\leq a_i \leq 10^9$

## 输出格式

一个整数，代表选择的方案数。由于答案可能过大，请对$10^9+7$取模。

## 样例

### 样例 1

**输入：**
```
3
1 2 2
```

**输出：**
```
4
```

**说明：**
最大中位数为 2。
选一个 2 有两种方案，选两个 2 有一种方案，选三个数有一种方案。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705978/detail?pid=60164024&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705978/detail?pid=60164024&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:19:07.181339+00:00', '2026-07-04T03:19:49.795031+00:00', 2000, 262144, '算法'),
	(332, '小红的环形数组', '小红的环形数组', '阿里', 'Medium', 'string', '小红拿到了一个环形数组（第一个元素的左边是最后一个元素，最后一个元素的右边是第一个元素），她有若干次询问，每次查询从某元素开始，向左/向右前进$k$步后在什么位置。你能帮帮她吗？

## 输入格式

第一行输入两个正整数$n,q$，代表数组大小和询问次数。
第二行输入$n$个正整数$a_i$，代表数组的元素。
接下来的$q$行，每行输入三个参数$x,op,k$，其中$x$为一个正整数，代表初始的位置；$op$为一个字符''L''或者''R''，''L''代表向左走，''R''代表向右走；$k$代表走的步数。

$1\leq n,q \leq 10^5$
$1\leq x \leq n$
$1\leq k,a_i \leq 10^9$

## 输出格式

输出$q$行，每行输出一个正整数，代表每次查询，前进$k$步后所在的元素。

## 样例

### 样例 1

**输入：**
```
5 2
3 4 5 2 4
1 R 3
4 L 4
```

**输出：**
```
2
4
```

**说明：**
第一次询问，小红初始在第一个元素，向右走 3 步后到达第四个元素，是 2。
第二次询问，小红初始在第四个元素，向左走 4 步后到达第五个元素，是 4。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2024, 'https://www.nowcoder.com/exam/test/97705978/detail?pid=60164024&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97705978/detail?pid=60164024&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FcurrentTab%3Drecommand%26jobId%3D100%26tagIds%3D134&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:19:07.092310+00:00', '2026-07-04T03:20:12.484835+00:00', 2000, 262144, '算法'),
	(339, '小红的数组切割', '小红的数组切割', '阿里', 'Medium', 'string', '小红有一个长度为 $n$ 的数组 $a$ 和一个长度为 $n$ 的字符串 $s$。她最多可以将数组切割成 $k$ 块。

定义数组的权值为所有元素的权值之和。对于数组中的第 $i$ 个元素，其权值计算方式为：$op(i) \times (a_i + j)$

其中：

- $op(i)$ 的值取决于字符串 $s$ 的第 $i$ 个字符：

- 若 $s_i = ''1''$，则 $op(i) = 1$

- 若 $s_i = ''0''$，则 $op(i) = -1$

- $j$ 表示 $a_i$ 所在的块的编号（从 1 开始）

小红想要通过合理的切割方式，使得数组的总权值最大。请你帮她计算出可能的最大权值。

## 输入格式

第一行包含两个正整数 $n$ 和 $k$，表示数组的长度和数组最多的块数。
第二行包含 $n$ 个整数 $a_1, a_2, ..., a_n$，表示数组 $a$。
第三行包含一个长度为 $n$ 的字符串 $s$，仅由字符 ''0'' 和 ''1'' 组成。
$1 \leq k \leq n$

$2 \leq n \leq 10^5$
$1 \leq a_i \leq 10^9$

## 输出格式

输出一个整数，表示数组可能的最大权值。

## 样例

### 样例 1

**输入：**
```
4 2
1 2 3 4
1001
```

**输出：**
```
1
```

**说明：**
一种最优的切割方案是将数组切成 [1, 2, 3] 和 [4] 两块。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706047/detail?pid=62105698&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706047/detail?pid=62105698&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:20:38.790817+00:00', '2026-07-04T03:21:00.792733+00:00', 2000, 262144, '技术'),
	(338, '小红的相等数组', '小红的相等数组', '阿里', 'Medium', 'bit-manipulation', '小红希望你构造一个长度为 $n$ 的数组，满足：

1. 数组中的每个元素 $a_i$ 满足 $0 \leq a_i < 2^k$

2. 数组所有元素的异或和小于等于所有元素的与和。即 $a_1 \oplus a_2 \oplus \cdots \oplus a_n \leq a_1 \And a_2 \And \cdots \And a_n$

小红想知道有多少种可能的方案数。

## 输入格式

第一行输入两个整数 $n$ 和 $k$。
$1 \leq n \leq 10^5$
$0 \leq k \leq 10^5$

## 输出格式

输出一个整数，表示满足条件的数组的方案数。由于答案可能很大，请对 $10^9 + 7$ 取模。

## 样例

### 样例 1

**输入：**
```
2 2
```

**输出：**
```
6
```

**说明：**
一共有 $6$ 种可能的方案数。分别是 $[0,0], [1,1], [2,2], [3,3], [2,3], [3,2]$。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706047/detail?pid=62105698&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706047/detail?pid=62105698&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:20:38.731235+00:00', '2026-07-04T03:21:10.859434+00:00', 2000, 262144, '技术'),
	(341, '字符串和声！', '字符串和声！', '阿里', 'Medium', 'string', '小歪正在学习字符串和声，字符串仅由小写字母和连接线 $\texttt{`-''}$ 构成。我们使用竖线 $\texttt{`|''}$ 来划分小结，例如，$\texttt{|do-do-re|re---|}$ 代表两个小结，其中，第一个小结长度为 $8$ ，即 $\texttt{"do-do-re"}$；第二个小结长度为 $5$ ，即 $\texttt{"re---"}$。 

随后，我们定义字符串的和声为：字符串和声小节数量和各个小结的长度均与原字符串一致，唯一的区别是其会比原字符串晚 $p$ 个长度出现，和声未出现时使用下划线替代空白位置，小结结束时未输出完整的和声会被直接截断；更具体地，先在每一个小节前面加上 $p$ 条下划线，随后截取原来的小节的长度位，得到每一个小节的和声。例如，当 $p=2$ 时，第一小节变为 $\texttt{"__do-do-re"}$，再截取前 $8$ 位，得到第一小节的和声 $\texttt{"__do-do-"}$，上方样例的和声最终可以唯一地表示为 $\texttt{|__do-do-|__re-|}$。

现在，对于给出的字符串和整数 $p$，请你直接输出和声！

## 输入格式

第一行输入两个整数 $n,p \left( 1 \leqq n \leqq 3 \times 10^5;\ 0 \leqq p \leqq 10^9\right)$ 代表原字符串总长度（包括 $\texttt{|}$ 在内）和和声延迟的长度。
此后若干行，一共输入 $n$ 个字符，代表原字符串。保证每行的首末均为竖线（ $\texttt{|}$ ），每个小结的长度至少为 $1$ ，小结中的字符仅为小写字母和连接线（ $\texttt{-}$ ）。

## 输出格式

根据输入，输出若干行，代表和声字符串。

## 样例

### 样例 1

**输入：**
```
16 2
|do-do-re|re---|
```

**输出：**
```
|__do-do-|__re-|
```

**说明：**
这个样例已经在题面中加以解释。

### 样例 2

**输入：**
```
15 0
|ciallo|
|-|
|--|
```

**输出：**
```
|ciallo|
|-|
|--|
```

**说明：**
第一节和声：$\texttt{do-do-re}$ 变为$\texttt{__do-do-}$
第二节和声：$\texttt{mi---}$变为$\texttt{__mi-}$', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706084/detail?pid=62105713&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706084/detail?pid=62105713&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:23:02.928153+00:00', '2026-07-04T03:23:33.976179+00:00', 2000, 262144, '技术'),
	(343, '树的最大权值', '树的最大权值', '阿里', 'Easy', 'tree', '小红定义一棵树的权值为:

若一条简单路径 $u\rightarrow v$ 满足 $s_u+...+s_v$ 是一个回文串。在所有这样的路径中，路径的长度的最大值是是该树的权值。

现在小红给定一棵结点总数为 $n$ 的树和 ''a'',''b'',''c'',...,''z''每种字母的个数，保证所有个数之和恰好等于 $n$。

你需要将每个字母填入一个树的结点，使得该树的权值最大，输出树的最大权值。

## 输入格式

第一行输入一个长度为26的数组，表示每个字母的个数，保证总和为 $n$。

第二行输入一个整数 $n(1\leq n\leq 10^5)$，表示树的结点总数。

接下来 $n-1$ 行，每行输入两个整数 $u,v(1\leq u,v\leq n,u\neq v)$，表示树的一条边。

## 输出格式

输出一个整数，表示树的最大权值。

## 样例

### 样例 1

**输入：**
```
1 0 2 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0
5
1 2
2 3
3 4
4 5
```

**输出：**
```
3
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706084/detail?pid=62105713&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706084/detail?pid=62105713&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:23:03.018592+00:00', '2026-07-04T03:23:13.999383+00:00', 2000, 262144, '技术'),
	(342, '小红的二进制操作', '小红的二进制操作', '阿里', 'Medium', 'bit-manipulation', '小红拿到了一个数组，她可以进行最多两次操作：选择一个元素，使其加1。

小红希望操作结束后，数组所有元素乘积的二进制末尾有尽可能多的0。你能帮帮她吗？

## 输入格式

第一行输入一个正整数 $n$，代表数组的大小。
第二行输入 $n$ 个正整数 $a_i$，代表数组的元素。
$1 \leq n \leq 10^5$
$1 \leq a_i \leq 10^9$

## 输出格式

输出一个整数，代表操作结束后，数组所有元素乘积的二进制末尾0的数量。

## 样例

### 样例 1

**输入：**
```
5
1 2 3 4 5
```

**输出：**
```
6
```

**说明：**
操作两次后数组变为 [2, 2, 4, 4, 5]，数组乘积为 320，二进制表示为 101000000，有 6 个 0。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706084/detail?pid=62105713&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706084/detail?pid=62105713&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:23:02.973173+00:00', '2026-07-04T03:23:23.705881+00:00', 2000, 262144, '技术'),
	(345, '基于相关性分析的特征选择实现', '基于相关性分析的特征选择实现', '阿里', 'Medium', 'simulation', '你的团队正在研究哪些产品特征最能影响销售，以便优化产品策略。为此，你决定使用相关性分析来评估特征与销售量之间的关系，从而选择最有价值的特征。

请你编写一个程序，使用 Python 和 NumPy 库，对给定的数据集进行相关性分析。具体要求如下：

1. 读取输入数据集，包含 ( N ) 个样本，每个样本有 ( M ) 个特征和一个目标值（销售量）。

2. 计算每个特征与目标值之间的皮尔逊相关系数。

3. 按照相关系数的绝对值从大到小排序，选择前 ( K ) 个特征。

4. 输出每个特征的相关系数值，保留四位小数，使用{x:.4f}格式化输出。

## 输入格式

-  第一行包含两个整数 ( N ) 和 ( M )，表示样本数量和特征数量。
-  接下来的 ( N ) 行，每行包含 ( M+1 ) 个浮点数，表示每个样本的特征值和目标值，特征值和目标值之间用空格分隔。
-  最后一行包含一个整数 ( K )，表示需要选择的特征数量。

## 输出格式

-  输出 ( M ) 行，每行包含一个特征的索引（从 0 开始）和对应的相关系数值，用空格分隔，保留四位小数。
-  按照相关系数的绝对值从大到小排序输出。

## 样例

### 样例 1

**输入：**
```
5 3
1.0 2.0 3.0 10.0
2.0 3.0 4.0 12.0
3.0 4.0 5.0 14.0
4.0 5.0 6.0 16.0
5.0 6.0 7.0 18.0
2
```

**输出：**
```
0 1.0000
1 1.0000
2 1.0000
```

**说明：**
-  所有特征与目标值的相关系数均为 1.0000。
-  由于 ( K=2 )，但相关系数相同，因此输出了所有特征。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706104/detail?pid=62105810&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706104/detail?pid=62105810&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:25:02.810670+00:00', '2026-07-04T03:25:22.988215+00:00', 2000, 262144, '算法'),
	(344, '小红的纸牌游戏', '小红的纸牌游戏', '阿里', 'Medium', 'string', '小红和小紫玩纸牌游戏，一共有 $n$ 张纸牌，每张纸牌上有一个数字 $0$ 或 $1$。

小红和小紫轮流从牌堆中拿出一张牌，小红先手。游戏持续到牌堆中只剩下 $k$ 张牌为止。最后剩下的 $k$ 张牌按照从左到右的顺序组成一个二进制数。

小红的目标是使这个二进制数尽可能大，小紫的目标是使这个二进制数尽可能小。假设双方都采取最优策略，最后剩下的 $k$ 张牌组成的二进制数是多少？

## 输入格式

第一行输入两个整数 $n$ 和 $k$，分别表示初始纸牌数量和最后剩余的纸牌数量。
第二行输入一个长度为 $n$ 的字符串，仅包含字符 ''0'' 和 ''1''，表示每张纸牌上的数字。

$1 \leqq k < n \leqq 10^5$

## 输出格式

输出一个字符串，长度为 $k$，表示最后剩下的 $k$ 张牌组成的二进制数。

## 样例

### 样例 1

**输入：**
```
5 3
10110
```

**输出：**
```
110
```

**说明：**
初始状态下有 5 张牌：$[1,0,1,1,0]$，需要保留 3 张牌。

游戏过程：
1. 小红先手，为了使最终数字尽可能大，她会拿走从左到右第一个 0
2. 小紫为了使最终数字尽可能小，她会拿走最后一个 1

最后剩下的三张牌是 $[1,1,0]$，从左到右组成二进制数 "110"。

可以证明，在双方都采取最优策略的情况下，这是最终可能得到的结果。', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706104/detail?pid=62105810&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706104/detail?pid=62105810&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:25:02.764132+00:00', '2026-07-04T03:25:32.461808+00:00', 2000, 262144, '算法');
INSERT INTO public.problems VALUES
	(348, '移动-', '移动', '阿里', 'Medium', 'string', '小红在一维度的世界中，她可以向左或者向右移动。她拿到一个长度为 $n$ 的字符串 $s$，仅包含 ''<'' 和 ''>'' 两种字符，''<'' 表示向左移动，''>'' 表示向右移动。

小红想知道，如果从字符串 $s$ 的第 $i(0\leq i<n)$ 个字符开始，然后按照 $s_{i},s_{i+1},s_{i+2},...$ 的顺序依次移动，那么小红有没有机会回到原地。

值得注意的是，你需要对于任意的 $i(0\leq i<n)$ 都判断是否存在一种移动方式，使得小红可以回到原地且不一定需要执行到 $s_{n-1}$，每个 $i$ 的判断互不影响。

## 输入格式

第一行一个整数 $n(1\leq n\leq 2\times 10^5)$，表示字符串 $s$ 的长度。
第二行一个字符串 $s$，仅包含 ''<'' 和 ''>'' 两种字符。

## 输出格式

输出 $n$ 个整数，第 $i$ 个整数表示从第 $i$ 个字符开始移动，小红有没有机会回到原地，若有机会输出1，否则输出0。

## 样例

### 样例 1

**输入：**
```
4
><><
```

**输出：**
```
1 1 1 0
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706133/detail?pid=62105707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706133/detail?pid=62105707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:26:55.932775+00:00', '2026-07-04T03:27:17.654354+00:00', 2000, 262144, '技术'),
	(349, '小红的异或之和', '小红的异或之和', '阿里', 'Medium', 'matrix-grid', '小红有两个长度都为 $n$ 的数组 $a,b$ ，仅包含 $0、1$。

现在小红生成一个二维矩阵 $c$ ，满足 $c_{i,j}= a_i \oplus b_j$。

现在小红想让你帮助她计算出其所有子矩阵的数值之和,结果对 $10^9+7$ 取模。

## 输入格式

第一行一个整数 $n(1\leq n\leq 2\times 10^5)$，表示数组长度。

第二行 $n$ 个整数，第 $i$ 个整数为 $a_i(0\leq a_i\leq 1)$。

第二行 $n$ 个整数，第 $i$ 个整数为 $b_i(0\leq b_i\leq 1)$。

## 输出格式

一个整数，表示矩阵 $c$ 的所有子矩阵之和,结果对 $10^9+7$ 取模。

## 样例

### 样例 1

**输入：**
```
3
1 0 1
0 1 0
```

**输出：**
```
52
```', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706133/detail?pid=62105707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706133/detail?pid=62105707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:26:55.996824+00:00', '2026-07-04T03:27:08.395933+00:00', 2000, 262144, '技术'),
	(347, '小红的字符串匹配', '小红的字符串匹配', '阿里', 'Medium', 'string', '小红很喜欢字符串 $s$ ，如果字符串 $t$ 的某一个长度至少为 $k$ 的前缀或某一个长度至少为 $k$ 的后缀是 $s$ 的子串，那么小红也会喜欢字符串 $t$ 。

例如， $k=2$ 时，小红喜欢字符串 "hello" ，那么小红也喜欢字符串 "ciallo" 、 "he" ，因为 "ciallo" 的长度为 2 的后缀 "llo" ， "he" 的长度为 2 的前缀 "he" 都是 "hello" 的子串，但小红不喜欢字符串 "soyo" ，因为 "soyo" 的任何一个前缀、后缀都不是 "hello" 的子串。

小红有一个字符串喜欢的 $s$ ，她每次会问你，字符串 $t$ 她是否喜欢。

## 输入格式

第一行输入一个长度不超过 $10^5$ 的只由小写字母构成的字符串 $s$ 。

第二行输入两个正整数 $q(1 \leq q \leq 10^5),k(1 \leq k \leq 10)$ ，表示询问次数和长度限制。

接下来 $q$ 行，每行输入一个只由小写字母构成的字符串 $t$ 表示询问。

数据保证，所有的字符串 $t$ 的长度之和不超过 $10^5$ 。

## 输出格式

对每个询问输出一行，若小红喜欢字符串 $t$ ，输出 "YES" ，否则输出 "NO" 。

## 样例

### 样例 1

**输入：**
```
hello
3 2
ciallo
he
soyo
```

**输出：**
```
YES
YES
NO
```

**说明：**
如题目描述', '', '["\u672a\u5206\u7c7b"]', '[]', '["Python", "C++", "Java"]', '{"Python": "def solve() -> None:\n    pass", "C++": "#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    return 0;\n}", "Java": "public class Main {\n    public static void main(String[] args) {\n    }\n}"}', '牛客', '牛客', '中', 2025, 'https://www.nowcoder.com/exam/test/97706133/detail?pid=62105707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', 'https://www.nowcoder.com/exam/test/97706133/detail?pid=62105707&examPageSource=Company&subTabName=written_page&testCallback=https%3A%2F%2Fwww.nowcoder.com%2Fexam%2Fcompany%3FquestionJobId%3D10%26subTabName%3Dwritten_page&testclass=%E8%BD%AF%E4%BB%B6%E5%BC%80%E5%8F%91', '未开始', '2026-07-04T03:26:55.874659+00:00', '2026-07-04T03:27:27.830716+00:00', 2000, 262144, '技术');


--
-- Data for Name: problem_test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.problem_test_cases VALUES
	(174, 71, 'hidden', 'hidden
1 2 3', '0', 1),
	(175, 70, 'hidden', 'hidden
1 2 3', '0', 1),
	(176, 69, 'hidden', 'hidden
1 2 3', '0', 1),
	(177, 68, 'hidden', 'hidden
1 2 3', '0', 1),
	(178, 67, 'hidden', 'hidden
1 2 3', '0', 1),
	(179, 66, 'hidden', 'hidden
1 2 3', '0', 1),
	(180, 65, 'hidden', 'hidden
1 2 3', '0', 1),
	(307, 117, 'hidden', 'hidden
1 2 3', '0', 1),
	(311, 113, 'hidden', 'hidden
1 2 3', '0', 1),
	(315, 109, 'hidden', 'hidden
1 2 3', '0', 1),
	(76, 40, 'hidden', '5 6 2
2 3 1 30 1
0 0 0 0 0
4 5 2 50 1
0 0 0 0 1
0 0 0 0 0
35 40 1
35 70 0
35 60 1
25 80 0
28 10 1
50 45 1', '0.800000', 1),
	(77, 39, 'hidden', '4 6 2 3
1.00 1.00
0.95 0.95 2.0
1.10 1.00 2.0
0.90 1.10 1.0
0.80 0.90 1.0
2.00 2.00 3.0
1.30 1.40 1.0', '2 2', 1),
	(319, 105, 'hidden', 'hidden
1 2 3', '0', 1),
	(323, 101, 'hidden', 'hidden
1 2 3', '0', 1),
	(327, 97, 'hidden', 'hidden
1 2 3', '0', 1),
	(575, 222, 'hidden', '{1,2,3,4,#,#,5}', '3', 1),
	(579, 218, 'hidden', '{}', '[]', 1),
	(83, 41, 'hidden', 'hidden
1 2 3', '0', 1),
	(84, 42, 'hidden', '6 4 2 2
0.1 0.2 0.3 0.4 0.5 0.6', 'error', 1),
	(441, 185, 'hidden', 'hidden
1 2 3', '0', 1),
	(347, 153, 'hidden', 'hidden
1 2 3', '0', 1),
	(351, 149, 'hidden', 'hidden
1 2 3', '0', 1),
	(88, 44, 'hidden', '[10, 20], [3, 4]', '[]', 1),
	(89, 43, 'hidden', 'hidden
1 2 3', '0', 1),
	(355, 145, 'hidden', 'hidden
1 2 3', '0', 1),
	(720, 259, 'hidden', 'hidden
1 2 3', '0', 1),
	(92, 46, 'hidden', 'hidden
1 2 3', '0', 1),
	(93, 45, 'hidden', 'hidden
1 2 3', '0', 1),
	(724, 256, 'hidden', '7', '21', 1),
	(96, 48, 'hidden', 'hidden
1 2 3', '0', 1),
	(97, 47, 'hidden', 'hidden
1 2 3', '0', 1),
	(368, 164, 'hidden', 'hidden
1 2 3', '0', 1),
	(197, 96, 'hidden', 'hidden
1 2 3', '0', 1),
	(100, 50, 'hidden', 'hidden
1 2 3', '0', 1),
	(101, 49, 'hidden', 'hidden
1 2 3', '0', 1),
	(198, 95, 'hidden', 'hidden
1 2 3', '0', 1),
	(199, 94, 'hidden', 'hidden
1 2 3', '0', 1),
	(104, 52, 'hidden', 'hidden
1 2 3', '0', 1),
	(105, 51, 'hidden', 'hidden
1 2 3', '0', 1),
	(200, 93, 'hidden', '3
5 5 5
15 15 15
25 25 25
1
4
4 4 4
6 6 6
14 16 14
26 24 26', '5.00 5.00 5.00
14.00 16.00 14.00
26.00 24.00 26.00', 1),
	(201, 92, 'hidden', '4
3
5 8 3', '-1', 1),
	(202, 91, 'hidden', '3 0.5
1 ground 0.15 80.0
2 air 0.1 200.0 ground 0.3 90.0
2 air 0.05 180.0 ground 0.2 70.0', '350.00', 1),
	(109, 54, 'hidden', '10 3
0.5 0.3 0.4 0
0.6 0.2 0.5 0
0.4 0.3 0.3 0
0.7 0.4 0.6 0
2.1 2.3 2.2 1
2.3 2.2 2.4 1
2.2 2.4 2.3 1
4.5 4.3 4.4 2
4.4 4.5 4.6 2
4.6 4.4 4.5 2
2.2 2.1 2.3', '1', 1),
	(110, 53, 'hidden', 'hidden
1 2 3', '0', 1),
	(203, 90, 'hidden', '3 2
10.0 -5.0
0.0 8.0
-3.0 -3.0
2 2
4.0 -6.0
2.0 7.0', '29.84 -95.35
16.13 56.00
-18.05 -2.98', 1),
	(204, 89, 'hidden', 'aaaaaaa', '1', 1),
	(205, 88, 'hidden', 'hidden
1 2 3', '0', 1),
	(114, 56, 'hidden', '3 10 30
1.2 1.5
1.8 1.2
5.0 5.2
5.5 4.8
4.9 5.5
-2.0 3.0
-2.5 3.5
-1.8 2.8
1.5 1.8
5.2 5.0', '2502', 1),
	(115, 55, 'hidden', 'hidden
1 2 3', '0', 1),
	(206, 87, 'hidden', 'hidden
1 2 3', '0', 1);
INSERT INTO public.problem_test_cases VALUES
	(601, 239, 'hidden', '[1],0', '[]', 1),
	(119, 58, 'hidden', 'hidden
1 2 3', '0', 1),
	(120, 57, 'hidden', '3
1.0 1.0 2.0
2.0 2.0 4.0
3.0 3.0 6.0', '0.002750 0.002750 0.002923', 1),
	(738, 277, 'hidden', '["abc"]', '"abc"', 1),
	(892, 335, 'hidden', 'zzzzzz
xyzabc', '9', 1),
	(124, 61, 'hidden', 'hidden
1 2 3', '0', 1),
	(125, 60, 'hidden', 'hidden
1 2 3', '0', 1),
	(126, 59, 'hidden', 'hidden
1 2 3', '0', 1),
	(481, 209, 'hidden', '{}', '{}', 1),
	(485, 205, 'hidden', '[0],[6,3]', '{6,3}', 1),
	(489, 201, 'hidden', '{1},{}', '"null"', 1),
	(493, 197, 'hidden', '{},1', '{}', 1),
	(132, 64, 'hidden', '4 14 19 99
8 5 11 13 22 24 44
1 1 18
3 1 22
6 7 2 12 14 17 30 36 39', '-1', 1),
	(133, 63, 'hidden', '4 6
1 0 0 0
1 4
2 1
2 4
3 1
4 2
4 3', '-1', 1),
	(134, 62, 'hidden', 'hidden
1 2 3', '0', 1),
	(375, 158, 'hidden', 'hidden
1 2 3', '0', 1),
	(386, 168, 'hidden', 'hidden
1 2 3', '0', 1),
	(900, 339, 'hidden', 'hidden
1 2 3', '0', 1),
	(621, 245, 'hidden', '[1,2,3,3,2,9]', '[1,9]', 1),
	(512, 216, 'hidden', '"1.1","1.01"', '0', 1),
	(410, 180, 'hidden', 'hidden
1 2 3', '0', 1),
	(425, 191, 'hidden', 'hidden
1 2 3', '0', 1),
	(516, 212, 'hidden', '1,[[2]]', 'false', 1),
	(909, 341, 'hidden', '15 0
|ciallo|
|-|
|--|', '|ciallo|
|-|
|--|', 1),
	(764, 285, 'hidden', '[2,2,3,4,3]', '3', 1),
	(768, 281, 'hidden', '"ranko"', 'false', 1),
	(774, 289, 'hidden', '2,[[1,3],[2,4]]', '2', 1),
	(915, 346, 'hidden', '1 3', '893518525', 1),
	(643, 253, 'hidden', '2', '["(())","()()"]', 1),
	(647, 249, 'hidden', '[0,1]', '[[0,1],[1,0]]', 1),
	(429, 187, 'hidden', 'hidden
1 2 3', '0', 1),
	(923, 347, 'hidden', 'hidden
1 2 3', '0', 1),
	(784, 293, 'hidden', 'hidden
1 2 3', '0', 1),
	(564, 233, 'hidden', '{8,6,10,5,7,9,11}', '{8,6,10,5,7,9,11}', 1),
	(568, 229, 'hidden', '{1,2,3,4,5,6,7}', 'true', 1),
	(572, 225, 'hidden', '{8,6,9,5,7,7,5}', 'false', 1),
	(158, 86, 'hidden', 'hidden
1 2 3', '0', 1),
	(159, 85, 'hidden', 'hidden
1 2 3', '0', 1),
	(160, 84, 'hidden', 'hidden
1 2 3', '0', 1),
	(161, 83, 'hidden', 'hidden
1 2 3', '0', 1),
	(162, 82, 'hidden', 'hidden
1 2 3', '0', 1),
	(163, 81, 'hidden', 'hidden
1 2 3', '0', 1),
	(164, 80, 'hidden', 'hidden
1 2 3', '0', 1),
	(165, 79, 'hidden', 'hidden
1 2 3', '0', 1),
	(166, 78, 'hidden', 'hidden
1 2 3', '0', 1),
	(167, 77, 'hidden', 'hidden
1 2 3', '0', 1),
	(169, 76, 'hidden', 'hidden
1 2 3', '0', 1),
	(170, 75, 'hidden', 'hidden
1 2 3', '0', 1),
	(171, 74, 'hidden', 'hidden
1 2 3', '0', 1),
	(172, 73, 'hidden', 'hidden
1 2 3', '0', 1);
INSERT INTO public.problem_test_cases VALUES
	(173, 72, 'hidden', 'hidden
1 2 3', '0', 1),
	(804, 297, 'hidden', '4
1 1 2 1', '5', 1),
	(704, 274, 'hidden', '[5,4,3,2,1]', '0', 1),
	(708, 271, 'hidden', '[1,3,6]', '7', 1),
	(712, 267, 'hidden', '"1111"', '["1.1.1.1"]', 1),
	(716, 263, 'hidden', '[5,2,3],0', '0', 1),
	(576, 221, 'hidden', '{8,6,10,5,7,9,11}', '[[8],[10,6],[5,7,9,11]]', 1),
	(308, 116, 'hidden', 'hidden
1 2 3', '0', 1),
	(312, 112, 'hidden', 'hidden
1 2 3', '0', 1),
	(316, 108, 'hidden', 'hidden
1 2 3', '0', 1),
	(320, 104, 'hidden', 'hidden
1 2 3', '0', 1),
	(324, 100, 'hidden', 'hidden
1 2 3', '0', 1),
	(721, 258, 'hidden', '"abc","def"', '"-1"', 1),
	(725, 255, 'hidden', '1', '1', 1),
	(344, 156, 'hidden', 'hidden
1 2 3', '0', 1),
	(348, 152, 'hidden', 'hidden
1 2 3', '0', 1),
	(352, 148, 'hidden', 'hidden
1 2 3', '0', 1),
	(356, 144, 'hidden', '3x=6', '2', 1),
	(598, 242, 'hidden', '"(2*(3-4))*5"', '-10', 1),
	(602, 238, 'hidden', '[9,10,9,-7,-3,8,2,-6],5', '[10,10,9,8]', 1),
	(739, 276, 'hidden', '"nowcoder",8', '"NOWCODER"', 1),
	(372, 161, 'hidden', '20
-6 -9 -90 -73 89 -90 2 19 52 -16 -41 -22 85 24 -22 66 75 78 48 -36', '134', 1),
	(376, 157, 'hidden', 'hidden
1 2 3', '0', 1),
	(893, 334, 'hidden', 'hidden
1 2 3', '0', 1),
	(387, 167, 'hidden', 'hidden
1 2 3', '0', 1),
	(618, 247, 'hidden', '[-2,0,1,1,2]', '[[-2,0,2],[-2,1,1]]', 1),
	(482, 208, 'hidden', '{1,4,6,3,7}', '{1,6,7,4,3}', 1),
	(486, 204, 'hidden', '{1},{2,3},{}', '{}', 1),
	(490, 200, 'hidden', '{1},-1', 'false', 1),
	(407, 183, 'hidden', '20
-6 -9 -90 -73 89 -90 2 19 52 -16 -41 -22 85 24 -22 66 75 78 48 -36', '134', 1),
	(411, 179, 'hidden', 'hidden
1 2 3', '0', 1),
	(414, 176, 'hidden', '6 2
aAbBcC
1 a b
2 B C', 'AAbbcc', 1),
	(494, 195, 'hidden', '{}', '{}', 1),
	(622, 244, 'hidden', '[3,3,3,3,2,2,2]', '3', 1),
	(901, 338, 'hidden', 'hidden
1 2 3', '0', 1),
	(426, 190, 'hidden', 'hidden
1 2 3', '0', 1),
	(430, 186, 'hidden', '5
9 6 3 5 4
1 2
1 3
3 4
4 5', '0 1 1 1 2', 1),
	(513, 215, 'hidden', '[3,100,200,3]', '3', 1),
	(517, 211, 'hidden', '[],3', '-1', 1),
	(765, 284, 'hidden', '""', '""', 1),
	(769, 280, 'hidden', '[1,2,3],[2,5,6]', '[1,2,2,3,5,6]', 1),
	(775, 288, 'hidden', '[1,1,1]', '3', 1),
	(785, 292, 'hidden', 'hidden
1 2 3', '0', 1),
	(644, 252, 'hidden', '8', '92', 1),
	(648, 248, 'hidden', '[1]', '[[1]]', 1),
	(561, 235, 'hidden', 'hidden
1 2 3', '0', 1),
	(565, 232, 'hidden', '{3,5,1,6,2,0,8,#,#,7,4},2,7', '2', 1),
	(569, 228, 'hidden', '{2,1,3}', 'true', 1),
	(573, 224, 'hidden', '{5,4,#,3,#,2,#,1}', 'From left to right are:1,2,3,4,5;From right to left are:5,4,3,2,1;', 1),
	(916, 345, 'hidden', 'hidden
1 2 3', '0', 1);
INSERT INTO public.problem_test_cases VALUES
	(805, 296, 'hidden', '2 2', '7.00', 1),
	(705, 273, 'hidden', '[2,4,1]', '2', 1),
	(709, 270, 'hidden', '"(())"', '4', 1),
	(717, 262, 'hidden', '"31717126241541717"', '192', 1),
	(837, 322, 'hidden', 'hidden
1 2 3', '0', 1),
	(840, 319, 'hidden', '2 2 1 1 0', '12', 1),
	(843, 316, 'hidden', 'hidden
1 2 3', '0', 1),
	(846, 313, 'hidden', '1000 500 4 2', '1000 500', 1),
	(849, 310, 'hidden', 'hidden
1 2 3', '0', 1),
	(852, 307, 'hidden', 'hidden
1 2 3', '0', 1),
	(855, 304, 'hidden', 'hidden
1 2 3', '0', 1),
	(858, 301, 'hidden', 'hidden
1 2 3', '0', 1),
	(864, 324, 'hidden', 'hidden
1 2 3', '0', 1),
	(877, 330, 'hidden', 'hidden
1 2 3', '0', 1),
	(880, 327, 'hidden', 'hidden
1 2 3', '0', 1),
	(577, 220, 'hidden', '{1,2,3,4,#,#,5}', '[[1],[2,3],[4,5]]', 1),
	(309, 115, 'hidden', 'hidden
1 2 3', '0', 1),
	(313, 111, 'hidden', 'hidden
1 2 3', '0', 1),
	(317, 107, 'hidden', 'hidden
1 2 3', '0', 1),
	(321, 103, 'hidden', 'hidden
1 2 3', '0', 1),
	(325, 99, 'hidden', 'hidden
1 2 3', '0', 1),
	(722, 266, 'hidden', '"abbba"', '5', 1),
	(890, 337, 'hidden', 'hidden
1 2 3', '0', 1),
	(894, 333, 'hidden', 'hidden
1 2 3', '0', 1),
	(345, 155, 'hidden', 'hidden
1 2 3', '0', 1),
	(349, 151, 'hidden', 'hidden
1 2 3', '0', 1),
	(353, 147, 'hidden', 'hidden
1 2 3', '0', 1),
	(357, 143, 'hidden', 'hidden
1 2 3', '0', 1),
	(599, 241, 'hidden', '[1,1,1]', '"1.00 1.00 1.00 "', 1),
	(603, 237, 'hidden', '"[]"', 'true', 1),
	(370, 163, 'hidden', 'hidden
1 2 3', '0', 1),
	(373, 160, 'hidden', 'hidden
1 2 3', '0', 1),
	(736, 279, 'hidden', '"114514",""', '"114514"', 1),
	(384, 170, 'hidden', 'hidden
1 2 3', '0', 1),
	(388, 166, 'hidden', 'hidden
1 2 3', '0', 1),
	(623, 243, 'hidden', '[20,70,110,150],90', '[1,2]', 1),
	(907, 343, 'hidden', 'hidden
1 2 3', '0', 1),
	(479, 196, 'hidden', '{5},1,1', '{5}', 1),
	(483, 207, 'hidden', '{2,1}', 'false', 1),
	(408, 182, 'hidden', 'hidden
1 2 3', '0', 1),
	(412, 178, 'hidden', '3
1 2
2 3
BBB', '3', 1),
	(487, 203, 'hidden', 'hidden
1 2 3', '0', 1),
	(491, 199, 'hidden', '[{1,2},{1,4,5},{6}]', '{1,1,2,4,5,6}', 1),
	(762, 287, 'hidden', '[4,5,1,3,2]', '2', 1),
	(766, 283, 'hidden', '"abcAbA","AA"', '"AbA"', 1),
	(427, 189, 'hidden', 'hidden
1 2 3', '0', 1),
	(645, 251, 'hidden', '"aab"', '["aab","aba","baa"]', 1),
	(917, 344, 'hidden', 'hidden
1 2 3', '0', 1),
	(921, 349, 'hidden', 'hidden
1 2 3', '0', 1),
	(514, 214, 'hidden', '[1,2,3]', '0', 1);
INSERT INTO public.problem_test_cases VALUES
	(786, 291, 'hidden', '[]', '[]', 1),
	(802, 299, 'hidden', 'hidden
1', '0', 1),
	(562, 217, 'hidden', 'hidden
1 2 3', '0', 1),
	(566, 231, 'hidden', '{7,1,12,0,4,11,14,#,#,3,5},12,11', '12', 1),
	(570, 227, 'hidden', '{}', '{}', 1),
	(574, 223, 'hidden', '{1,2},0', 'false', 1),
	(806, 295, 'hidden', '20
11111000111011101100', '94', 1),
	(706, 272, 'hidden', '[1,3,6]', '6', 1),
	(710, 269, 'hidden', '"aad","c*a*d"', 'true', 1),
	(714, 265, 'hidden', '[2]', '2', 1),
	(718, 261, 'hidden', '[[1,2,3],[1,2,3]]', '7', 1),
	(838, 321, 'hidden', 'hidden
1 2 3', '0', 1),
	(841, 318, 'hidden', 'hidden
1 2 3', '0', 1),
	(844, 315, 'hidden', 'hidden
1 2 3', '0', 1),
	(847, 312, 'hidden', 'hidden
1 2 3', '0', 1),
	(850, 309, 'hidden', 'hidden
1 2 3', '0', 1),
	(853, 306, 'hidden', 'hidden
1 2 3', '0', 1),
	(856, 303, 'hidden', 'hidden
1 2 3', '0', 1),
	(859, 300, 'hidden', 'hidden
1 2 3', '0', 1),
	(865, 323, 'hidden', 'hidden
1 2 3', '0', 1),
	(878, 329, 'hidden', '6 2
1 1 4 5 1 4', '7', 1),
	(881, 326, 'hidden', '5
1 3 2 2 5', '10', 1),
	(310, 114, 'hidden', 'hidden
1 2 3', '0', 1),
	(314, 110, 'hidden', 'hidden
1 2 3', '0', 1),
	(318, 106, 'hidden', 'hidden
1 2 3', '0', 1),
	(322, 102, 'hidden', 'hidden
1 2 3', '0', 1),
	(326, 98, 'hidden', 'hidden
1 2 3', '0', 1),
	(578, 219, 'hidden', '{1}', '[1]', 1),
	(723, 257, 'hidden', '[1,100,1,1,1,90,1,1,80,1]', '6', 1),
	(737, 278, 'hidden', '"2001:0db8:85a3:0:0:8A2E:0370:7334"', '"IPv6"', 1),
	(346, 154, 'hidden', 'hidden
1 2 3', '0', 1),
	(350, 150, 'hidden', 'hidden
1 2 3', '0', 1),
	(354, 146, 'hidden', 'hidden
1 2 3', '0', 1),
	(358, 142, 'hidden', 'hidden
1 2 3', '0', 1),
	(891, 336, 'hidden', '10 2
-1 -1 2 3 4 -9 -9 -1 3 -1', '10', 1),
	(895, 332, 'hidden', 'hidden
1 2 3', '0', 1),
	(371, 162, 'hidden', 'hidden
1 2 3', '0', 1),
	(374, 159, 'hidden', 'hidden
1 2 3', '0', 1),
	(600, 240, 'hidden', '[10,10,9,9,8,7,5,6,4,3,4,2],12,3', '9', 1),
	(604, 236, 'hidden', '["PSH2","POP","PSH1","POP"]', '2,1', 1),
	(385, 169, 'hidden', 'hidden
1 2 3', '0', 1),
	(389, 165, 'hidden', '4 5', '1', 1),
	(899, 340, 'hidden', 'hidden
1 2 3', '0', 1),
	(480, 210, 'hidden', '{}', '{}', 1),
	(484, 206, 'hidden', '[-1,0,-2]', '{-2,-1,0}', 1),
	(488, 202, 'hidden', '{2},8', '{}', 1),
	(492, 198, 'hidden', '{},{}', '{}', 1),
	(409, 181, 'hidden', 'hidden
1 2 3', '0', 1),
	(413, 177, 'hidden', 'hidden
1 2 3', '0', 1),
	(908, 342, 'hidden', 'hidden
1 2 3', '0', 1);
INSERT INTO public.problem_test_cases VALUES
	(282, 141, 'hidden', '2
testcase10
testcase9', 'testcase9
testcase10', 1),
	(283, 140, 'hidden', '3
-3 4 -2
-3 2', '5', 1),
	(620, 246, 'hidden', '[-2,3,4,1,5]', '2', 1),
	(285, 139, 'hidden', '11 3
2 3 4 5 5 6 7 7 9 16 17
2 0
2 1
0 7', '3 1
5 2
2 2', 1),
	(286, 138, 'hidden', '5 4 3 2 1', '1', 1),
	(287, 137, 'hidden', '5
1 3 2 3 1', '2', 1),
	(288, 136, 'hidden', '12
7 5 4 3 2 1 1 9 8 7 7 10
4
0 10 11 6', '3', 1),
	(289, 135, 'hidden', '7
0 100 1 300 2 10 0', '-1 -1', 1),
	(290, 134, 'hidden', '4
1 1 1 2 3 4
2 2 5 6 7 8
3 3 9 10 11 12
4 2 13 14 15 16', '1 2 3
1 4 3', 1),
	(291, 133, 'hidden', '8 4
1 1 1 0 1 1 1 1
1 0 1 0 1 1 0 1
1 1 1 0 1 1 1 1
0 0 1 0 0 1 1 1', '2', 1),
	(292, 132, 'hidden', '2 2
1 2
3 4', '4', 1),
	(293, 131, 'hidden', '3 3
0 0 0
1 1 1
0 0 0
0 0
2 2
2', '-1', 1),
	(294, 130, 'hidden', '3 1
0 0', '-1', 1),
	(295, 129, 'hidden', '1 1
-10', '10', 1),
	(296, 128, 'hidden', '3 3
1 0 0
0 3 1
1 0 2
0 0 2 0
2 2', '-1', 1),
	(297, 127, 'hidden', '1 1 1 2', 'null', 1),
	(298, 126, 'hidden', '3
2 3 1
4', '-1', 1),
	(299, 125, 'hidden', 'buy red running shoes online!|red shoes|buy shoes running|shoes black|Phone', '1.0000|1.4000|0.0750|0.0000', 1),
	(300, 124, 'hidden', '1 1 2
1 10
1 20', '-1', 1),
	(301, 123, 'hidden', '4
1 2 4 8', '-1', 1),
	(302, 122, 'hidden', '1
80
100 300', '-1', 1),
	(303, 121, 'hidden', 'hidden
1 2 3', '0', 1),
	(304, 120, 'hidden', 'hidden
1 2 3', '0', 1),
	(305, 119, 'hidden', 'hidden
1 2 3', '0', 1),
	(306, 118, 'hidden', 'hidden
1 2 3', '0', 1),
	(428, 188, 'hidden', 'hidden
1 2 3', '0', 1),
	(432, 184, 'hidden', '4 5', '1', 1),
	(642, 254, 'hidden', '[[1,2],[4,3]]', '4', 1),
	(515, 213, 'hidden', '[1,2,3,1]', '2', 1),
	(763, 286, 'hidden', '[2,2]', '2', 1),
	(767, 282, 'hidden', '[[0,10],[10,20]]', '[[0,20]]', 1),
	(922, 348, 'hidden', 'hidden
1 2 3', '0', 1),
	(646, 250, 'hidden', '[[0]]', '0', 1),
	(783, 294, 'hidden', 'hidden
1 2 3', '0', 1),
	(787, 290, 'hidden', '4,0,[1,2,3,4]', '[1,2,3,4]', 1),
	(563, 234, 'hidden', '[1],[1]', '{1}', 1),
	(567, 230, 'hidden', '{}', 'true', 1),
	(571, 226, 'hidden', '{1},{}', '{1}', 1),
	(803, 298, 'hidden', '3
#*#
.**
*.#', '3 0', 1),
	(703, 275, 'hidden', '[9,8,4,1]', '0', 1),
	(711, 268, 'hidden', '"intention","execution"', '5', 1),
	(715, 264, 'hidden', 'hidden
1 2 3', '0', 1),
	(719, 260, 'hidden', '2,2', '2', 1),
	(839, 320, 'hidden', 'hidden
1 2 3', '0', 1),
	(842, 317, 'hidden', 'hidden
1 2 3', '0', 1),
	(845, 314, 'hidden', 'hidden
1 2 3', '0', 1),
	(848, 311, 'hidden', '5 2', '1 2
1 3
1 4
1 5
2 3
2 4
2 5
3 4
3 5
4 5', 1),
	(851, 308, 'hidden', 'hidden
1 2 3', '0', 1),
	(854, 305, 'hidden', 'hidden
1 2 3', '0', 1),
	(857, 302, 'hidden', '3 2', '1', 1);
INSERT INTO public.problem_test_cases VALUES
	(863, 325, 'hidden', 'hidden
1 2 3', '0', 1),
	(876, 331, 'hidden', '5
1 2 3 4 5', '3', 1),
	(879, 328, 'hidden', 'hidden
1 2 3', '0', 1);


--
-- Name: problem_test_cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.problem_test_cases_id_seq', 923, true);


--
-- Name: problems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.problems_id_seq', 349, true);


--
-- PostgreSQL database dump complete
--

\unrestrict COn5shxpzFn4If9hhKfzitB6z6ywY6GZtmsBP4SIgqsDKkO4p7pqbAJmVKB0YyO

