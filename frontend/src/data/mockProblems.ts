export type ProblemRow = {
  id: string
  title: string
  company: string
  department: string
  difficulty: 'Easy' | 'Medium' | 'Hard'
  tags: string[]
  status: 'AC' | 'WA' | 'Review'
  updatedAt: string
}

export const mockProblems: ProblemRow[] = [
  {
    id: 'BH-001',
    title: '数组划分后的最大差值',
    company: '字节跳动',
    department: '广告算法',
    difficulty: 'Medium',
    tags: ['双指针', '贪心'],
    status: 'AC',
    updatedAt: '今天 09:12',
  },
  {
    id: 'BH-014',
    title: '括号序列的最短修复',
    company: '腾讯',
    department: '微信后台',
    difficulty: 'Easy',
    tags: ['栈', '字符串'],
    status: 'WA',
    updatedAt: '昨天 21:48',
  },
  {
    id: 'BH-027',
    title: '区间合并后的最小代价',
    company: '阿里巴巴',
    department: '淘天技术',
    difficulty: 'Hard',
    tags: ['DP', '前缀和'],
    status: 'Review',
    updatedAt: '昨天 18:05',
  },
  {
    id: 'BH-031',
    title: '日志流中的热词窗口',
    company: '美团',
    department: '推荐平台',
    difficulty: 'Medium',
    tags: ['滑动窗口', '哈希'],
    status: 'Review',
    updatedAt: '周日 16:20',
  },
]
