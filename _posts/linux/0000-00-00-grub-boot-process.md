---
title: Linux, Booting with Grub in BIOS and UEFI
date: 2015-08-29
categories: [cs_related]
---

The following diagrams details the main step of the boot process:

* Different loading stages of GRUB
* Loading the compressed linux and [initial ram disk][3] filesystem
* [Kernel and PID1][2] configuration (cf `man bootparam`
* A few of the main components involved in user space init system

Then a couple reminders when changing [grub config][1]

![Linux_Grub_Boot.svg]({{ site.images }}/Linux_Grub_Boot.svg){:.my-block-wide-img}
![Linux_Grub_Install_Conf.svg]({{ site.images }}/Linux_Grub_Install_Conf.svg){:.my-block-wide-img}

[1]: http://www.gnu.org/software/grub/manual/grub.html#Simple-configuration
[2]: https://www.kernel.org/doc/Documentation/kernel-parameters.txt
[3]: https://www.kernel.org/doc/Documentation/filesystems/ramfs-rootfs-initramfs.txt
