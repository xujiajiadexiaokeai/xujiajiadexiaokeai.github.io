---
title: "Go Channel"
date: 2022-07-12T21:12:06+08:00
draft: false
url: "/2022-07-12/go-channel"
layout: post
description: "Go channel"
author: "Wenhao Jiang"
tags:
    - Go
---

读写nil管道均会阻塞
关闭的管道仍然可以读取数据
向关闭的管道写数据会触发panic

只有一个缓冲区的管道,写入数据 —> 加锁; 读出数据 -> 解锁
# 特性
## 初始化
- 变量声明
```go
var ch chan int declare chan, value == nil
```

- make()
```go
ch1 := make(chan string) no-buffered chan
ch2 := make(chan string, 5) buffered chan
```

## 管道操作
- 操作符: <- ->
默认为双向可读写,在函数传递间可使用操作符限制读写
```go
func ChanParamR(ch <-chan int) {
    only can read from chan
}
func ChanParamW(ch chan<- int) {
    only can write to chan
}
```

- 数据读写
协程读取管道时,阻塞的条件有:
- chan no-buffer
- chan buffer no data
- chan value == nil
协程写入管道时,阻塞的条件有:
- chan no-buffer
- chan buffer is full
- chan value == nil

# 实现原理
## 数据结构
> https://cs.opensource.google/go/go/+/refs/tags/go1.18.3:src/runtime/chan.go
```go
type hchan struct {
	qcount   uint           // total data in the queue
	dataqsiz uint           // size of the circular queue
	buf      unsafe.Pointer // points to an array of dataqsiz elements
	elemsize uint16
	closed   uint32
	elemtype *_type // element type
	sendx    uint   // send index
	recvx    uint   // receive index
	recvq    waitq  // list of recv waiters
	sendq    waitq  // list of send waiters

	// lock protects all fields in hchan, as well as several
	// fields in sudogs blocked on this channel.
	//
	// Do not change another G's status while holding this lock
	// (in particular, do not ready a G), as this can deadlock
	// with stack shrinking.
	lock mutex
}
```

1. 环形队列
chan内部实现了一个环形队列,队列长度在chan创建时指定
sendx: 队尾, 写入位
recvx: 队首, 读取位

2. 等待队列
- goroutine从chan读 -> buf为空或没有buf -> 当前goroutine阻塞 -> 加入recvq
- goroutine向chan写 -> buf已满或没有buf -> 当前goroutine阻塞 -> 加入sendq
处于等待队列中的协程会在其他协程操作管道时被唤醒:
- 因读阻塞的协程会被向管道写入的协程唤醒
- 因写阻塞的协程会被从管道读取的协程唤醒
```
Invariants:
 At least one of c.sendq and c.recvq is empty,
 except for the case of an unbuffered channel with a single goroutine
 blocked on it for both sending and receiving using a select statement,
 in which case the length of c.sendq and c.recvq is limited only by the
 size of the select statement.

For buffered channels, also:
 c.qcount > 0 implies that c.recvq is empty.
 c.qcount < c.dataqsiz implies that c.sendq is empty.
```

3. 类型信息
- 一个管道只能传递一种类型的值
- 如果需要管道传递任意类型的数据,可以使用interface{}类型

4. 互斥锁
一个管道同时仅允许被一个协程读写

## 管道操作
1. 创建管道
创建管道 -> 初始化hchan结构
2. 写入管道
trick:
当接收队列recvq不为空时,说明缓冲区中没有数据但有协程在等待数据
会把数据直接传递给recvq队列中的第一个协程,而不必再写入缓冲区

3. 读出管道
trick:
当等待发送队列sendq不为空,且没有缓冲区,
那么此时将直接从sendq队列的第一个协程中获取数据

4. 关闭管道
关闭管道时会把recvq中的协程全部唤醒, 协程会获取对应类型的零值
同时会把sendq队列中的协程全部唤醒,协程会触发panic

会触发panic的操作还有:
- 关闭值为nil的管道
- 关闭已经被关闭的管道
- 向已经关闭的管道写入数据

## 常见用法
- 单向管道

- select
使用select可以监控多个管道
select的case语句读管道时不会阻塞

- for-range
for-range可以持续从管道中读出数据,当管道中没有数据时会阻塞当前协程
