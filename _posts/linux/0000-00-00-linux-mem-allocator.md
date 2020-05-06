---
title: Linux training, Memory allocators
date: 2015-05-29
categories: [cs_related]
---

### Slab Memory Allocators
* Slab allocation - allocation based on object (=data in this ctx) size, each size object has a dedicated set of slabs where it will be allocated.
  Avoids fragmentation for frequent allocation of small objects.
* The slab API allows to pass a constructor/destructor to an object size so that reallocation of the same type has less CPU overhead
* SLUB - implementation of the slab allocator from 2.6, replaced the slab allocator

![Memory_Fragmentation.svg]({{ site.images }}/Memory_Fragmentation.svg){:.my-block-wide-img}
![Linux_Slab_Allocation.svg]({{ site.images }}/Linux_Slab_Allocation.svg){:.my-block-wide-img}
