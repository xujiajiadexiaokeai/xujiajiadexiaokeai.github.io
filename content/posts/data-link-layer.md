---
title: "data-link-layer Notes"
date: 2021-11-23T15:49:30+08:00
layout: post
description: "data link layer notes"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - Network
URL: "/2021-11-23/data-link-layer"
---

# 数据链路层将比特合成帧为单位进行传输

可以在出错时只重发出错的帧,而不用重发全部数据,提高了效率

组帧: 封装成帧 主要解决 帧定界、帧同步、帧传输

## 组帧要加首部、尾部

网络中以帧为最小单位进行传输,而分组(即IP数据报)仅仅是包含在帧的数据部分,不需要尾部

### 字符计数法(脆弱)

在帧头部使用一个计数字段来标明帧内字符数,可以确定帧结束位置 计数字段的字节数包含自身

如果计数字段出错,则后续将无法确认帧结束位和开始位

### 字符填充的首尾定界符法(复杂 不兼容)

开始: DLE STX

结束: DLE ETX

如果在数据段出现DLE字符,发送方在每个DLE字符前再插入一个DLE,接收方会自己删除DLE,数据仍不变

### 比特填充的首尾标志法

01111110 来标识一帧的开始与结束

发送方 每5个连续的1会自动在后面插入一个0

接收方 每5个连续的1会删除后面的0

容易用硬件实现 性能优于字符填充

### 违规编码法

曼彻斯特编码法: 1 : 高-低电平 0: 低-高电平 

高-高 低-低是违规编码 可以用于标识首尾 局域网IEEE 802采用这种方法编码

不采用任何填充技术

只适用采用冗余编码的特殊编码环境

# 差错控制

传输中的差错都是由噪声引起的.

### 噪声分成两类:

信道固有的,持续存在的热噪声: 可通过提高信噪比来减少或避免

外界特定原因所造成的冲击噪声: 需要利用编码技术来进行差错控制

### 差错控制: 自动重传请求(ARQ)-检错编码、前向纠错(FEC)-纠错编码

### ARQ: 接收端通知发送端重发,直到正确

### FEC: 接收端发现差错,并可以确定错误位置,加以纠正

## 检错编码

奇偶校验码

通过增加冗余位来使码字中 1 的个数保持为奇数或偶数的编码方法.

只能发现奇数个比特的错误

循环冗余校验码

假设一个帧有m位,其对应的多项式为G(x),则计算冗余码的步骤如下:

1) 加0: 假设G(x)的阶为r,在帧的低位端加上r个0

2) 模2除: 利用模2除法,用G(x)对应的数据串去除1)中计算出的数据串,得到的余数为冗余码(共r位,前导0不可去除)

多项式为模2运算. 加法不进位,减法不借位(其实就是异或操作) 

## 纠错编码

m个信息位插入r个校验位组成m+r个码字,必须满足2^r>=m+r+1

海明码

可发现双比特错,纠正单比特错

纠错d位 需要码距为2d+1的编码方案 检错d位 只需要d+1位

# 流量控制与可靠传输

## 流量控制

使接收方有足够的缓冲空间来接收帧

基本方法: 由接收方来控制发送方发送数据的速率



















