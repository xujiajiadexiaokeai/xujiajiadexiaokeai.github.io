---
date: 2023-04-10T09:35:30+08:00
draft: false
url: "/2023-04-10/building-a-go-profiler-using-go"
layout: post
description: "[NOTE] Building a Go profiler using Go"
author: "Wenhao Jiang"
tags:
    - Profiling
    - Observability
    - eBPF
    - Go
title: "[NOTE] Building a Go profiler using Go"
---
# [NOTE] Building a Go profiler using Go

## What is profilling

A form of dynamic program analysis that **measures** resource consumption

For example:

- the **space** (memory)
- **time complexity** of a program (CPU)
- **usage of instructions**
- **frequency** and **duration** of function calls

## Why use profiling

Profiling is about how do we know:

- What's worth optimizing?
- What needs optimization?

## How to profiling

- Tracing
  - Recording each and every event constantly
  - High costs
- Sampling
  - Sample for a certain duration
    - Eg. 10 seconds
  - Periodically observe function call stack
    - Eg. 100x per second
  - Low overhead
    - <0.5% CPU
    - ~4MB memory

## Tiny Profiler

- A proof-of-concept profiler
- Profile all Go processes on a machine
- Produce pprof formatted profiles every 10s

## Continuous Profiling

- pprof creates profile samples
- We want to sample every so often
- Little overhead due to sampling
- We hope to get profiles right before OOMs
- Automatically collect profiles rather than by hand

## Source

- [GopherCon Europe 2022: Kemal Akkoyun - Building a Go Profiler Using Go](https://www.youtube.com/watch?v=OlHQ6gkwqyA)
- [Google-Wide Profiling: A Continuous Profiling Infrastructure For Data Centers](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36575.pdf)