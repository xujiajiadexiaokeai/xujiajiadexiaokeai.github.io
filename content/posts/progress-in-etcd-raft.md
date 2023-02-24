---
title: "[译]Progress in etcd"
date: 2021-10-28T15:00:30+08:00
layout: post
description: "Progress in etcd"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - etcd
    - distributed-system
URL: "/2021-10-28/progress-in-etcd"
---

> From etcd Raft Design Doc

Progress是etcd中leader保存的所有follower的progress的视图

Leader维护着所有follower的progress，并根据follower的progress向follower发送 `replication message` 

`replication message` 是带着log entries信息的`msgAppend` 消息

progress有两个属性： `match` 和 `next` 

`match` 是leader对该follower已确定日志(entry)中最高的index，如果leader对这个follower的日志复制情况(replication status)一无所知，`match` 则会被设置为0

`next` 是leader将要发送给该follower的第一条日志(entry)的index,leader会将从`next` 开始到最新的entries放到下一条`replication message` 中

一个follower的progress会处于以下三种状态： `probe` , `replicate` ,`snapshot` 

```text
                            +--------------------------------------------------------+          
                            |                  send snapshot                         |          
                            |                                                        |          
                  +---------+----------+                                  +----------v---------+
              +--->       probe        |                                  |      snapshot      |
              |   |  max inflight = 1  <----------------------------------+  max inflight = 0  |
              |   +---------+----------+                                  +--------------------+
              |             |            1. snapshot success                                    
              |             |               (next=snapshot.index + 1)                           
              |             |            2. snapshot failure                                    
              |             |               (no change)                                         
              |             |            3. receives msgAppResp(rej=false&&index>lastsnap.index)
              |             |               (match=m.index,next=match+1)                        
receives msgAppResp(rej=true)                                                                   
(next=match+1)|             |                                                                   
              |             |                                                                   
              |             |                                                                   
              |             |   receives msgAppResp(rej=false&&index>match)                     
              |             |   (match=m.index,next=match+1)                                    
              |             |                                                                   
              |             |                                                                   
              |             |                                                                   
              |   +---------v----------+                                                        
              |   |     replicate      |                                                        
              +---+  max inflight = n  |                                                        
                  +--------------------+                                                        

```

`probe` ：当follower处于待调查(probe)状态时，leader在一次心跳间隔(heartbeat interval)内最多向该follower发送一条`replication message`  。leader慢慢向follower发送`replication message` 并试探follower的实际复制进展(actual progress)。leader在收到`msgHeartbeatResp` 或者`msgAppResp` 的拒绝消息后会触发下一条`replication message` 的发送。

`replicate` ：当follower处于复制(replicate)状态时，leader在向该follower发送`replication message` 时，会乐观地(optimistically)将`next` 增加至最新的index。这是一个最优的状态(optimized state)，可以快速的将日志(log entries)复制给follower。

`snapshot` ：当follower处于快照(snapshot)状态时，leader会停止向该follower发送`replication message` 

# 状态流转

一个新选出的leader，会将所有follower的state设置为`probe` 状态，`match` 设置为0，`next` 设置为自己最新的index。之后leader会缓慢的向各个follower发送`replication message` (一次心跳最多一条)去试探他们的日志复制进展。

在收到follower`reject` 为`false` 的`msgAppResp` 时，会将该follower的progress设置为`replicate` 状态，这表明发送的index已经和follower目前的index匹配上了，可以进行后续日志快速的发送。当follower回复一条reject的`msgAppResp` 或者连接层(link layer) 报告follower不可连接时，该follower的progress会回到`probe` 状态。我们积极地将`next` 重置为`match` +1，因为如果我们很快收到任何`msgAppResp` ，`match` 和`next` 将直接增加到`msgAppResp` 中的index。（如果将`next` 设置过低，我们可能会发送一些重复条目。请参阅开放性问题）

当follower远远落后并且需要快照(snapshot)时，该follower将从`probe` 状态更改为`snapshot` 状态。发送`msgSnap` 后，leader将等待上一个快照发送成功、失败或中止。应用发送结果后，该follower的progress将返回到`probe` 状态。

# 流转控制

限制每条message发送的message最大大小。最大值应该是可配置的。降低探测状态的成本，因为我们限制每条消息的大小；如果下一步的罚分过低，则降低罚分

当处于复制状态时，限制飞行中消息的数量 < N N应该是可配置的。大多数实现将在其实际网络传输层（不阻塞raft节点）的顶部有一个发送缓冲区。我们希望确保raft不会使缓冲区溢出，这可能会导致消息丢失并触发大量不必要的重复重发。

