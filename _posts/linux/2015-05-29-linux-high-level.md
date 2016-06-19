---
layout: diagram
title: Linux training - high level view
categories : [diagram, linux]
diagram_list: [ Linux_High_Level.svg ]
---

### Kernel source tree
* Include - shared structures (ex task_struct), constants ...
* Kernel - OS features : scheduler, signals, synchronization primitives (mutex) ...
* MM - memory management : allocator, page map ...
* Arch - processor architecture dependent code
* Net - network stack : protocols, sockets
* Drivers - device drivers, further subdivided by categories (usb, video ...)
* Fs - filesystems (ext4, jffs2, fat ...)

## Built-in or loadable module
To avoid recompiling the kernel each time a new device is installed drivers can be loaded as kernel modules. The modules can be in the initial ram disk so that the kernel is not compiled with a potentially high number of fs modules (ext4, reiser ...) => initrd allows a same build to run in several machine configurations

* Vmlinuz - compressed kernel (single monolithic ELF executable) to make it smaller all symbols are removed. Contains minimal set of drivers required.

To load a module into the kernel

* Load the ELF object to kernel space
* Link object to kernel symbols (the only symbol visible have been explicitly declare with a macro in the kernel code)
* Add any module symbol to the exported kernel symbol table (for other dependent module)
* Strip the object from useless ELF sections to minimize kernel memory space
* Call module entry function to setup interface, register IRQ, set queues ...
* VFS allows loadable modules to provide an interface to user code without introducing a new sys call number (=> recompile)
 

