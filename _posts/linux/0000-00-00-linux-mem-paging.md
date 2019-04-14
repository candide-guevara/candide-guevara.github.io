---
title: Linux training, virtual memory and paging
date: 2015-05-29
categories: [cs_related, linux]
---

* Flat memory model - hardware memory segments cover the whole address space. Used by Linux to avoid complex handling of segments
* Linear address - virtual address + process memory segment offset
* VPN - virtual page number. Page start address in memory
* TLB - translation lookaside buffer : a hardware cache to store linear page -> physical frame translations
  Besides the TLB modern processor have caches for **each level of the page tree**
* Page table walks - when the VPN is not found in the TLB the hardware/software scans the page table looking for it
* Multi-level page tables - the page table is contained in a tree structure to **reduce the memory overhead per process
  BUT page walks take more time**. 64bits linux uses a 4 level tree
* Major page fault - the page is not in memory and has to be loaded from disk.
  It can be the case for memory mapped files not in page cache or pages that have been swapped out.
* Minor page fault - **first access to page allocated by the process** and not mapping anything in disk.
  The OS just needs allocate a page frame and add an entry to the page table.

### Page size dilemma
* Problems with **small pages** - if the ratio page_size/total_mem is very low then there is an important memory
  and performance overhead. Page tables will consume more memory => longer page walks.
  Also higher TLB misses since there are so many pages to track.
* Problems with **huge pages** - copy on write are less effective. For example af forked process maybe block for some time
  when writing to its memory
* Huge pages - allocate some pages with 2Mb size (x64). Page tree has only 3 levels  

![Linux_Page_Tree.svg]({{ site.images }}/Linux_Page_Tree.svg){:.my-wide-img}
![Linux_Page_Fault_Algo.svg]({{ site.images }}/Linux_Page_Fault_Algo.svg){:.my-wide-img}
