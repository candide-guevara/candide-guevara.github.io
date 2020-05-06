---
title: Linux, How to trace running processes
date: 2018-08-01
categories: [cs_related]
---

## Perf

### strace with perf

* Prints every syscall from running ls : `perf trace ls`
* Prints every call to read from every process in the system : `perf trace -a -e read`

### hardware counters with perf

Cache misses and cycle stall from running a python script :  
`perf stat -e "L1-dcache-load-misses,cycle_activity.cycles_no_execute" -- python -c 'print(2**15)'`

### kprobes with perf 

If you do not have kernel with debuginfo, you cannot refer to variables or function arguments by name.  
To see a list of kernel symbols : `less /boot/System.map-$(uname -r)`.
To know the type of arguments and their corresponding register (in x64 at least), you need to check [the source][0]

* List system-wide invocations to `do_sys_open` kernel function with second argument (filename)
```bash
perf probe --add='myopen=do_sys_open filename=+0(%si):string' # notice the assembler ptr dereference syntax !
perf trace --no-syscalls -a -e 'probe:myopen'
```

### tracepoints with perf 

Trace all schedulers switch invocations :

```bash
perf list | grep sched # looks for predefined scheduler tracepoints
perf trace --no-syscalls -a -e 'sched:sched_switch'
```

### uprobes with perf 

Trace invocations of readline function inside of bash shells processes.
If you do not have kernel with debuginfo, you cannot refer to variables or function arguments by name.

```bash
perf probe -x /bin/bash 'myreadline=readline'
perf trace --no-syscalls -a -e 'probe_bash:myreadline'
```

In the worst case you can always use absolute memory addresses :

```bash
objdump -tT /bin/bash | gawk '/readline/ && $4 == ".text" { print $0 }'
perf probe -x /bin/bash  'myreadline=0x0ad6d0'
perf trace --no-syscalls -a -e 'probe_bash:myreadline'
```

### usdt with perf 

You need the `sys/sdt.h` header to insert probes.

```c
#include <sys/sdt.h>
#include <string.h>

int main(int argc, char** argv) {
  int i = 0;
  while(i++ < argc) {
    int arglen = strlen(argv[i]);
    DTRACE_PROBE1(probe_group, probe_name, arglen);
  }
  return 0;
}
```

Compared to uprobes, there is an extra step to call `buildid-cache`

```bash
gcc -o usdt_test usdt_test.c
perf buildid-cache --add usdt_test
perf probe 'sdt_probe_group:probe_name'
perf list | grep "probe_name" # checks both the tracepoint and probe have been defined
perf trace --no-syscalls -e 'sdt_probe_group:probe_name' -- ./usdt_test "salut" "coco"
```

## BPF Compiler Collection (BCC)

TODO

## Resources

* [linux-traceing-systems](https://jvns.ca/blog/2017/07/05/linux-tracing-systems/)
* [linux-tracing-workshop](https://github.com/goldshtn/linux-tracing-workshop)
* [tutorial_bcc_python_developer](https://github.com/iovisor/bcc/blob/master/docs/tutorial_bcc_python_developer.md)

[0]: https://elixir.bootlin.com/linux/latest/source/fs/open.c#L1110

