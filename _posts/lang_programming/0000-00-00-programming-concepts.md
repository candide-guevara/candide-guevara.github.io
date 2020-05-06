---
title: Programming Concepts
date: 2015-05-25
categories: [cs_related]
---

### Programming languages
* Static typing - type information is associated to variables. It does not change and all types are known at compile time.
* Dynamic typing - type information is associated to data. Variable change types as they change their data. Data and type are only known at compile time
* Weak typing - data may be interpreted as a variable of any type (ex: long v = 'd')
* Strong typing - Both variable and data have an associated type, the language controls that assignments are not made between incompatible variable-data type pairs
* Runtime and indirection - any runtime mechanism seems to be implemented using indirection (virtual functions, member function calls, exceptions).

### Concurrency
* Contention - a resource being shared by several processes thus reducing performance (IO access, processor time ...)
* Critical section - block of code that read/writes a resource shared among threads/processes
* Race condition - event in which a critical section is run concurrently and may produce non-deterministic results.
  It may depend on the thread scheduling, hardware memory model, compiler optimizations
* Mutex - mutual exclusion lock, used to grant exclusive access to critical sections
* Futex - fast userspace mutex : kernel managed wait thread queue associated in userspace to an integer handle
* Spin lock - busy wait concurrent lock (ok for short waits => avoids scheduler overhead)
* CAS - compare and swap / check and save : synchronization primitive with checks data in the store has not changed since last read before updating
* Busy wait - waiting for an event without yielding the cpu resource (ex: polling in while loop)
* COW - copy on write : lazy memory paging technique to set shared memory between processes as read only. 
  When a process writes to it, the page fault handler will create a copy with write permission
* CPU bound process - a process which consumes all of its timeslice if not preempted, contrary to a IO bound process which blocks often waiting for a resource

### Memory
* Slab - Contiguous set of page frames mapped by a contiguous set of virtual pages
* Dirty data - data in a cache is dirty when modification in the cache has not been propagated to main storage. Contrary to "clean data"
* Cache coloring - color page frames with different color modulo the cache size so that pages with same color will compete for cache space.
  Try to map contiguous virtual pages to frames with different color to ensure data close together fits in the cache.

### Class VS prototype inheritance

{:.my-table}
| Class                                                              | Prototype                                                          |
|--------------------------------------------------------------------|--------------------------------------------------------------------|
| Class definition (fields and methods) and object instantiation are separate | Both fields, methods and construction are done in the constructor function |
| Class definition are not changeable at run time, the fields and methods are always the same | New fields and methods can be added to each object independently or to all objects sharing the same prototype object |
| Inherited class fields are writable by sub classes | Prototype object cannot be modified through the object that references it => setting values on a object does not affect all others sharing the prototype |
| Instances of sub classes do not reference the same objects coming from the class hierarchy | All object created from the same constructor function share a reference to the same proto object |

### Design by contract

Interaction between software components is materialized in a contract that specifies:

* Input (preconditions) / output properties
* Locks on resources acquired before client call
* Effects on the state of the called component after the client call (=postcondition)
* Component invariants (which must be true in all of its states)
* Control flow invariant: branches that should never be reached in certain scenarii

Contracts guarantee the Liskov substitution principle since subclass preconditions should not be stricter whereas post-conditions may have additional constraints
=> guarantees inheritance keeps type semantics

Difficult to implement contracts on called component state in concurrent programs, For example
in a stack used by several threads after the call to 'push' you may not have the post-condition size(before call) < size(after call)
since other clients may have done some 'pops' in the mean time.

Assertions are a way to guarantee the contract is respected, their goal is not recover from errors but to **fail-fast to allow easier debug**
=> not very adapted for a prod environment or to give clients friendly error logs

Assertions should **not produce any side effect** since they can be deactivated so they should not modify code behavior.


### Cloud computing
* Cloud - vague concept of an architecture that provides computing power to clients
* Elasticity - the cloud can grow or shrink depending on load
* On-demand - user pay only for the computation power he consumes
* High availability - the cloud is distributed hence it is fault tolerant Virtualization provides an abstraction layer between
  the physical cloud machines and the lower stack of the client application
* IaaS - infrastructure as a service : the cloud provides to the client virtual machine images where he can deploy its application servers
* PaaS - platform as a service : the cloud provides a framework (persistence layer, network interface ...) and running environment to develop a client application
* SaaS - The cloud directly provides an application the client does not have to deploy any code, for example facebook
* BPaaS - business process as a service : a whole business process is handled by a third party cloud, for example airlines using altea inventory
* Hypervisor - program managing the execution of several virtual machines (guest) on a physical machine (host),
  it may be a layer on top of the OS or replace the kernel layer completely ("bare metal")
* Chaos monkey - test resilience of a system by randomly taking down nodes, dependencies or other components
  and checking the system still provides valid answers to queries (used by Netflix)

### API Design
* Method chaining - Setter methods return the object they are bound to instead of void. This allows to call several methods in one statement
  Ex from D3js : select("p").data(['bla','blb'...]).style('font', '...').style('size', ...)
* Fluent API - an API designed to be read as normal language. Terms in a statement are interpreted in the context of the previous terms.
  Relies heavily on method chaining. It is similar to C++ overload mechanism (ex: cout << "coucou" << integer << endl)

### Math concepts (what is this doing here ?!)
* Predicate - an expression that evaluates to True or False but that do not have any bound variables
  Example: X is in France (monadic predicate) / X > Y (dyadic predicate)
* Predicate calculus - constructions that relate predicates between them
  Example: Given predicates P and Q => For x in X P(x), y in B like Q(y)
* Arity - the number of arguments a function or operator accepts

