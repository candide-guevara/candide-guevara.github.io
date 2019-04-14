---
title: Linux training, debugging
date: 2015-05-31
categories: [cs_related, linux, debug]
---

Small diagram of the main components of GDB and their interaction with Linux and the hardware.

* Watchpoint - a breakpoint triggered by access to data (read, write ...). Software impl is slow (step-by-step)
  
![Linux_Gdb_Debugger.svg]({{ site.images }}/Linux_Gdb_Debugger.svg){:.my-wide-img}
