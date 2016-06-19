---
layout: diagram
title: Booting with Grub in BIOS and UEFI
categories : [diagram, linux]
diagram_list: [ Linux_Grub_Boot.svg, Linux_Grub_Install_Conf.svg ]
---

The following diagrams details the main step of the boot process:

* Different loading stages of GRUB
* Loading the compressed linux and [initial ram disk][3] filesystem
* [Kernel and PID1][2] configuration (cf `man bootparam`
* A few of the main components involved in user space init system

Then a couple reminders when changing [grub config][1]

[1]: http://www.gnu.org/software/grub/manual/grub.html#Simple-configuration
[2]: https://www.kernel.org/doc/Documentation/kernel-parameters.txt
[3]: https://www.kernel.org/doc/Documentation/filesystems/ramfs-rootfs-initramfs.txt

