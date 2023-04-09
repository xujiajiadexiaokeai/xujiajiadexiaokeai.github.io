---
date: 2023-04-05T22:15:25+08:00
draft: true
url: "/2023-04-05/parca-quickstart-tutorial-for-macos-users"
layout: post
description: "Parca Quickstart Tutorial For MacOS Users"
author: "Wenhao Jiang"
tags:
    - Profiling
    - Observability
    - eBPF
    - Parca
title: "Parca Quickstart Tutorial For MacOS Users"
---

# Parca Quickstart Tutorial For MacOS Users

This tutorial will have three sections.Section 1 introduces Parca, Section 2 explains how to install and start Parca on MacOS, and the final Section covers some usage scenarios for Parca.

## Introduction

Parca is an open source tool for providing system observability, designed to reduce the fragmentation between logs, traces, and metrics - the three pillars of observability, and to provide continuous profiling for analysis of CPU, memory usage over time, saving infrastructure cost, improving performance, and increasing reliability.

Measuring the state of your application by capturing CPU/memory profiles or snapshots of the application is known as sampling profiling. But instead of using discrete profiles, Parca monitors the state continuously over time. Continuous sampling profiling carries very little overhead, making it suitable for production environments.[1]

These profiles can then be visualised and queried to drill down on resource-heavy areas of your code.[1]

Parca comprises three components:

- Parca Server
- Parca Agent
- Parca web UI

# Quickstart



# Usage



# Source

[1] https://www.polarsignals.com/blog/posts/2022/07/12/introducing-parca-sequel/