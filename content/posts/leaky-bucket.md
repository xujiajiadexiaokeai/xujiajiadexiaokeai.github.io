---
date: 2022-08-20T15:32:17+08:00
draft: false
url: "/2022-08-20/leaky-bucket"
layout: post
description: "token-bucket"
author: "Wenhao Jiang"
tags:
    - Algorithm
title: "漏桶算法"
---

# 请求如何排队


delta = 当前时间t - last
last = 当前时间t + (rate - delta)



```go
type LeakyBucket struct {
    rate int64 // 处理请求的速率
    capacity int64 // 桶的最大容量
    last time.Time // 桶中最后一个排队请求被处理的时间
    mu sync.Mutex
}

func (t *LeakyBucket) Limit(ctx context.Context) (time.Duration, error) {
    t.mu.Lock()
    defer t.mu.Unlock()

    now := time.Now().UnixNano()
    if now < t.last {
        // 说明已经有请求在排队了,那么新请求进来排队后被处理的时间就是rate后
        t.last += t.rate
    } else {
        // 桶为空
        var offset int64 // 代表等待处理该请求的时间需要等待多久
        delta := now - state.Last // 代表当前时间距离上次处理请求的时间过了多久
        if delta < t.rate {
            // 说明还没有到下次处理请求的时间, 还需要等待offset后才能到
            offset = t.rate - delta
        }
        t.last = now + offset
    }

    wait := t.last - now 
    if wait / t.rate > t.capacity { // 桶满了, 直接丢弃请求, 返回error
        t.last = now - offset
        return time.Duration(wait), ErrLimitExhausted
    }

    // 排队成功, 返回要等待的时间给调用者, 让调用者sleep进行阻塞就能实现按rate速率处理请求了
    return time.Duration(wait), nil

}
```
# 总结
LeakyBucket的核心思想是按固定的速率处理请求, 不支持突增的流量
基于计数原理的实现本质上就是按固定的处理速率计算该请求能够被处理的时间以及需要等待的时间

