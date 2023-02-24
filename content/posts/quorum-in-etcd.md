---
title: "Quorum in etcd"
date: 2021-10-12T22:44:30+08:00
layout: post
description: "Quorum in etcd"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - etcd
    - distributed-system
URL: "/2021-10-12/quorum-in-etcd"
---

# CAP
一致性(Consistency)、可用性(Availability)、分区容错性(Partition tolerance)

# WARO
(Write All Read One)一种简单的副本控制协议。当Client请求向某副本写数据时,只有当所有的副本都更新成功后,才算写成功,否则都视为失败。

WARO牺牲了更新服务的可用性,最大程度增强了读服务的可用性

# Quorum
一种权衡机制, 一种将“读写转化”的模型

quorum是“抽屉原理”的一个应用。定义:假设有N个副本,更新操作wi在W个副本中更新成功后,才认为此次更新操作wi成功。称成功提交的更新操作对应的数据为“成功提交的数据”。对于读操作而言,至少需要读R个副本才能读到此次更新的数据。其中,W+R>N,即W和R有重叠。一般W+R=N+1

## Quorum机制分析

**Quorum机制无法保证强一致性**

如何读取最新的数据:在已经知道最近成功提交的数据版本号的前提下,最多读R个副本就可以了

如何确定 最高版本号 的数据是一个成功提交的数据: 继续读其他副本,直到读到了 W 次

基于Quorum机制选primary

中心节点读取R个副本,选择R个副本中版本号最高的副本作为新的Primary。

新选出的primary不能立即提供服务,还需要与至少W个副本完成同步后,才能提供服务  -----> 为了保证Quorum的规则: W+R > N

### 如何处理冲突？

(V2,V2,V1,V1,V1) R = 3 

如果读取的是(V1,V1,V1),则V2需要丢弃

如果是(V2,V1,V1),则V1需要同步到V2



## Quorum 在etcd中的应用

Quorum在etcd中主要作用有两个,一个是计算已被多数节点接收(Match)的Index,二是在进行Leader选举时,计算选举结果。

raft/quorum/quorum.go













