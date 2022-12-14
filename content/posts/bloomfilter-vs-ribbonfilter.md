---
date: 2022-07-01T10:16:17+08:00
draft: false
url: "/2022-07-01/bloomfilter-vs-ribbonfilter"
layout: post
description: "bloomfilter vs ribbonfilter"
author: "Wenhao Jiang"
tags:
    - Distributed System
title: "Bloom Filter VS Ribbon Filter"
---

> https://developer.aliyun.com/article/980796

由于Bloom Filter只需要占用极小的空间，便可以给出”可能存在“和”肯定不存在“的存在性判断，因此可以提前过滤掉许多不必要的数据块，从而节省了大量的磁盘IO