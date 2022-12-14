---
date: 2022-08-20T15:30:17+08:00
draft: false
url: "/2022-08-20/token-bucket"
layout: post
description: "token-bucket"
author: "Wenhao Jiang"
tags:
    - Algorithm
title: "令牌桶"
---

> https://zhuanlan.zhihu.com/p/442218413
# 基本思想
令牌桶, 通过让请求被处理前先行获取令牌, 只有获取到令牌的请求才能被放行处理
- 按固定速率来产生令牌存入桶中, 如果令牌数量超过桶的最大容量则直接丢掉
- 当有请求时先从桶中获取令牌,获取到令牌后才能进行处理, 否则被直接丢弃或者等待获取令牌

# 令牌桶与漏桶的区别
令牌桶与漏桶的区别在于漏桶控制的是请求被处理的速率。即当有请求的时候，先进入桶中进行排队，按固定的速率流出被处理；而令牌桶控制的是令牌产生的速率。即当有请求的时候，先从令牌桶中获取令牌，只要能获取到令牌就能立即通过被处理，不限制请求被处理的速度，所以也就可以应对一定程度的突发流量

# 实现
[time/rate](https://pkg.go.dev/golang.org/x/time/rate)包就是基于令牌桶实现的
```go
func main() {
    // 构造限流器
    limiter := NewLimiter(10, 5)

    for i := 0; i < 10; i++ {
        time.Sleep(time.Millisecond * 20)
        if !limiter.Allow() {
            fmt.Printf("%d passed\n", i)
            continue
        }

        // 说明请求通过Allow获取到了令牌, 继续处理
        // todo

    }
}
```
## time/rate实现原理
- lazyload
- 直到有请求消费时才根据时间查更新Token数目
- 通过计数原理计算当前桶中已有的Token数量

## Token的生成和消耗
- 以**固定速率**产生Token
```go
func NewLimiter(r Limit, b int) *Limiter {
    return &Limiter{
        limit: r, // 每秒钟可以生成Token的数量
        burst: b,
    }
}  
```
- lazyload
当有请求到来时，去桶中获取令牌的同时先计算一下从上次生成令牌到现在的这段时间应该添加多少个令牌，把增量的令牌数先加到总的令牌数据上即可，后面被取走的令牌再从总数中减去即可

```go
type Limiter struct {
    limit Limit    // QPS 一秒钟多少个token
    burst int      // 桶的容量
    tokens float64 // 当前的token数量
    last time.Time // last代表最近一次更新token的时间
}
```
所以在请求到来时:
```go
tokens += (当前时间t - 最近一次更新tokens的时间last) / 时间间隔
```

## 如何应对突发流量
- 令牌桶缓存令牌
- 令牌桶最大容量约束

## 数值溢出问题
```go
    // elapsed表示最后一次更新tokens数量的时间到现在的时间差
    elapsed := now.Sub(last)
    // delta 具有数值溢出风险， 表示elapsed这段时间应该产生的令牌数量
    delta := elapsed.Seconds() * float64(limit)

    //tokens 表示当前总的令牌数量
    tokens := lim.tokens + delta
    if burst := float64(lim.burst); tokens > burst {
        tokens = burst
    }
```
所以为了防止delta溢出,应该对elapsed有最大值的约束, maxElapsed是可以计算得到的
```go
    maxElapsed := lim.limit.durationFromTokens(float64(lim.burst) - lim.tokens)
    elapsed := now.Sub(last)
    if elapsed > maxElapsed {
        elapsed = maxElapsed
    }

    delta := lim.limit.tokensFromDuration(elapsed)

    tokens := lim.tokens + delta
    if burst := float64(lim.burst); tokens > burst {
        tokens = burst
    }

    func (limit Limit) tokensFromDuration(d time.Duration) float64 {
        sec := float64(d/time.Second) * float64(limit)
        nsec := float64(d%time.Second) * float64(limit)
        return sec + nsec/1e9
    }
}
```

# 总结
TokenBucket是以固定的速率生成令牌，让获得令牌的请求才能通过被处理。令牌桶的限流方式可以应对一定的突发流量。在实现TokenBucket时需要注意在计算令牌总数时的数值溢出问题以及精度问题。