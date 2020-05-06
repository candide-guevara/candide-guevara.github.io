---
title: Linux, TTY, sessions and process groups
date: 2016-04-24
categories: [cs_related]
---

What is the relation between TTY, sessions, [process groups][1] and child processes ?
This hierarchy is used to propagate signals and select which process output is displayed by a termninal.

All processes spawned by Bash share the same session. They generally have their own process group except for :

* Processes piped together : `cat mr_monkey | grep bananas`
* Processes inside a subshell : `( cat mr_monkey & cat banana_count )`

![Linux_Tty_Session.svg]({{ site.images }}/Linux_Tty_Session.svg){:.my-block-wide-img}

[1]: https://lwn.net/Articles/603762/
