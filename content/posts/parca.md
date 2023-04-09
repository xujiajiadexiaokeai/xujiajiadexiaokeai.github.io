---
date: 2023-04-08T14:15:30+08:00
draft: false
url: "/2023-04-08/parca"
layout: post
description: "Parca"
author: "Wenhao Jiang"
tags:
    - Profiling
    - Observability
    - eBPF
title: "Parca"
---

# Overview

## Features

- a multi-dimensional data model with series of profiles identified by the profile type and key/value pairs
- a label-selector based designed for profiling data
- optimized, built-in storage
- support for pushing and pulling profiles from targets
- targets are discovered via service discovery or static configuration
- super low overhead profiler, powered by eBPF

## What is profiling

Profiles describe a particular aspect of the execution of code

Two main types of profiles: tracing and sampling

Parca focuses on samplign profiling, very little overhead, can always be on in production env.

Profiling types:

- CPU profiling
- heap profiling
- runtime specific profiling: goroutine profiling

Raw data for sampling profiles: stack-traces, values attached to those stack-traces

## What is continuous profiling?

sampling profiling is possible that some parts of an execution are missed

continuous profiling attempts to gather data continuously

## Use cases

- saving money
- understand difference
- understand incidents

# Concepts

## Data model

## Stable links

## Pprof

## Icicle Graphs

## Cumulative and Diff values

# Source

- https://www.parca.dev/docs/overview