---
title: "Dynamo"
date: 2021-10-26T13:52:30+08:00
layout: post
description: "Dynamo"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - distributed-system
URL: "/2021-10-26/dynamo"
---
Dynamo is a peer-to-peer system can quickly find the key by DHT(distributed hash table) 

为了保证能最快速的定位到key，所以在每个node中都保存了整个集群的信息，在客户端也保存了集群信息，可以将请求直接打到目标node

zero-hop (零跳)

# 一致性哈希的优点：

node join or exit，only effect the adjacent nodes in the same hash ring

接着考虑到每个node的Heterogeneous(异构性)、处理能力不同，于是加入了virtual nodes（虚拟结点）的概念

尽量做到每个虚拟节点的处理能力一致

起初一致性哈希是为了解决新加入节点和退出节点对数据的影响最小，但是由于数据分布的不均匀，热点数据，节点能力的异构都会造成分布不均匀，于是加入的virtual nodes，但是为了同一份数据的replicas分布在不同的物理机器上，配置virtual也会造成一定的困难。

# 一致性和复制

## replicate：

the node that performs data replication is called coordinator

负责存储key的node被称为preference list

## coordinator

coordinator进行复制的时候，是异步进行的，（可尽快给用户返回），所以Dynamo是一个弱一致系统

## NRW: 

可自定义R和W的数量，但要满足 R + W > N

### W(W<=N):

一个写操作只有成功更新了W个副本，才会被任务操作成功

### R(R<=N):

一个读操作需要读的副本数量

### R + W > N

能够保证读操作和写操作有节点交集：至少有一个节点会被读操作和写操作同时操作到

通过调整R和W能实现available和consistency之间的转换

### W小R大

writes never fail -> high availability

### R小W大

block for all replicas to be readable -> strong consistency

每个node都记录自己的操作记录，通过向量时钟能够记录同一对象不同版本间的因果关系

当节点接收到更新 -> 逐相对比本地向量钟和待更新数据的向量钟

如果待更新向量钟的每一项都不小于本地向量钟，那么数据无冲突，新的值可以接受。

Dynamo并不会贸然假定数据的冲突合并准则，而是保留全部的冲突数据，等待客户端处理。

# 容错

Dynamo将异常分为两种：

- 临时性

- 永久性

## 临时性故障：

针对临时性故障，其处理策略就是仲裁(quorum)，但是如果严格执行仲裁策略，会影响Dynamo的可用性，因为需要等到N个节点都执行了，才能返回，此时如果其中一个结点故障了，会影响可用性。

于是Dynamo采用了Sloppy Quorum策略，只需要N个healthy node即可

Sloppy Quorum：

如果某台机器故障了，则顺延将数据写入到后面的健康机器，并标注数据为hinted handoff，当机器恢复后，将数据进行回传

## 永久性故障：

针对永久性故障，其处理策略是Merkle Hash Tree.

### Merkle Hash Tree:

非叶子结点对应多个文件，值是其所有子节点值结合以后的哈希值；

叶子节点对应单个数据文件，值是文件内容的哈希

通过对比Merkle树，就能找出不同的文件了

# 成员资格及错误检测

所有的node中都保存了集群中所有node的路由信息，这导致了有新节点加入或者节点退出的时候，需要将这消息传递给集群内的所有人，使用了gossip协议

# 总体特点

- 最终一致性

- 即使故障也保障可写

- 允许写冲突，由上层应用自行解决



