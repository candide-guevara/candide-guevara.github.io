---
layout: post
title: Deadlock in concurrent programming
js_custom : math_notation
categories : [article, concurrency]
---

### Coffman conditions
A deadlock can occur only and only if all of the four conditions occur.

* Mutual exclusion : critical sections can only be entered by one thread/process at a time
* Hold and wait : a process holding a lock is allowed to wait for a resource
* No preemption : a process **cannot** be forced to yield its locks
* Circular dependency : $$ \{P_1, L_1\}\ wait\ on\ L_2 \to \{P_2, L_2\}\ wait\ on\ L_3 \to \{P_3, L_3\}\ wait\ on\ L_1 $$

### Preventing deadlocks
These techniques guarantee that concurrent processes will not deadlock.
* Lock acquisition order
* Lock free synchronisation : breaks the mutual exclusion condition

### Avoiding deadlocks
These techniques guarantee that the system will not allow a process to acquire a lock if can produce a deadlock.

* Banker's algorithm

