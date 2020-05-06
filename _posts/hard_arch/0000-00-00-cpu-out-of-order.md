---
title: CPU, Pipeline and Out-Of-Order Execution
date: 2015-07-06
categories: [cs_related]
---

## x86 pipeline
Any Sandy Bridge or more recent processor from Intel should share the same pipeline stages as the diagram below.
I had not the time to go over the whole architecture manual so my drawing is inaccurate.

**TODO** : illustrate macro/micro op fusion and memory dependency prediction

## Out of order execution
The x86 do not execute instructions. It looks more like a just-in-time compiler that translates macro operations
into micro operations and executes them on the fly. **Micro ops are executed in // and speculatively.**
A number of known incorrect behaviours can arise from these optimisations:

* Branch miss-prediction
* RAW (read after write) : a memory address was read from the cache before a store to that same address was committed
  to the store buffer or L1 cache
* WAR (write after read) : the inverse problem. Out of order executed a store before a load whereas the order in the
  program was the other way around
* WAW (writer after write) : 2 store operations are executed in the wrong sequence compared to the program.  

Any of the above may trigger a pipeline flush.

![CPU_Exe_Pipeline.svg]({{ site.images }}/CPU_Exe_Pipeline.svg){:.my-block-wide-img}
![CPU_Load_Buffer.svg]({{ site.images }}/CPU_Load_Buffer.svg){:.my-block-wide-img}
