---
title: "蓄水池抽样算法"
date: 2022-07-04T03:06:30+08:00
layout: post
description: ""
author: "Wenhao Jiang"
draft: true
tags:
    - Algorithm
URL: "/2022-07-04/red-black-tree"
---
# 蓄水池抽样算法

> https://www.jianshu.com/p/7a9ea6ece2af

## 问题描述

给定一个数据流,数据流长度N很大,且N不可知.如何在只遍历一遍数据(O(N))的情况下,随机选出m个不重复的数据

1. 数据流长度N很大且不可知,所以不能一次性塞入内存
2. 时间复杂度为O(N)
3. 随机选取m个数,每个数被选中的概率为m/N

## 核心代码及原理

```go
    reservoir := make([]int, m)

    // init
    for i := 0; i < len(reservoir); i++ {
        reservoir[i] = dataStream[i]
    }

    for i := m; i < len(dataStream); i++ {
        // 随机获得一个[0, i]内的随机整数
        d := rand.Intn(i + 1)
        // 如果随机整数落在[0, m-1]范围内, 则替换蓄水池中的元素
        if d < m {
            reservoir[d] = dataStream[i]
        }
    }
```

注: 这里使用已知长度的数组dataStream来表示未知长度的数据流,并假设数据流长度大于蓄水池容量m

原理

1. 如果接收的数据量小于m, 则依次放入蓄水池
2. 当接收到第i个数据时, i >= m, 在[0, i]范围内取以随机数d, 若d落在[0, m-1]的范围内, 则用接收到的第i个数据替换蓄水池中的第d个数据
3. 重复步骤2

当处理完所有的数据时, 蓄水池中国呢的每个数据都是以m/N的概率获得的


### 分布式蓄水池抽样(Distributed/Parallel Reservoir Sampling)

1. 假设有k台机器, 将大数据集分成K个数据流, 每台机器使用单机版蓄水池抽样处理一个数据流, 抽样m个数据,并最后记录处理的数据量为N1, N2, ...Nk(假设m<Nk),N1+N2+...+Nk=N.
2. 取[1, N]一个随机数d, 若d<N1,则在第一台机器的蓄水池中等概率不放回地(1/m)选取1个数据;若N1<=d<(N1+N2),则在第二台机器的蓄水池中等概率不放回地选取一个数据;以此类推,重复m次,则最终从总量N的数据集中选出m个数据.

m/N的概率验证如下:
1. 第k台机器中的蓄水池数据被选取的概率为m/Nk
2. 从第k台机器的蓄水池中选取一个数据放进最终蓄水池的概率为Nk/N
3. 第k台机器蓄水池的一个数据被选中的概率为1/m
4. 重复m次选取,则每个数据被选中的概率为m*(m/Nk*Nk/N*1/m)=m/N

## 算法验证