---
title: "算法笔记"
date: "2022-08-01T08:14:47+08:00"
draft: false
layout: post
description: "算法笔记"
author: "Wenhao Jiang"
tags:
    - Algorithm
URL: "/2022-08-01/algorithm-notes"
--- 

# 前缀和
> https://oi-wiki.org/basic/prefix-sum

- 数据预处理
- 降低时间复杂度
- 数列前n项的和

## 思路
### 一维
```
recurrence:

B[0] = A[0],对于i>=1,则B[i] = B[i-1] + A[i]
```

### 二维/多维
- 容斥原理
>https://zh.m.wikipedia.org/zh-hans/%E6%8E%92%E5%AE%B9%E5%8E%9F%E7%90%86

$$\left|\bigcap_{i=1}^{n}S_i\right|=\sum_{m=1}^n(-1)^{m-1}\sum_{a_i<a_{i+1}}\left|\bigcap_{i=1}^mS_{a_i}\right|$$

不定方程非负整数解计数

# 排列组合
> https://oi-wiki.org/math/combinatorics/combination/
## 排列数

$$\mathrm A_n^m = n(n-1)(n-2) \cdots (n-m+1) = \frac{n!}{(n-m)!}$$

## 组合数

$$ \mathrm C_n^m = \frac{\mathrm A_n^m}{m!} = \frac{n!}{m!(n-m)!}$$

组合数也被称为「二项式系数」,$\displaystyle \binom{n}{m}$ 读作「n选m」

$$\displaystyle \mathrm C_n^m = \binom{n}{m}$$

特别地,规定当m > n时, $\mathrm A_n^m = \mathrm C_n^m = 0$


# 单调栈

