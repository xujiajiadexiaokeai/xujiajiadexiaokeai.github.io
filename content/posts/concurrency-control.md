---
title: "Concurrency Control"
date: 2021-12-03T21:55:30+08:00
layout: post
description: "并发控制-锁和MVCC"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - Concurrency
URL: "/2021-12-03/concurrency-control"
---

> 摘录自: https://draveness.me/database-concurrency-control/

# 并发控制机制

- Pessimistic
- Optimistic
- Multiversion

## 悲观并发控制-Pessimistic Concurrency Control

在悲观并发控制中,数据库程序对于数据被修改持悲观态度,在数据处理的过程中都会被锁定,以此来解决竞争问题

### 读写锁

为了最大化数据库事务的并发能力,数据库中的锁被设计为两种模式,分别是共享锁和互斥锁.

当一个事务获得共享锁之后,只可以进行读操作,所以共享锁也叫读锁

当一个事务获得一行数据的互斥锁时,就可以对该行数据进行读和写操作,所以互斥锁也叫写锁

共享锁和互斥锁出了限制事务能够执行的读写操作之外,它们之间还有共享和互斥的关系,也就是多个事务可以同时获得某一行数据的共享锁,但是互斥锁和共享锁和其他的互斥锁并不兼容,我们可以很自然地理解这么设计的原因: 多个事务同时写入同一数据难免会发生诡异的问题

如果当前事务没有办法获取该行数据对应的锁时就会陷入等待的状态,直到其他事务将当前数据对应的锁释放才可以获得锁并执行相应的操作

### 两阶段锁协议

两阶段锁协议(2PL)是一种能够保证事务可串行化的协议,它将事务的获取锁和释放锁划分成了增长(Growing)和缩减(Shrinking)两个不同的阶段

在增长阶段,一个事务可以获得锁但不能释放锁;在缩减阶段,事务只能释放锁,不能获得锁

变种:

Strict 2PL: 事务持有的互斥锁必须在提交后再释放

Rigorous 2PL: 事务持有的所有锁必须在提交后再释放

问题:

两阶段锁的使用带来了另一个问题-死锁

### 死锁的处理

解决死锁大体上有两种方法:

- 从源头杜绝死锁的产生和出现

- 允许系统进入死锁的状态,但是在系统出现死锁时能够及时发现并且进行恢复

**预防死锁**

- 保证事务之间的等待不会出现环 有向无环图
- 抢占加事务回滚 时间戳
  - wait-die
  - wound-wait

### 死锁检测和恢复
**死锁检测**
检测有向图中是否出现环

**死锁恢复**

- Victim
- Rollback
- Starvation

### 锁的粒度
- 显式 explicit
- 隐式 implicit
- 意向共享锁
- 意向互斥锁

## 乐观并发控制-Optimistic Concurrency Control
### 基于时间戳的协议
保证事务并行执行的顺序与事务按照时间戳串行执行的效果完全相同

每一个数据项都有两个时间戳: 读时间戳和写时间戳

该协议能够保证所有冲突的读写从左都能按照时间戳的大小串行执行

### 基于验证的协议
根据事务的只读或者更新将所有事务的执行分为两到三个阶段:
- Read Phase
- Validation Phase
- Write Phase


## 多版本并发控制- Multi-Version Concurrency Control
每一个写操作都会创建一个新版本的数据, 读操作会从有限多个版本的数据中挑选最合适的版本返回