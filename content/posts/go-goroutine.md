---
date: 2022-07-13T10:16:17+08:00
draft: false
url: "/2022-07-13/go-goroutine"
layout: post
description: "Go Memory"
author: "Wenhao Jiang"
tags:
    - Go
title: "Goroutine"
---

# 基本概念
1. 进程
- 进程是应用程序的启动实例
- 有独立的内存空间
- 不同进程通过进程间通信的方式进行通信

2. 线程
- 线程是cpu调度的基本单位
- 不同线程可以共享进程的资源
- 不同线程通过共享内存等线程间通信方式进行通信

3. 协程
- 协程调度由用户程序提供,不直接受操作系统调度
- 协程调度器按照调度策略把协程调度到线程中执行

# 协程的优势
过多的线程会导致上下文切换的开销变大,而工作在用户态的协程则能大大减少上下文切换的开销

协程调度器把可运行的协程逐个调度到线程中执行,同时及时把阻塞的协程调度出线程

有效地避免了线程的频繁切换

实现了使用少量线程实现高并发的效果

多个协程分享操作系统分给线程的时间片

协程调度器决定了协程运行的顺序

线程运行调度器指派的协程,每一时刻只能运行一个协程

# 调度模型
1. 线程模型
线程可分为用户线程和内核线程

用户线程由用户创建、同步合销毁

根据用户线程管理方式的不同,分为三种线程模型:
- N:1模型
N个用户线程运行在1个内核线程中,上下文切换较快
- 1:1模型
每个用户线程对应一个内核线程,上下文切换较慢
- M:N模型
充分利用cpu且上下文切换较快,但调度算法较为复杂

2. Go GPM模型

G: goroutine,Go协程,每个`go`关键字都会创建一个goroutine

P: processor,处理器(Go定义的一个概念,不是指cpu),包含运行Go代码的必要资源,也有调度goroutine的能力

M: machine,工作线程,由操作系统调度

M必须持有P才能运行代码
M会被系统调用阻塞

P的个数在程序启动时决定,默认等于CPU的核数,可以使用环境变量GOMAXPROCS或在程序中使用runtime.GOMAXPROCS()方法指定P的个数
```
export GOMAXPROC=80

runtime.GOMAXPROCS(80)
```

M的个数通常稍大于P的个数,因为除了运行Go代码,还有其他内置任务需要处理.

# 调度策略
1. 队列轮转
每个处理器P维护着一个协程G的队列, 处理器P依次将协程G调度到M中执行
P会周期性地查看全局队列中是否有G待运行,防止“饥饿”
全局队列中的G主要来自从系统调用中恢复的G


2. 系统调用

P的个数默认等于CPU的核数, 每个M必须持有一个P才能执行G
一般情况下M的个数略大于P,多出来的M将会在G产生系统调用时发挥作用

M池
当M运行的某个G产生系统调用时: // TODO

3. 工作量窃取
通过`go`关键字创建的协程通常会优先放到当前协程对应的多处理器队列中
可能有些协程自身会不断派生新协程,有些协程不会派生,导致多个P中维护的G队列是不均衡的

所以Go调度器提供了工作量窃取策略: 当某个P没有需要调度的协程时, 将从其他处理器中偷取协程

发生窃取前,会查询全局队列,如果全局队列中没有需要调度的协程,才会从其他P中偷取,一次偷一半

4. 抢占式调度
避免某个协程长时间执行,而阻碍其他协程被调度的机制

调度器会监控每个协程的执行时间, 一旦执行时间过程且有其他协程在等待时,会把当前协程暂停,转而调度等待的协程,类似`时间片轮转`

