---
layout: diagram
title: Linux training - memory allocators
categories : [diagram, linux]
diagram_list: [ Memory_Fragmentation.svg, Linux_Slab_Allocation.svg ]
---

### Slab Memory Allocators
* Slab allocation - allocation based on object (=data in this ctx) size, each size object has a dedicated set of slabs where it will be allocated.
  Avoids fragmentation for frequent allocation of small objects.
* The slab API allows to pass a constructor/destructor to an object size so that reallocation of the same type has less CPU overhead
* SLUB - implementation of the slab allocator from 2.6, replaced the slab allocator


