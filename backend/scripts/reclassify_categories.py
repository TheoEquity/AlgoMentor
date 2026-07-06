#!/usr/bin/env python3
"""保守重分类：仅对 simulation 题目做重新判断，强证据才改。"""
import sys, os, re
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))
from core.db import get_connection

SLUGS = [
    'two-pointers', 'sliding-window', 'hashing', 'binary-search', 'prefix-sum',
    'intervals', 'matrix-grid', 'linked-list', 'stack-queue', 'monotonic-stack',
    'heap-priority-queue', 'tree', 'graphs', 'backtracking', 'dynamic-programming',
    'greedy', 'bit-manipulation', 'simulation', 'math', 'string',
]
NAME_MAP: dict[str, str] = {
    'two-pointers': 'Two Pointers', 'sliding-window': 'Sliding Window',
    'hashing': 'Hashing', 'binary-search': 'Binary Search', 'prefix-sum': 'Prefix Sum',
    'intervals': 'Intervals', 'matrix-grid': 'Matrix Grid', 'linked-list': 'Linked List',
    'stack-queue': 'Stack Queue', 'monotonic-stack': 'Monotonic Stack',
    'heap-priority-queue': 'Heap Priority Queue', 'tree': 'Tree', 'graphs': 'Graphs',
    'backtracking': 'Backtracking', 'dynamic-programming': 'DP', 'greedy': 'Greedy',
    'bit-manipulation': 'Bit Manipulation', 'simulation': 'Simulation', 'math': '数学', 'string': 'String',
}


def classify(text: str, current_slug: str) -> str:
    """如果当前是 simulation，尝试找到更好的分类；否则保持不变。"""
    if current_slug not in ('simulation', 'string'):
        return current_slug  # 只重分 simulation 和 string

    t = text.lower()

    # ==== ML/AI 类 → math ====
    ml_pat = (
        r'(K\-?Means|KNN|DBSCAN|聚类|线性回归|最小二乘|正规方程|线性模型|'
        r'损失函数|梯度下降|SVM|激活函数|神经网络|卷积核|卷积操作|LSTM|RNN|GRU|'
        r'机器学习|轮廓系数|决策树|ID3|CART|随机森林|XGBoost|逻辑回归|softmax|'
        r'分类器.*训练|二分类|多分类|Na[iï]ve Bayes|贝叶斯分类|'
        r'特征.*归一化|标准化|主成分|PCA|深度学习|ViT|patch.embed|'
        r'Masked Multi-Head|Multi-Head Attention|Self-Attention|'
        r'INT8.*量化|非对称量化|模型量化|剪枝|稀疏注意力|M[O0]E.*路由|'
        r'Token.*调度.*推理|大模型推理|语言模型.*预测|语言模型.*耗时|'
        r'PageRank|CLIP.*对比学习|对比学习|NGD优化|Logistic|'
        r'岭回归|多项式岭回归|拉格朗日乘数|HAC聚类|Anchor.*优化)'
    )
    if re.search(ml_pat, text, re.IGNORECASE):
        return 'math'

    # ==== 数学类 → math ====
    math_pat = (
        r'(质数|素数|质因数|最大公约数|最小公倍数|GCD|LCM|'
        r'排列组合|组合数|概率|期望|数论|'
        r'几何|三角形|矩形面积|最小外接圆|坐标系|行列式|'
        r'取模|模\s*\d|同余|费马|欧拉|'
        r'完全平方数|因子|'
        r'水仙花数|蛇形数|斐波那契)'
    )
    if re.search(math_pat, text):
        return 'math'

    # ==== DP → dynamic-programming ====
    dp_pat = (
        r'(动态规划|状态转移|最优子结构|记忆化|'
        r'01.*背包|完全背包|多重背包|背包问题|背包容量|'
        r'最长公共子序列|最长递增子序列|最长上升子序列|编辑距离|'
        r'打家劫舍|买卖股票|跳台阶|爬楼梯|'
        r'\bdp\[|DP\[)'
    )
    if re.search(dp_pat, text):
        return 'dynamic-programming'

    # ==== 图论 → graphs ====
    graph_pat = (
        r'(拓扑排序|最短路径|Dijkstra|Bellman|SPFA|Floyd|'
        r'并查集|Union Find|最小生成树|MST|强连通|连通分量|二分图|'
        r'邻接矩阵|邻接表|有向图|无向图|入度|出度|'
        r'网络流|最大流|关键路径|'
        r'岛屿数量|迷宫)'
    )
    if re.search(graph_pat, text):
        return 'graphs'

    # ==== 树 → tree ====
    tree_pat = (
        r'(二叉树|二叉搜索树|平衡二叉树|AVL|红黑树|'
        r'层序遍历|先序遍历|前序遍历|中序遍历|后序遍历|'
        r'前缀树|Trie|字典树|线段树|树状数组|Fenwick|'
        r'最近公共祖先|LCA|'
        r'叶子节点|根节点|子树|父节点|子节点|'
        r'二叉树的|树的直径|树的高度)'
    )
    if re.search(tree_pat, text):
        return 'tree'

    # ==== 回溯 → backtracking ====
    bt_pat = r'(回溯|全排列|N皇后|八皇后|解数独|括号生成)'
    if re.search(bt_pat, text):
        return 'backtracking'

    # ==== 贪心 → greedy ====
    greedy_pat = r'(贪心算法|贪心策略)'
    if re.search(greedy_pat, text):
        return 'greedy'

    # ==== 位运算 → bit-manipulation ====
    bit_pat = r'(位运算|异或|XOR|按位与|按位或|bitwise|位操作|二进制操作)'
    if re.search(bit_pat, text):
        return 'bit-manipulation'

    # ==== 二分 → binary-search ====
    bs_pat = r'(二分查找|二分答案|二分法|binary.search|折半查找)'
    if re.search(bs_pat, text):
        return 'binary-search'

    # ==== 双指针 → two-pointers ====
    tp_pat = r'(双指针|对撞指针|左右指针|快慢指针)'
    if re.search(tp_pat, text):
        return 'two-pointers'

    # ==== 滑动窗口 → sliding-window ====
    sw_pat = r'(滑动窗口|长度为\s*k\s*的子|长度为\s*K\s*的子)'
    if re.search(sw_pat, text):
        return 'sliding-window'

    # ==== 前缀和 → prefix-sum ====
    ps_pat = r'(前缀和|差分数组|prefix.sum)'
    if re.search(ps_pat, text):
        return 'prefix-sum'

    # ==== 堆 → heap-priority-queue ====
    heap_pat = r'(优先队列|大根堆|小根堆|大顶堆|小顶堆|最大堆|最小堆|topk|Top K)'
    if re.search(heap_pat, text):
        return 'heap-priority-queue'

    # ==== 单调栈 → monotonic-stack ====
    ms_pat = r'(单调栈|下一个更大|下一个更小|上一个更大|上一个更小)'
    if re.search(ms_pat, text):
        return 'monotonic-stack'

    # ==== 栈/队列 → stack-queue ====
    sq_pat = r'(括号匹配|表达式求值|后缀表达式|逆波兰|出栈|入栈|栈|堆栈|队列|双端队列|deque|单调队列)'
    if re.search(sq_pat, text):
        return 'stack-queue'

    # ==== 链表 → linked-list ====
    ll_pat = r'(链表|单链表|双向链表|反转链表|合并链表|环形链表)'
    if re.search(ll_pat, text):
        return 'linked-list'

    # ==== 区间 → intervals ====
    intv_pat = r'(合并区间|区间合并|重叠区间|区间调度)'
    if re.search(intv_pat, text):
        return 'intervals'

    # ==== 矩阵/网格 → matrix-grid ====
    mg_pat = r'(矩阵|网格|二维数组|棋盘|螺旋矩阵)'
    if re.search(mg_pat, text):
        return 'matrix-grid'

    # ==== 字符串 → string ====
    str_pat = r'(字符串|KMP|模式匹配|正则|回文串|字典序|子串|子序列|字符)'
    if re.search(str_pat, text):
        return 'string'

    # ==== 哈希 → hashing ====
    hash_pat = r'(哈希|hash|计数|频次|去重|出现次数|集合|set|字典|映射)'
    if re.search(hash_pat, text):
        return 'hashing'

    # 没匹配到 → 保持原样
    return current_slug


def main(dry_run: bool = True):
    conn = get_connection('postgresql://bytehunter:bytehunter123@localhost:5432/bytehunter')

    with conn.cursor() as cur:
        cur.execute("SELECT id, title, statement_markdown, category_slug FROM problems ORDER BY id")
        problems = [dict(r) for r in cur.fetchall()]

    changes: list[tuple[int, str, str, str]] = []
    stats_before: dict[str, int] = {}

    for p in problems:
        old = p['category_slug']
        stats_before[old] = stats_before.get(old, 0) + 1
        new = classify(p['statement_markdown'] or p['title'], old)
        if new != old:
            changes.append((p['id'], p['title'], old, new))

    print(f"总题数: {len(problems)}")
    print(f"变更数: {len(changes)}\n")

    for cid, title, old, new in changes:
        print(f"  #{cid:3d} | {title[:40]:40s} | {old:22s} -> {new}")

    stats_after: dict[str, int] = {}
    for p in problems:
        s = classify(p['statement_markdown'] or p['title'], p['category_slug'])
        stats_after[s] = stats_after.get(s, 0) + 1

    print(f"\n{'分类':25s} {'变更前':>6s} {'变更后':>6s} {'变化':>6s}")
    print("-" * 56)
    for slug in SLUGS:
        name = NAME_MAP.get(slug, slug)
        before = stats_before.get(slug, 0)
        after = stats_after.get(slug, 0)
        diff = after - before
        marker = f"+{diff}" if diff > 0 else str(diff)
        print(f"{name:25s} {before:6d} {after:6d} {marker:>6s}")

    if dry_run:
        print("\n[Dry Run] 使用 --apply 执行写入。")
        return

    if changes:
        with conn.cursor() as cur:
            for cid, _, _, new in changes:
                cur.execute("UPDATE problems SET category_slug = %s WHERE id = %s", (new, cid))
        conn.commit()
        print(f"\n已更新 {len(changes)} 道题目。")
    conn.close()


if __name__ == '__main__':
    main(dry_run='--apply' not in sys.argv)
