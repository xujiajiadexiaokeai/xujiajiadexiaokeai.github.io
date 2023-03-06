---
title: "为什么select仅能作用于管道?"
date: "2022-11-17T19:15:45+08:00"
draft: false
layout: post
author: "Wenhao Jiang"
tags:
    - Go
URL: "/2022-11-17/why-select-only-work-on-channel"
---

# select的特性
## case的执行
具体执行那个case,取决于函数传入的管道
- 管道没有缓冲区
- 有缓冲区并且还可以塞数据
- 有缓冲区但缓冲区已满
- 有缓冲区且已有部分数据

## 返回值
可以在case中声明变量并赋值

## default
default不能处理管道读写
当所有case被阻塞,执行default
default是特殊的case

# 使用案例
## 永久阻塞
使用select阻塞main函数
```go
func main() {
    server := webhooktesting.NewTestServer(nil)
    server.StartTLS()
    fmt.Println("serving on", server.URL)
    select {} // 没有case和default ,main()永久阻塞
}
```

## 快速检错
当使用管道来传输error时, 可以使用select快速检查管道中是否有error
```go
errCh := make(chan error, active)
jm.deleteJobPods(&job, activePods, errCh) // 传入chan用于记录error
select {
case manageJobErr = <-errCh:
    if manageJobErr != nil {
        break
    }
default: // 没有error, 结束
}
```

## 限时等待
当使用管道管理函数上下文时, 可以使用select创建具有时效性的管道
```go
func waitForStopOrTimeout(stopCh <-chan struct{}, timeout time.Duration) <-chan struct{} {
    stopChWithTimeout := make(chan struct{})
    go func() {
        select {
        case <-stopCh:
        case <-time.After(timeout): // 管道会在指定时间内关闭
        }
        close(stopChWithTimeout)
    }()
    return stopChWithTimeout 
}
```

# 实现原理
- 为什么每个case语句只能处理一个管道?
- 为什么case语句执行顺序随机(多个case都就绪的情况下)?
- 为什么case语句向值为nil的管道中写数据不会触发panic?

## 数据结构
```go
type scase struct {
    c *hchan // 操作的管道
    kind unit16 // case类型
    elem unsafe.Pointer // 指向数据存放位置的指针
    ...
}
```
1. 管道
因为每个scase中只有一个管道, 这决定了一个case只能处理一个管道
编译器在处理case语句时,如果case语句中没有管道操作(不能处理成scase对象),则会给出编译错误:
```
select case must be receive, send or assign recv
```

2. 类型
```go
const (
    caseNil = iota
    caseRecv
    caseSend
    caseDefault
)
```
- caseNil: 表示其操作的管道值为nil, 由于nil管道既不可读,也不可写,所以永远不会命中
所以在case语句中向值为nil的管道中写数据不会触发panic的原因
- caseRecv: 从管道中读数据
- caseSend: 向管道中写数据
- caseDeafult: 不会操作管道,每个select中仅可存在一个, 可出现在任意位置

3. 数据
scase.elem表示数据存放的地址
- caseRecv: 读出的数据存放的地址
- caseSend: 将写入管道的数据存放的地址

## 实现逻辑
`selectgo()` 用于处理select语句
```go
func selectgo(cas0 *scase, order0 *uint16, ncases int) (int, bool)
```
`selectgo()`函数会从一组case中挑选一个case,并返回命中case的下标,对于caseRecv的case,还会返回是否读取成功
当所有case都不可能就绪时,selectgo()陷入永久阻塞,此时函数不会返回
### cas0
编译器会将select中的case语句存储在一个数组中,cas0保存这个数组的地址
### ncases
ncases表示case的个数(包活default),即cas0数组的长度
### order0
order0 为一个整型数组的地址,其长度为case格式的2倍.
order0数组是**case执行随机性的关键**

order0数组被一分为二
前半部分存放case的随机顺序(pollorder),selectgo()会将原始的case顺序打乱,这样在检查每个case是否就绪时就会表现出随机性
后半部分存放管道加锁的顺序(lockorder),selectgo()会按照管道地址顺序对多个管道加锁,从而避免因重复加锁引发的死锁问题

## 实现
selectgo()函数的实现包括以下要点:
- 通过随机函数fastrandn()将原始的case顺序打乱,在遍历各个case时使用打乱后的顺序就会表现出随机性
- 循环遍历各个case时,如果发现某个case就绪,则直接跳出循环操作管道并返回
- 循环遍历各个case时,如果循环正常结束,说明所有case都没有就绪,有default直接跳default
- 如果都没有就绪且没有default,selectgo()将阻塞等待所有管道,任一管道就绪后,都将开始新的循环

# 小结
- select仅能操作管道
- 每个case仅能处理一个管道,要么读要么写
- 多个case语句的执行顺序是随机的
- 存在default,则select不会阻塞