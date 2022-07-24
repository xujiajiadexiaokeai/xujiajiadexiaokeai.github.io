---
title: leetcode日记
date: "2022-07-22T02:52:47+08:00"
discription: "具体开始时间不可考, 那就从今天开始吧!"
draft: true
layout: post
author: "Wenhao Jiang"
tags:
    - leetcode
URL: "/leetcode-diary"

---

# 2022-07-24
## 移除元素
## 设置数字容器系统
## 重塑矩阵
## 公交站间的距离
## 全0子数组的数目

# 2022-07-23
## 最好的扑克手牌

# 2022-07-22
## 买卖股票的最佳时机II
### tag
- DP

## 买卖股票的最佳时机
### tag
- 贪心


## 打家劫舍III
> https://leetcode.cn/problems/house-robber-iii/solution/si-chong-xie-fa-di-gui-ji-yi-hua-di-gui-shu-xing-d/
### tag
- 递归
- 记忆化递归
- 树型DP

### 实现
```go
/**
 * Definition for a binary tree node.
 * type TreeNode struct {
 *     Val int
 *     Left *TreeNode
 *     Right *TreeNode
 * }
 */
func rob(root *TreeNode) int {
    if root == nil {
        return 0
    }

    money := root.Val
    if root.Left != nil {
        money = money + rob(root.Left.Left) + rob(root.Left.Right)
    }
    if root.Right != nil {
        money = money + rob(root.Right.Left) + rob(root.Right.Right)
    }
    return max(money, rob(root.Left) + rob(root.Right))
}

func max(a, b int) int {
    if a > b {
        return a
    } else {
        return b
    }
}
```

```go
/**
 * Definition for a binary tree node.
 * type TreeNode struct {
 *     Val int
 *     Left *TreeNode
 *     Right *TreeNode
 * }
 */
func rob(root *TreeNode) int {
    m := make(map[*TreeNode]int)
    return myRob(root, m)
}

func myRob(root *TreeNode, m map[*TreeNode]int) int {
    if root == nil {
        return 0
    }
    v, exist := m[root]
    if exist {
        // fmt.Println(v)
        return v
    }
    money := root.Val
    if root.Left != nil {
        money = money + myRob(root.Left.Left, m) + myRob(root.Left.Right, m)
    }
    if root.Right != nil {
        money = money + myRob(root.Right.Left, m) + myRob(root.Right.Right, m)
    }
    m[root] = max(money, myRob(root.Left, m) + myRob(root.Right, m))
    return m[root]
}


func max(a, b int) int {
    if a > b {
        return a
    } else {
        return b
    }
}
```

```go
/**
 * Definition for a binary tree node.
 * type TreeNode struct {
 *     Val int
 *     Left *TreeNode
 *     Right *TreeNode
 * }
 */
func rob(root *TreeNode) int {
    ans := myRob(root)
    return max(ans[0], ans[1])
   
}
func myRob(root *TreeNode) []int {
    if root == nil {
        return []int{0,0}
    }
    ans := make([]int, 2)
    /**
     * 先make后赋值的影响?
     * left := make([]int, 2) 
     * right := make([]int, 2)
     * left = myRob(root.Left)
     * right = myRob(root.Right)
     */
    left := myRob(root.Left)
    right := myRob(root.Right)
    ans[0] = max(left[0], left[1]) + max(right[0], right[1])
    ans[1] = left[0] + right[0] + root.Val
    return ans
}


func max(a, b int) int {
    if a > b {
        return a
    } else {
        return b
    }
}
```




# 2022-07-21
## 二叉树剪枝
## 二叉树的所有路径
## 打家劫舍
## 打家劫舍II
