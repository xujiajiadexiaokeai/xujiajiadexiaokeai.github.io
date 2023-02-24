---
title: "Linux Network Notes"
date: 2021-10-16T15:51:30+08:00
layout: post
description: "Linux Network Notes"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - Network
URL: "/2021-10-16/linux-network-notes"
---
### I/O模型

阻塞I/O Blocking I/O

非阻塞I/O Nonblocking I/O

Linux 下,我们可以通过 `fcntl` 系统调用来设置 `O_NONBLOCK` 标志位,从而把 socket 设置成 Non-blocking。

当用户进程发出 read 操作时,如果 kernel 中的数据还没有准备好,那么它并不会 block 用户进程,而是立刻返回一个 EAGAIN error。从用户进程角度讲 ,它发起一个 read 操作后,并不需要等待,而是马上就得到了一个结果。用户进程判断结果是一个 error 时,它就知道数据还没有准备好,于是它可以再次发送 read 操作。一旦 kernel 中的数据准备好了,并且又再次收到了用户进程的 system call,那么它马上就将数据拷贝到了用户内存,然后返回。

**所以,Non-blocking I/O 的特点是用户进程需要不断的主动询问 kernel 数据好了没有**

### I/O多路复用 I/O multiplexing

I/O多路复用就是 select/poll/epoll 等多路选择器：支持单一线程同时监听多个文件描述符,阻塞等待,并在其中某个文件描述符文可读写时收到通知。

本质上复用的是线程,让一个thread of control能够处理多个连接(I/O事件)

### 信号驱动I/O Signal drivern I/O

### 异步I/O Asynchronous I/O
