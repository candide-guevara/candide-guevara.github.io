---
title: Linux, Blank TTY of death
date: 2019-09-10
my_extra_options: [ graphviz ]
categories: [quick_notes, linux]
---

Just noticed that before X11 modeset the display, linux is unable to show any text.
AFAIK you can display text either via a console mode (character based) or by emulating a terminal on a framebuffer.
Here is my partial understanding of the graphics stack.

* modesetting is the process of creating a framebuffer shared with the GPU, configured to the desired resolution/color/refresh...

```myviz
digraph {
  node[shape=box]
  subgraph cluster_userland {
    label=<<b>userland</b>>
    labeljust=l
    compliant_graphics_module [style=dashed]
    unaccelerated_module [style=dashed]
    tty_shell_app
    xorg -> compliant_graphics_module [style=dashed]
    xorg -> unaccelerated_module [style=dashed]
    xorg -> nvidia_x11_module [label="modesets on behalf of Xserver", fontcolor=red]
  }

  subgraph cluster_kernel {
    label=<<b>kernel</b>>
    labeljust=l
    console_driver [shape=record,color=chartreuse,label=<???<br/>wtf is used as driver<br/>for console output>]
    console_quest [shape=oval,color=chartreuse,label="where does this go ?"]
    nvidia_driver [shape=record,label=<{nvidia_driver|does both rendering<br/>and modesetting}>]
    uvesafb [shape=record,color=chartreuse,label="{uvesab|unversal fb driver ?|does it use kms/drm ?}"]
    kms [shape=record,label="{KMS|kernel modesetting API}"]
    drm [shape=record,label="{DRM|Direct Render Manager API}"]
    drm_driver [shape=record,label="{DRM_driver|example: nouveau}"]
    {drm kms} -> drm_driver
    console_driver -> console_quest
  }

  subgraph cluster_bootloader {
    label=<<b>bootloader</b>>
    labeljust=l
    grub -> efi_video_module
  }

  subgraph cluster_gpu {
    label=<<b>gpu</b>>
    labeljust=l
    vbios [shape=record,label="vbios framebuffer|vbios console"]
    wtf [shape=record,color=chartreuse,label=<???<br/>some component<br/>to handle OS driver<br/>on GPU side>]
  }

  framebuffer [shape=cylinder,color=red]
  nvidia_x11_module -> nvidia_driver
  compliant_graphics_module -> {drm kms} [style=dashed]
  unaccelerated_module -> uvesafb [style=dashed]
  drm_driver -> framebuffer
  uvesafb -> framebuffer
  efi_video_module -> framebuffer -> vbios
  nvidia_driver -> framebuffer -> wtf
  grub -> vbios
  tty_shell_app -> console_driver
  # console_driver -> vbios
}
```

### Facts

* grub is able to output in console and gfx mode
* `systemctl rescue` or switching to another TTY (via `ctrl-alt-f*`) returns a blank screen but the shell is running.
  * I can `reboot` the machine athough I cannot see what I am typing
* using nvidia proprietary drivers

### Failed attempts at solving the problem

* Boot in recovery mode with `nomodeset`
* Configure grub `terminal_output` to attempt to only use the console mode before reaching X11
* Activating [nvidia driver KMS][0] mode

### Unsolved questions

* What are the sofware components on the GPU besides the VBIOS ?
  * Are they updated somehow when I updated the OS graphics driver ?
* Is it possible configure linux to use only console mode ?
  * Is there any dependency with the bootloader ?
* Can I use `vesafb` or `efifb` to have fancy framebuffer terminal without nvidia driver ?

[0]: https://wiki.archlinux.org/index.php/NVIDIA#DRM_kernel_mode_setting
