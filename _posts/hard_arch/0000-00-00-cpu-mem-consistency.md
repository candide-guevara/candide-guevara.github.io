---
title: CPU, Memory consistency in multicore processors
date: 2015-07-06
categories: [cs_related, cpu]
---

## Memory barriers
* x86 has 3 types of memory barriers : sfence (store), lfence (load), mfence (full barrier)
* Memory barriers ensure loads and stores use the latest data from the cache. They enforce some sort of sequential consistency.

## Cache coherence

### **L1 caches always have the most up-to-date data.** In case of memory write-back the memory (and L3 cache) may have old data.
* Cache coherence protocols ensure all caches sharing the same line have the same data.
* 2 types of coherence architectures : bus snooping (between the same processor cores) and directory-based (between NUMA sockets)
* Bus snooping is faster but not scalable. It implies invalidation broadcasts => bus contention
* Directory based coherence has more latency but scales better. It uses point-to-point messages between sockets.
* Many types of messages flows are possible for directory based coherence. The optimal flow will reduce the contention on the home socket
  and have the shortest critical path (longest sequence of messages)
* WARNING : the diagram illustrating directory based coherence is not optimal nor realistic. I just made it up to have an idea on the
  message flows

## MESI protocol
Each cache line load/store follows a finite state machine. There are 4 main states M, E, S, I. 
Other states like O(owner) and F(forward) are optimisations to reduce bus contention and for NUMA sockets interconnect.

* Invalid : cache line is not present
* Exclusive : cache line is present **only in 1 core cache** and is clean (same contents in memory/L3 cache)
* Modified : cache line is exclusive and dirty (write-back needed)  
* Shared : cache line is clean and present in at least 2 core caches

## Links
* [Presentation on directory based coherence](http://www.cs.cmu.edu/afs/cs/academic/class/15418-s12/www/lectures/13_directorycoherence2.pdf)
* [Overview of memory barriers and bus snooping](https://fgiesen.wordpress.com/2014/07/07/cache-coherency/)

![CPU_Memory_Barriers.svg]({{ site.images }}/CPU_Memory_Barriers.svg){:.my-wide-img}
![CPU_Coherence_Bus_Snoop.svg]({{ site.images }}/CPU_Coherence_Bus_Snoop.svg){:.my-wide-img}
![CPU_Coherence_Directory.svg]({{ site.images }}/CPU_Coherence_Directory.svg){:.my-wide-img}
