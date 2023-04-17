---
date: 2023-04-16T09:30:14+08:00
draft: true
url: "/2023-04-16/scheduler-system-design"
layout: post
description: "[Note] Scheduler System Design"
author: "Wenhao Jiang"
tags:
    - Scheduler
    - OS
    - Go
    - Kubernetes
title: "[Note] Scheduler System Design"
---
# Scheduler System Design

## 调度目的

## 调度原理

- 协作式调度与抢占式调度
- 单调度器与多调度器
- 工作分享与工作窃取

### 协作式与抢占式

- 协作式 Cooperative

  协作式调度允许任务执行任意长的时间,直到任务主动通知调度器让出资源

- 抢占式 Preemptive

  抢占式调度允许任务在执行过程中被调度器挂起,调度器会重新决定下一个运行的任务

任务的执行时间和任务上下午切换的额外开销决定了哪种调度方式会带来更好的性能

### 单调度器与多调度器

### 工作分享与工作窃取

- 工作分享 Work Sharing

  当调度器创建了新任务时,它会将一部分任务分给其他调度器

- 工作窃取 Work Stealing

  当调度器的资源没有被充分利用时,它会从其他调度器窃取一些待分配的任务

- 开销

  两种分配策略都会增加额外的开销,工作窃取引入的额外开销更小一些,只会在当前调度器的资源没有被充分利用时触发

## 架构设计

### 调度器内部

- 状态模块
  - 收集信息
  - 为调度提供上下文
- 决策模块
  - Queue Sort: 根据上下文确定调度顺序
  - Score: 通过过滤和打分为任务选择合适的资源
  - Preemption: 不存在满足条件的资源时,选择牺牲的抢占对象

### 调度器外部

- 多调度器

- 反调度器

  根据当前的状态移除错误的调度决策

## 操作系统中的调度器

### 调度系统类型

- 长期调度器
  - 决定任务是否进入准备队列
  - 授权或者延迟Work的执行
  - 平衡I/O密集型或者CPU密集型Work的数量
  - 最大化利用操作系统的资源
- 中期调度器
  - 为其他Work释放资源
- 短期调度器
  - 从就绪队列中选出一个Work执行
  - 使用特定的调度算法

### 设计与演进

## Go语言

运行时调度器 Runtime Scheduler

通信顺序进程(CSP) Communicating Sequential Processes

### 设计与演进

- 单进程调度器
- 多线程调度器
- 任务窃取调度器
- 抢占式调度器
  - 基于协作的抢占式调度器
  - 基于信号的抢占式调度器
- 非均匀存储访问调度器

## Kubernetes

### 设计与演进

- 谓词和优先级算法

  - 基于谓词和优先级的调度器 Predicates and Priorities
    - Scheduler Extender
    - MapReduce-like Scheduler Priority
    - Move scheduler code out of plugin directory

  - 基于调度框架的调度器

- 调度框架 Scheduling Framework

## Source
- [调度系统设计精要 - Draveness](https://draveness.me/system-design-scheduler/)