---
title: CPU architecture considerations
date: 2015-07-06
categories: [cs_related, cpu]
---

## Notions
* ISA density : number of instructions needed to perform tasks. The higher the density (less instructions) the better.
  It will consume less space in the instruction cache and use less bandwidth.
* Direct-associative cache : Each memory block has an **unique** cache line. It is determined using the memory address.  
  This is the faster lookup cache. However 2 addresses that are cache\_size * line\_size apart will be overwritten.
* N-associative cache : Like direct associative but for a given index value, N different lines can be stored.
  A lookup will need to check all the lines sharing the same index value. This is a compromise between lookup-speed
  and premature cache eviction problems.
* Full-associative cache : Basically a key-value map. You can store cache\_size lines independently of their address.
  However it has the slower lookup.
* False sharing : contention over 2 **distinct** variables stored in the same cache line.

## Memory models
* Sequential consistent : stronger model where operations are ordered for each core.
* DRF-SC : data race free sequential consistency, SC is guaranteed as long as critical sections are synchronized
* Release consistency : sequential consistency around load and store barriers

## Links
* [What are caches and why do you care](https://www.youtube.com/watch?v=WDIkqP4JbkE)

![CPU_Associative_Cache.svg]({{ site.images }}/CPU_Associative_Cache.svg){:.my-block-wide-img}
![CPU_Write_Combining.svg]({{ site.images }}/CPU_Write_Combining.svg){:.my-block-wide-img}
![CPU_Sequential_Consistency.svg]({{ site.images }}/CPU_Sequential_Consistency.svg){:.my-block-wide-img}
