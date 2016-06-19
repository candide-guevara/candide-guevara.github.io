---
layout: diagram
title: Linux training - scheduling
categories : [diagram, linux]
diagram_list: [ Linux_Preemptive_Kernel.svg, Linux_Completely_Fair_Scheduler.svg, Linux_Process_Sleep.svg ]
---

### Notions
* Quantum - timeslice - the amount of time given to a process to run on a CPU
* Jiffy - a tick of the interrupt timer, used to measure quantum
* Processor affinity - processes should be scheduled to run in the processors they ran before so that some of their data is still in the local cache.
  Otherwise it will have to be filled from the start => Hot vs Cold cache (memory latency penalty)

### Signal/Interrupt handling
* Re-entrant - a piece of code (function, block) that can be stopped by a interrupt in the middle of its execution and can be re-entered at a later time without error
* Reentrancy - any function that can be interrupted after any instruction, re-entered (called again) and resumed from previous instruction.
  A piece of code is reentrant if it does not use static variables, it does not modify its code and does only call reentrant functions.
* Preemption - stopping an executing process without its cooperation to schedule another task. Contrary to cooperative scheduling where process must yield the CPU resource
* Bottom half - in linux an interrupt may be split in a top half which should execute quickly in interrupt context,
  and a bottom half which performs the lengthy task using any linux framework like tasklets, workqueues ...

### Process schedulers
Linux can handle different classes of schedulers that are called one after the other. From higher to low priority.
There are 2 types of scheduling : Fair scheduling for normal processes and Real time scheduling using round robin between processes.
Since 2.6 linux kernel is preemptive. Kernel parts which are not reentrant can acquire a preemption lock.

### Characteristics of a good scheduler

* Scale to any number of processes ideally scheduling should be independent of it
* Limit contention (several cores can schedule in //) and schedule overhead
* Improve system response : processes waiting for input should be waken up quickly
* Try to keep process/CPU affinity but also balance the load between CPUs

### Scheduler implemetations
* O(1) scheduler - legacy scheduler running in constant time using active/inactive runqueues
* CFS - completely fair scheduler : sorts processes by the time they have used the CPU in red black trees. To take into account priority, times passes slower on higher proc

