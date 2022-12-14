---
date: 2022-08-20T09:20:17+08:00
draft: false
url: "/2022-08-20/consistent-hashing"
layout: post
description: "一致性哈希"
author: "Wenhao Jiang"
tags:
    - Algorithm
title: "一致性哈希"
---

> https://www.zsythink.net/archives/1182
问题1：当缓存服务器数量发生变化时，会引起缓存的雪崩，可能会引起整体系统压力过大而崩溃（大量缓存同一时间失效）。

问题2：当缓存服务器数量发生变化时，几乎所有缓存的位置都会发生改变，怎样才能尽量减少受影响的缓存呢？

# 优点
- 服务器数量发生改变, 并不是所有缓存都会失效,是部分失效

# 问题
- 哈希环倾斜, 数据分配不均

# 解决方案
- 虚拟节点

# 优化
- 如果缓存服务器间性能存在较大差异,可考虑容器化? 均匀分配数据处理能力

# sample实现
> https://www.cnblogs.com/luxiaoxun/p/12573742.html

# Chord环
> https://zhuanlan.zhihu.com/p/129049724
1. Napster
- 使用中心服务器接收所有查询
- 问题: 中心服务器单点失效导致整个网络瘫痪
2. Gnutella
- 使用消息洪泛(message flooding)来定位数据
- 使用TTL来限制网络内转发消息的数量
- 问题: 消息数与节点数成线性关系,网络负载较重
3. SN
- SN保存网络中节点的索引信息,有多个SN

## Chord算法
### 实现原理
### 资源定位
### 查询步骤
### 路由表维护