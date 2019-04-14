---
title: Linux, Using BTRFS for data resilience
date: 2015-09-01
categories: [cs_related, linux]
---

A few weeks ago while moving my home from France to Switzerland, I realized something.
What would happen to my data in case of an unfortunate accident ? If I had a car accident on the way there,
I would not mind a few broken ribs. But it would be too painful to damage my hard drives in because of it.
Even if I made it safely to my new house, what if it caught fire a few months later ?

After looking around I decided to give [BTRFS][1] and Amazon Glacier a shot.

* BTRFS in RAID1 mode will protect against disk failures
* Glacier is a kind of insurance in case a group of angry gorillas storm into my place looking for bananas.
  Compared to what I pay for motorbike insurance, is a really good deal :-)
* BTRFS send/receive commands make it easy to backup delta snapshots on Glacier.

Anyway the diagram below details what I want to do. And yes all my partitions are named after characters in
[Valkyrie Profile][2].

![Linux_Btrfs_My_Setup.svg]({{ site.images }}/Linux_Btrfs_My_Setup.svg){:.my-wide-img}

[1]: https://lwn.net/Articles/576276/
[2]: http://valkyrieprofile.wikia.com/wiki/Valkyrie_Profile_Wiki
