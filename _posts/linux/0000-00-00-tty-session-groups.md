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

## How to kill all processes forked by a script

### Using `systemd-run`

[`systemd-run`][0] allows to run a command in a transient unit file.
All forked processes will be terminated when the service process ends or you call `systemctl --user stop <unit>`.

```bash
systemd-run --user \
  --name "<unit_name>" \
  --property=KillMode=mixed \
  --pty --same-dir --wait --collect --service-type=exec \
  bash "<script_path>"

# If you just want an interective terminal
systemd-run --user --shell

# All processes fored from the unit are in the same cgroup
cat "/sys/fs/cgroup/systemd/user.slice/.../<unit_name>/cgroup.procs"
```

### Using current session id

```bash
# get the session leader, if using `setsid` then $$ == $leader
leader=`ps --pid $$ --no-headers -o sid | sed 's/ //g'`
# Small flaw : allsid[@] contains the transient `grep` process :-(
# sid 0 translates to the current session
all_in_session=( `pgrep -s 0 | grep -Ev "$$|$leader"` )
kill -9 "${all_in_session[@]}"
# Check there are no survivors out there
pgrep -s 0
```

All processes that have forked or are in the background should be killed.
This should work indenpendently if you launch your script as :

* `setsid --wait bash script.sh` : may f\*ck up signal delivery, avoid if script needs user input
* `bash script.sh` : may kill background processes that were running on the interactive shell

### Using PID namespaces

```bash
# Maps $USER to root in a new user namespace. The script will think it is running as root.
unshare --map-root --pid --mount --fork --kill-child bash "<script_path>"

# Requires actual root privileges. Although script will be run under $USER.
sudo unshare --pid --fork --kill-child sudo -u $USER bash "<script_path>"

# To check the process in that pid namespace
lsns --type pid
pgrep --ns "<script_ns_pid>"
```

For the script running inside the namespace.

```bash
# Only works if $USER is mapped to root
mount -t proc proc /proc
pgrep --ns 1
```

[0]: https://www.freedesktop.org/software/systemd/man/systemd-run.html
[1]: https://lwn.net/Articles/603762/
