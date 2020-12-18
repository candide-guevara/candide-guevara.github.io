---
title: Linux, Steam runtime problemo
date: 2020-12-16
my_extra_options: [ graphviz ]
categories: [cs_related]
---

## The many layers to launch a game

Starting with proton 5.13 steam always launches games inside a sort of container prepared by [pressure-vessel][0]
(a sort of fork from [flatpak][2]). This container is called a 'steam runtime' : an [introduction talk to runtimes][1].

```myviz
digraph {
  rankdir=BT
  node [shape=box]
  subgraph cluster_host {
    label="Host System"
    color=green
    style=dashed
    othr_lib [label="Other system libs"]
    grap_lib [label="Graphical stack libs"]
    runt_tar [
      fontcolor=blue
      href=":https://repo.steampowered.com/steamrt-images-soldier/snapshots/" target=_parent
      label="Runtime tarball"]
  }
  subgraph cluster_runtime {
    label="Steam runtime (soldier)"
    color=green
    style=dashed
    link_lib [label="Symlinks to graphical stack"]
    runt_lib [label="Runtime libs\n(replaces native libs)"]
  }
  subgraph cluster_wine {
    label="Wine runtime"
    color=green
    style=dashed
    emul_dir [label="WINEPREFIX\n(emulated windows folder\nhierarchy)"]
    emul_lib [label="Wine re-implementation\nof windows libs"]
    real_lib [label="Windows real libs\n(.net, ucrtbase c++ runtime)"]
    prot_lib [label="Proton libs\n(not sure what is\nadditional to wine)"]
    game_bin [color=red penwidth=2
      label="Windows native game binaries"]
  }
  pres_ves [label="pressure-vessel"]
  bwrp_bin [label="Bubblewrap\n(util to create containers\nno root privilege needed)"]
  note_real_lib [color=grey
    fontcolor=blue
    href="https://github.com/Winetricks/winetricks" target=_parent
    label="Can be installed by winetricks.\nNot included in wine\nby default"]
  note_prot_lib [color=grey
    fontcolor=blue
    href="https://github.com/ValveSoftware/Proton/blob/proton_5.13/proton" target=_parent
    label="Can be configured via user_settings.py"]

  runt_tar -> pres_ves -> bwrp_bin
  bwrp_bin -> {link_lib runt_lib}
  grap_lib -> link_lib [arrowhead=none]
  {emul_lib real_lib prot_lib} -> emul_dir
  emul_dir -> game_bin

  prot_lib -> note_prot_lib [arrowhead=none color=grey]
  real_lib -> note_real_lib [arrowhead=none color=grey]

  note_prot_lib -> note_real_lib [style=invis]
  runt_lib -> prot_lib [style=invis]
}
```

## Some problemos while running games

There are several families of errors: problems setting up the steam runtime,
missing functionality on the wine libs reimplementations, or plain old crashes of binaries.

### The [`fcntl ADD_SEALS`][4] problemo

> This broke the very start of pressure-vessel runtime init.

The flatpak code inside `pressure-vessel` has [some routines][3] to put stuff into "anonymous tmpfs files".
It then calls `fcntl(ADD_SEALS)` to prevent the contents from being modified. It looks like this snippet.

```c
void buffer_to_sealed_memfd_or_tmpfile (const char  *name,
                                        const char  *content,
                                        size_t      len) {
  int memfd = memfd_create (name, MFD_CLOEXEC | MFD_ALLOW_SEALING);
  ftruncate (memfd, len);
  write (memfd, content, len);
  lseek (memfd, 0, SEEK_SET);
  errno = 0;
  fcntl (memfd, F_ADD_SEALS, F_SEAL_SHRINK | F_SEAL_GROW | F_SEAL_WRITE | F_SEAL_SEAL);
  perror("fcntl result: ");
}
```

`fcntl(ADD_SEALS)` fails with `EBUSY` if the memory of the file has any direct mapping.
Not sure why, but this is always the case when [THP for shmem][5] is "always" enbaled.

### Network drop problemo

> Broke AOE2 multiplayer.

Wine reimplementation of the c++ runtine is not perfect. For some games it is better to use the real deal.

* You can [install it manually][7] (you need to knwo the correct version of visual c++ compiler used by the game)
* You can use [winetricks][6] to install it (can also install .net which is good because the mono in wine fails in many games).
  * Not sure I am confortable with winetricks going and fetching random stuff from the internet and installing it on my machine.
  * Maybe I could sandbox it somehow ?

### Pagefault problemo

> Likely cause of game freezes on AOE2 ? Note some read page fault seem benign.

Randomly, after about 20mins of gameplay, the game would freeze with :

```
Unhandled exception: page fault on execute access to 0x054fb120
```

Seems solved with the release of proton 5.13.


## Some steam kung-fu to debug game issues

### Controlling wine logging via `user_settings.py`

> WARNING: Each version of proton has its one copy of `user_settings.py`

With a bit of [python coding][9] you can choose some proton and wine options for each game launched based on its numerical [steam id][8].
See [this doc][10] to know how to tweak the `WINEDEBUG` env var. Looks like [SEH structured exception handling][10] is most useful for crashes ?

### Getting a shell inside the steam runtime container

* To run `strace` on the creation of a runtime container (without running any game).
```sh
pushd "$STEAM_LIB/steamapps/common/SteamLinuxRuntime_soldier"
strace --decode-fds --trace=fcntl,memfd_create --follow-forks -o strace.log \
  ./run-in-soldier cat /etc/os-release`
```

* To get verbose logging while building the steam runtime container.
  * `PRESSURE_VESSEL_VERBOSE=1 steam > pressure_vessel.log 2>&1`

* To get a pressure-vessel GUI with launch options. You can for example choose to get an `xterm` before the game launches.
  * `PRESSURE_VESSEL_SHELL=instead PRESSURE_VESSEL_WRAP_GUI=1 steam > steam.log 2>&1`
  * Do `echo "$@"` to see the actual command to run the game

### Checking FSYNC and ext4

There are a couple of kernel patches dvelopped to reduce wine layer overhead.

* [FSYNC (futex waint multiple)][12] : works out of the box on (linux5.9, proton5.13)
  * Check it is enabled `grep fsync "steam-${GAME_ID}.log"`
  * Check the running kernel has the needed syscall `grep -i 'futex_wait_multiple' /proc/kallsyms` 
* [Case insensitive filesystem][13] (on a per directory basis).
  * Have the steam library installed on a `ext4` fs to ge teh best support.
  * As of linux5.9 not enabled, cannot set the needed fs option.
  * `sudo tune2fs -O casefold -E encoding_flags=strict "<device>"`

[0]:https://gitlab.steamos.cloud/steamrt/steam-runtime-tools/-/tree/master/pressure-vessel
[1]:https://archive.fosdem.org/2020/schedule/event/containers_steam/
[2]:https://archive.fosdem.org/2018/schedule/event/flatpak/
[3]:https://github.com/flatpak/flatpak/blob/master/common/flatpak-utils.c
[4]:https://github.com/flatpak/flatpak/issues/3409
[5]:https://www.kernel.org/doc/html/latest/admin-guide/mm/transhuge.html#hugepages-in-tmpfs-shmem
[6]:https://github.com/Winetricks/winetricks
[7]:https://github.com/candide-guevara/handy-scripts-for-work/blob/master/configuration/steam/patch_aoe2_de.sh
[8]:https://steamdb.info/app/813780/
[9]:https://github.com/candide-guevara/handy-scripts-for-work/blob/master/configuration/steam/user_settings_5_13.py
[10]:https://wiki.winehq.org/Wine_Developer%27s_Guide/Debug_Logging#Controlling_the_debugging_output
[11]:https://wiki.winehq.org/Wine_Developer%27s_Guide/Kernel_modules#Structured_Exception_Handling
[12]:https://lkml.org/lkml/2019/7/30/1399
[13]:https://www.collabora.com/news-and-blog/blog/2020/08/27/using-the-linux-kernel-case-insensitive-feature-in-ext4/
