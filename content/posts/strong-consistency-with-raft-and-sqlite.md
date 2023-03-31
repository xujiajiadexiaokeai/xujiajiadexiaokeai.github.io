---
date: 2023-03-31T10:30:15+08:00
draft: false
url: "/2023-03-31/strong-consistency-with-raft-and-sqlite"
layout: post
description: "[Note]Strong Consistency with Raft and SQLite"
author: "Wenhao Jiang"
tags:
    - Consistency
    - Raft
    - SQLite
    - System Design
title: "[Note]Strong Consistency with Raft and SQLite"
---
# [Note]Strong Consistency with Raft and SQLite

> https://blog.sqlitecloud.io/strong-consistency-with-raft-and-sqlite

## Central Database vs Distributed Database
### Central Database
- Advantage:
  - It is consistent and up-to-date by default
  - Only one source of truth
- Disadvantage:
  - Single point of failure
  - Become overwhelemd as the amount of data grows
  - Performance issues
  - Slower response times

### Distributed Database
- Advantage:
	- Scalability
	- High availability
	- Localized access
    Improve response times and reduce network latency
	- Lower cost
		Can be built using commodity hardware

## Challenge in Distributed Database
**maintain data consistency across multiple nodes**

Must be use a strong consistency model

SQLite Cloud guarantees strong consistency and uses the Raft consensus algorithm under the hood

## Raft
- A distrubuted consensus algorithm
- Be designed to help manage replicated logs
- Works by ensuring that all nodes in a distributed system agree on the same log of commands or events

## How does Raft work?
- Leader manage all log
  - Works by electing a leader node that manages the replicated log
  - Leader node receives commands  and replicates them across all nodes
  - Ensures that all nodes have the same log of commands by using a series of communication messages called "log entries"
  - Each log entry contains a command or event that is appended to the log of each node
- Divide time into terms
	- Each term begins with a leader election
- Log replication
	- Leader sends log entries to all other nodes
	- A majority vote(quorum)

## How To Achieve Strong Consistency with Raft?
- Leader election
- Log replication
- Commit mechanisms
  Ensure that log entries are executed in the same order on all nodes in the system

## What to distribute with SQLite?
- Raw SQL statement
  Some database engines distribute raw SQL statement.

  It will produce different outputs on different nodes by using **non-deterministic SQL** functions.
  
	How to immune  the side effects of non-deterministic SQL statements
  - Use severe limitations
  - Use complex SQL parsers

- ChangeSet
  SQLite Cloud only distribute hte changeset derived from executing the SQL statement in one node

  They distribute the result of the statement (plus some other metadata)
  ```json
  {
      "table": foo,
      "data": {
          "col1": 8875612685081594789,
          "col2": "10:57:34",
          "col3": "2023-03-21"
      }
  }
  ```