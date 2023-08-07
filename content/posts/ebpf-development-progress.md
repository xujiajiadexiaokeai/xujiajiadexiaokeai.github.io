---
title: "[WIP]eBPF在可观测性领域工程进展"
date: "2023-07-04T12:13:36+08:00"
draft: true
layout: post
description: "本文对eBPF近期在可观测性领域工程进展进行梳理..."
author: "Wenhao Jiang"
tags:
  - Kernel
  - OS
  - eBPF
  - Observability
URL: "/2023-07-04/ebpf-development-progress"
---
# eBPF在可观测性领域工程进展

## 概念

### 什么是eBPF

eBPF（extended Berkeley Packet Filter）是一种虚拟机技术，它可以在Linux内核中运行小型程序，这些程序可以访问内核数据结构，而不会破坏内核的稳定性和安全性。eBPF程序可以在运行时动态加载，而无需重新编译内核或重新启动系统。eBPF程序可以在内核中执行，也可以在用户空间中执行。eBPF程序可以通过内核中的钩子点来执行，这些钩子点允许eBPF程序在内核中的特定位置执行，例如网络栈、文件系统、虚拟文件系统、安全模块、调度程序、内存管理、信号处理、跟踪和调试等。

### 什么是可观测性

可观测性（Observability）是一个系统工程和控制系统领域的概念，它描述了一个系统中的状态是否能够被观测到和测量到。一个系统是可观测的，当且仅当系统的任何状态都可以通过测量系统的输出来唯一确定。换句话说，如果我们可以测量或估计系统的所有状态变量，那么系统就是可观测的。如果我们不能测量或估计一个或多个状态变量，那么系统就是不可观测的。

在计算机系统领域，可观测性是指计算机系统的状态、性能和行为是否能够被有效地监测、测量和分析。可观测性在计算机系统的设计、开发、测试和维护等各个阶段都非常重要。

计算机系统中的可观测性包括以下几个方面：

- 系统状态的监测和测量：计算机系统的状态包括硬件和软件方面的状态，例如 CPU 使用率、内存使用率、磁盘空间等。为了保证系统的正常运行，需要对这些状态进行监测和测量，以及在必要时进行调整和优化。

- 性能的监测和测量：计算机系统的性能包括响应时间、吞吐量、并发性等方面。为了保证系统的高性能，需要对这些性能指标进行监测和测量，并对性能问题进行分析和优化。

- 日志和跟踪的记录和分析：通过记录系统的日志和跟踪信息，可以了解系统的行为和状态，以及诊断问题和进行故障排除。因此，日志和跟踪的记录和分析也是可观测性的重要方面。

- 监控和报警：为了及时发现和解决问题，需要对系统进行监控，并在必要时发出报警。监控和报警是保证系统可靠性和可用性的重要手段。

为了实现计算机系统的可观测性，需要使用各种工具和技术，例如性能监测工具、日志记录工具、跟踪工具、监控系统等。此外，还需要设计和实现可观测性的机制和接口，以便系统的各个组件可以相互通信和交换信息，实现有效的监测、测量和分析。

## 为什么eBPF适用于可观测性

eBPF是一个基于内核的虚拟机，它可以在不修改内核代码的情况下，动态地在内核中注入代码进行监控和控制。
eBPF因其强大的功能和高效的性能，在可观测性领域得到了广泛的应用。

eBPF适用于可观测性的原因主要有以下两个方面：

1. **特性优势**：eBPF具有丰富的特性和优势，包括：
- 动态性：eBPF可以在运行时动态地加载和卸载代码，而不需要重新编译或重新启动内核，从而实现了实时监测和控制。
- 安全性：eBPF的代码可以被内核安全地执行，而不会对内核造成任何损害或风险。
- 灵活性：eBPF可以访问内核和用户空间的数据，可以监测和控制各种类型的系统事件和资源。
- 可扩展性：eBPF可以通过各种插件和库扩展其功能和用途，例如，可以用eBPF实现网络监测、安全审计、性能分析等。
- 高效性：eBPF的代码可以被编译为高效的机器码，并在内核中直接执行，从而实现了极高的性能和低延迟。
2. **应用场景丰富**：eBPF可以应用于各种可观测性场景，例如：
- 网络监测：eBPF可以监测网络流量、协议、连接和性能等指标，帮助诊断和调试网络问题。
- 安全审计：eBPF可以监测系统调用、文件访问、进程行为和权限等，帮助发现和预防安全漏洞。
- 性能分析：eBPF可以监测CPU使用率、内存使用率、I/O操作和函数调用等，帮助分析和优化系统性能。


总之，eBPF适用于可观测性领域，因为它具有丰富的特性和优势，并且可以应用于多种场景，从而实现了高效、灵活、安全和可扩展的监测和控制。

## 可观测领域相关工程进展

### 工具发展

1. bpftrace

  [bpftrace](https://github.com/iovisor/bpftrace) 是基于eBPF技术构建的高级跟踪工具，它提供了一种简单而强大的方式来分析和观察Linux系统的各个方面。它使用一种类似于C语言的声明式语法，允许用户编写跟踪脚本来捕获和分析系统事件。bpftrace 语言的灵感来自 awk 和 C，以及 DTrace 和 SystemTap 等前身跟踪器。 bpftrace 由[Alastair Robertson](https://github.com/ajor)创建。

  以下是bpftrace的一些特性和用途：

  - 动态跟踪：bpftrace可以在运行时动态地跟踪系统事件，如系统调用、函数调用、内核事件等。它可以帮助开发人员和系统管理员深入了解系统的行为和性能瓶颈。
  - 低开销：bpftrace使用eBPF虚拟机技术，它在内核中执行用户提供的脚本，而无需修改内核代码。这种设计使bpftrace具有较低的性能开销和较小的安全风险。
  - 丰富的事件源：bpftrace可以跟踪各种事件源，包括系统调用、函数调用、硬件事件、内核事件等。这使得它适用于各种不同的用例，如性能分析、故障排查和安全监测等。
  - 灵活的脚本语言：bpftrace使用类似C语言的语法，允许用户编写简洁而灵活的跟踪脚本。它支持条件语句、循环、函数定义等常见的编程结构，使得用户可以根据需要自定义跟踪逻辑。
  - 强大的输出格式：bpftrace可以以不同的输出格式展示跟踪结果，包括文本、JSON、直方图等。这使得用户可以根据自己的喜好和需求选择最合适的展示方式。

  bpftrace提供了各种工具，用于跟踪各种事件源，这些[工具](https://github.com/iovisor/bpftrace/tree/master/tools)也可作为 bpftrace 语言编程的示例。

  - tools/[biolatency.bt](https://github.com/iovisor/bpftrace/blob/master/tools/biolatency.bt): 以直方图形式展示块 I/O 延迟. [Examples](https://github.com/iovisor/bpftrace/blob/master/tools/biolatency_example.txt).
  - tools/[biosnoop.bt](https://github.com/iovisor/bpftrace/blob/master/tools/biosnoop.bt): 块 I/O 跟踪工具，显示每个 I/O 延迟. [Examples](https://github.com/iovisor/bpftrace/blob/master/tools/biosnoop_example.txt).
  - tools/[bitesize.bt](https://github.com/iovisor/bpftrace/blob/master/tools/bitesize.bt): 以直方图形式显示磁盘 I/O 大小. [Examples](https://github.com/iovisor/bpftrace/blob/master/tools/bitesize_example.txt).
  - tools/[capable.bt](https://github.com/iovisor/bpftrace/blob/master/tools/capable.bt): 跟踪安全能力检查. [Examples](https://github.com/iovisor/bpftrace/blob/master/tools/capable_example.txt).
  - tools/[cpuwalk.bt](https://github.com/iovisor/bpftrace/blob/master/tools/cpuwalk.bt): 采样哪些 CPU 正在执行进程. [Examples](https://github.com/iovisor/bpftrace/blob/master/tools/cpuwalk_example.txt).
  - ...


  bpftrace还提供了一些仅用一行命令来完成一些功能的[教程](https://github.com/iovisor/bpftrace/blob/master/docs/tutorial_one_liners.md)，用来快速熟悉相关功能和能力。


  - 利用Regex列出所有可用tracepoint
  ```
  bpftrace -l 'tracepoint:syscalls:sys_enter_*'
  ```
  - 对系统调用进行统计
  ```
  bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'
  Attaching 1 probe...
  ^C

  @[bpftrace]: 6
  @[systemd]: 24
  ```
  - ...

// TODO
2. bcc
3. eCapture
4. OpenResty XRay
### 云原生领域的进展
1. Datadog
2. Pixie
3. Parca
4. Groundcover
5. Skywalking
6. Deepflow
7. Kindling