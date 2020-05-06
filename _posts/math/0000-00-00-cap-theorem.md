---
title: Distributed systems, CAP theorem
date: 2015-05-25
categories: [cs_related]
---

## CAP theorem
* Availability - the system answers to all queries with a valid (but potentially not correct) response
* Consistency - externally : all reads to the system will return the value set by the last commit
  Internally : all nodes share the same copy of the data (except the nodes updating it)
  This implies the notion of atomicity : all distributed access to data appear to be serialized
  So that there is an order between them even among different nodes
* Partition tolerance - in case of a network failure creating a partition (2 or more distinct sets of
  Nodes cannot reach the other sets anymore), consistency and/or availability are guaranteed

Formulated in 2000 and proven in 2002 there are actually 2 theorems depending on whether the system is
asynchronous or partially synchronous. The practical rules proven by CAP are:

1. Only 2 properties from (availability, consistency and partition tolerance) can be achieved
2. A scalable system must be partition tolerant. Scalable => many machines => probability of
  Failures increases. A consistent and available system is not indefinitely scalable

## Consistency models
In order to have a scalable and available system the following consistency models may be chosen

* Weak - any repeated read of the same data may return different values
  Internally : any node holding a copy of the data can have a different value
* Eventual - after the last update there exists an **finite inconsistency window** after which data becomes consistent  
  Internally : a replication mechanism ensure all nodes eventually get the same value for their local copy
* Monotonic read - if a first read has returned version V then all subsequent reads will return a version of data V' >= V  
  Internally : clients have an affinity for a certain node
* Monotonic write - writes by the same client are serialized so that they happen in the same order as they were issued

## Parameters of a distributed data store
In a model were each data is stored in several nodes (each has a copy reflecting the value at some point)
there are 3 parameters that determine the consistency of the system :

1. N number of nodes sharing a copy of the data
2. W number of nodes that have written the same new value of a data before the write returns as
  successful to the client
3. R number of nodes queried for the data when a client attempts a single read on that data

* R+W>N - In this case the system is consistent => A read will contact at least 1 node where the data
  was last written => by using versioning on data the most recent value can be determined
* W>3 - the system is fault tolerant data durability is guaranteed
* R=1,N big - configuration for scalable reads, many nodes can handle read to the data, minimum
  latency (only 1 node contacted/read)

