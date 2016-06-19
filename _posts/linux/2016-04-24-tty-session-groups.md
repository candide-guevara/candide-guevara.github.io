---
layout: diagram
title: TTY, sessions and process groups
categories : [diagram, linux]
diagram_list: [ Linux_Tty_Session.svg ]
---

What is the relation between TTY, sessions, [process groups][1] and child processes ?
This hierarchy is used to propagate signals and select which process output is displayed by a termninal.

All processes spawned by Bash share the same session. They generally have their own process group except for :

* Processes piped together : `cat mr_monkey | grep bananas`
* Processes inside a subshell : `( cat mr_monkey & cat banana_count )`

[1]: https://lwn.net/Articles/603762/

