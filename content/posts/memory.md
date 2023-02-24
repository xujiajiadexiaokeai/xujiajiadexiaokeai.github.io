---
title: "memory-management Notes"
date: 2022-02-28T17:07:30+08:00
layout: post
description: "内存管理 笔记"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - System
URL: "/2022-02-28/memory-management"
---
虚拟内存->物理内存

虚拟存储器

虚拟存储器解决了三个根本需求:

确保可以运行存储空间需求比实际内存空间大的用户进程

确保为用户程序分配的内存空间是连续的

确保多个用户程序之间的内存空间互相隔离

虚拟存储器能力:

**隔离性**和**连续性**



**内-外存空间交换能力**

基于局部性原理实现的内-外存交换技术

时间局部性

空间局部性

是一种时间换空间策略



Swap交换分区

**虚拟地址空间编址能力**

**虚拟地址空间隔离能力**





 页式管理

页不是程序独立模块对应的逻辑实体,所以处理、保护和共享都不及段来的方便.同时因为页要比段小的多,在进行交换时,不会出现段交换那般卡顿.所以页式存储管理方式会更加的收到欢迎,



页式存储在加载程序时,不需要一次性加载完全部程序,由操作系统调度.当CPU要读取特定的页,但却发现页的内容没有加载,会触发来自CPU的缺页错误.然后找到对应的页并加载到内存中.



通过这种方式可以运行远大于实例物理内存的程序,但相对的执行效率会下降



页表管理机制中有两个重要概念:

### 快表(TLB)

目的: 为了解决虚拟地址到物理地址的转换速度.

流程:

    1. 根据虚拟地址中的页号查快表

    1. 如果该页在快表中,直接从快表中读取相应的物理地址

    1. 如果该页不再快表中,就访问内存中的页表,再从页表中得到物理地址,同时将页表中的该映射表项添加到快表中

    1. 当快表填满后,又要登记新页时, 就按照一定的淘汰掉快表中的一个页

### 多级页表

目的: 为了避免把全部页表一直放在内存中占用过多空间



分页与分段的异同:

共同点:

分页和分段都是为了提高内存利用率,较少内存碎片

页和段都是离散存储的,所以两者都是离散分配内存的方式.但是每个页和段中的内存是连续的

区别:

页的大小是固定的,由操作系统决定;而段的大小不固定,取决于当前运行的程序

分页仅仅是为了满足操作系统内存管理的需求,而段是逻辑信息的单位,在程序中可以体现为代码段,数据段,能够更好满足用户的需要.

![](https://tcs.teambition.net/storage/312f5c40cf69de4112c2471cf710bd622426?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE1OSwiaWF0IjoxNjc3MjIwMzU5LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmY1YzQwY2Y2OWRlNDExMmMyNDcxY2Y3MTBiZDYyMjQyNiJ9.cQU2BY-HE-NC92QSshNfxpwF6YiCbXhK3p_gSVbUbCU&download=image.png "")

因为操作系统的虚拟地址空间大小都是一定的，整片虚拟地址空间被均匀分成了 N 个大小相同的内存页，所以内存页的大小最终会决定每个进程中页表项的层级结构和具体数量，虚拟页的大小越小，单个进程中的页表项和虚拟页也就越多。



一个完整的页表翻译和查找的过程叫作页表查询(Translation Table Walk), 页表查询的过程由硬件自动完成,但是页表的维护需要软件来完成



基于页表的虚实地址转换原理







# 段式管理

# 段页式管理

