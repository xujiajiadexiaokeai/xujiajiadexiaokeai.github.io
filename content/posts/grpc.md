---
date: 2022-07-13T19:15:17+08:00
draft: false
url: "/2022-07-13/grpc-concepts"
layout: post
description: "gRPC concepts"
author: "Wenhao Jiang"
tags:
    - gRPC
    - Network
title: "gRPC concepts"
---

# Interface Definition Language(IDL)
protocol buffers

# Synchronous vs. asynchronous
**application-specific**

# RPC life cycle
## Unary RPC
1. client -> server
- metadata
- method name
- deadline if applicable
2. server -> client
- send back its own initial metadata (which must be sent before any response) straight away
- or wait for the client’s request message
- which happens first, is **application-specific**
- optional trailing metadata
  
## Server streaming RPC
like unary RPC

## Client streaming RPC
like unary RPC

## Bidirectional streaming RPC
- the call is initiated by the client invoking the method and the server receiving the client metadata, method name, and deadline
- server can choose to send back its initial metadata or wait for the client to start streaming messages
- processing is application specific
- two streams are independent

# Deadlines/Timeouts
- clients to specify
- server can query
- specifying a deadline or timeout **is language specific**

# RPC termination
both the client and server make **independent** and local determinations of the success of the call, and their conclusions may not match

# Cancelling an RPC
- client and server either can cancel at any time
- changes made before a cancellation are not rolled back.

# Metadata

# Channels
- clients can specify channel arguments to modify gRPC’s default behavior(such as message compression)
- channels has state, including **connected** and **idle**
- closing a channel is **language dependent**
- Some languages also permit querying channel state