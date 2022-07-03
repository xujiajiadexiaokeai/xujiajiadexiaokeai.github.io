---
title: "AVLTree"
layout: post
description: 一种平衡二叉树.
date: 2022-03-25T20:32:48+08:00
draft: false
tags:
    - Test
    - Data Structure
url: /2022-03-25/avl-tree
---
# 特征
· 左右子树的高度差小于等于1

· 每一个子树均为平衡二叉树



# 原理

## 监督机制

### 监督指标: 

**平衡因子**(Balance Factor): 某个节点的左子树高度-右子树高度的差值

所以AVL树是一种所有节点的平衡因子的绝对值都不超过1的二叉树



### 高度

```go
type Node struct {
	Data    int
	Height  int
	left    *Node
	right   *Node
}  
```

计算节点高度

```go
func (n *Node) TreeHeight() int {
	if n == nil {
		return 0
	} else {
		return max(treeHeight(n.left), treeHeight(n.right)) + 1
	}
}
```

在进行如下操作时,需要更新受影响的所有节点的高度

1. 在插入节点时, 沿插入的路径更新节点的高度值

1. 在删除节点时, 沿删除的路径更新节点的高度值

计算平衡因子

```go
func (n *Node) treeBalanceFactor() {
	if n == nil {
		return 0
	} else {
		return x.left.height - x.right.height
	}
}
```

## 再平衡

左旋和右旋

在整个平衡化过程可能进行一次或多次,从失去平衡的最小子树根节点开始

右旋: 

```go
func (n *Node) treeRotateRight() {
}
```

左旋

```go
func (n *Node) treeRotateLeft() {
}
```

### 需要平衡的四种情况

1. LL

![](https://tcs.teambition.net/storage/312g482677e05394fcde6d8d0ff8553342f9?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY0ODgxNTcxMSwiaWF0IjoxNjQ4MjEwOTExLCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmc0ODI2NzdlMDUzOTRmY2RlNmQ4ZDBmZjg1NTMzNDJmOSJ9.KVRPdEsaV4Vj5BLRVmHR3h0wpKwsW_zMh-s8HUdt3aU&download=image.png "")

2. RR



3. LR

![](https://tcs.teambition.net/storage/312g335de979fb780cfd8a48c2348c1cc61f?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY0ODgxNTcxMSwiaWF0IjoxNjQ4MjEwOTExLCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmczMzVkZTk3OWZiNzgwY2ZkOGE0OGMyMzQ4YzFjYzYxZiJ9.88VeeegnYTUu9r94DBtMln21URc3Dus40r0lOQyvM6U&download=image.png "")

4. RL

