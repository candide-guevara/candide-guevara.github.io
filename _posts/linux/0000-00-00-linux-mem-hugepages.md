---
title: Linux training, Huge page subsystem
date: 2015-05-29
categories: [cs_related]
---

![Linux_Huge_Pages.svg]({{ site.images }}/Linux_Huge_Pages.svg){:.my-block-img}

For configuration see [this article][0], [my sytemd unit][2] and [transparent huge pages doc][1]

## Memory mapping with mmap

{:.my-table}
| private/shared | file/anon | Huge allowed | Description |
|----------------|-----------|--------------|-------------|
| private | anon | OK | forked process will have the mmap region but will NOT see writes from parent |
| private | memfd | OK | same as above |
| private | file | NO | write to memory will NOT be persisted to the file |
| shared | anon | OK | forked process will have the mmap region but will see writes from parent |
| shared | file | NO | write to memory will eventually be persisted to file |

## Huge page memory inspection

* [This tool][5] inspects page frames (and their flags) for each vma of a process.

```sh
# Stats on transparent huge pages
grep thp /proc/vmstat
# Stats on pre-allocated huge pages
grep -i huge /proc/meminfo
# Mounted hugetlbfs
mount | grep huge
# THP parameters
cat /sys/kernel/mm/transparent_hugepage/*/* /sys/kernel/mm/transparent_hugepage/*
```

### FAQ

* Are all huge pages compound pages ? 
  * Looking at the page frame flags for the different types of allocation, it looks **yes**
* Can [huge pages be swapped][3] ?
  * Looks like currently will be split back to small pages when written to swap storage.
  * The reason is to minize cost of major page fault (copy whole huge page back from swap)
* Can [file mapped memory use huge pages][4] ? **nope**

[0]:https://lwn.net/Articles/374424/
[1]:https://www.kernel.org/doc/Documentation/vm/transhuge.txt
[2]:https://github.com/candide-guevara/handy-scripts-for-work/blob/master/configuration/shell_tools/huge_pages.service
[3]:https://lwn.net/Articles/758677/
[4]:https://lwn.net/Articles/789159/
[5]:https://github.com/candide-guevara/misc_labs/blob/master/hugepages/check_compound_pages.py
