---
title: Network, Implementing a poor man's IaaS with PXE
date: 2015-06-02
categories: [cs_related]
---

We use this type of deployment strategy for some test systems. It stroke me as really simple but providing some basic IaaS functionality.
PXE relies on existing protocols DHCP and TFTP to locate and access the image to boot from. If you configure the linux init ram disk you
can boot diskless machines.

When you combine this with virtual machines you get a quick way to provision machines with the OS you choose.

![Arch_PXE_Diskless.svg]({{ site.images }}/Arch_PXE_Diskless.svg){:.my-block-wide-img}
