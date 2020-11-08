---
title: Linux, Graphics stack and blank TTY of death
date: 2019-09-10
my_extra_options: [ graphviz ]
categories: [quick_notes]
---

I am trying to debug why when I switch to a terminal TTY I just get a blank screen.
AFAIK you can display text either via a console mode (character based) or by emulating a terminal on a framebuffer.
Here is my partial understanding of the graphics stack.

## The graphics stack for a stranger

### When using DRM/KMS

```myviz
digraph {
  node[shape=box]
  newrank=true
  subgraph cluster_userland {
    style=dashed
    label=<<b>userland</b>>
    libdrm [label="libdrm/libkms"]
  }
  subgraph cluster_kernel_api {
    style=dashed
    label=<<b>kernel api</b>>
    drm [label="DRM\nDirect Render Mgr\n(API for rendering)"]
    kms [label="KMS\nKernel Mode Setting\n(API for displaying)"]
  }
  subgraph cluster_logical_obj {
    style=dashed
    label=<<b>display pipeline logical repr</b>>
    fb [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms.html#c.drm_framebuffer_state"
      label="Framebuffer\nChunk of mem with pixel data\nMetadata: width*height, pixel format..."]
    plane [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms.html#c.drm_plane_state"
      label="Plane\nRepresents an area of the screen\nMetadata: fb rotation/scaling..."]
    crtc [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms.html#c.drm_crtc_state"
      label="CRT Controller\nDumps planes into display pipeline bus"]
    mode [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms.html#c.drm_display_mode"
      label="Display Mode\nMetadata: resolution,refresh rate...\n(What is output on HDMI port)"]
    encode [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms.html#c.drm_encoder"
      label="Encoder\nTransforms pixel data"]
    bridge [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms-helpers.html#c.drm_bridge"
      label="[OPTIONAL] Bridge ??\n(no clue of an example)"]
    connec [
      fontcolor=blue target=_blank
      href="https://www.kernel.org/doc/html/latest/gpu/drm-kms.html#c.drm_connector_state"
      label="Connector\n(fixed or hotplugable displays)\nCan be chained"]
  }
  subgraph cluster_physical_obj {
    style=dashed
    label=<<b>display pipeline hw</b>>
    mem [label="CPU/GPU memory"]
    cmd [label="Command queue ?\nTo configure card pipeline"]
    hdmi [label="HDMI port"]
  }

  libdrm -> {drm kms} [label="ioctl based API"]
  {drm kms} -> plane [style=invis]
  plane -> fb [arrowhead=none]
  plane -> crtc
  crtc -> encode
  crtc -> mode [arrowhead=none]
  encode -> bridge
  bridge -> connec
  connec -> hdmi
  fb -> mem
  {crtc encode} -> cmd

  {rank=same kms drm}
  {rank=same plane crtc encode bridge connec}
  {rank=max mem cmd hdmi}
}
```

### Non DRM/KMS view

```myviz
digraph {
  node[shape=box]
  subgraph cluster_userland {
    style=dashed
    label=<<b>userland</b>>
    labeljust=l
    unaccelerated_module [style=dashed]
    tty_shell_app
    xorg -> unaccelerated_module [style=dashed]
    xorg -> nvidia_x11_module [label="modesets on behalf of Xserver", fontcolor=red]
  }

  subgraph cluster_kernel {
    style=dashed
    label=<<b>kernel</b>>
    labeljust=l
    console_driver [shape=record,color=chartreuse,label=<???<br/>wtf is used as driver<br/>for console output>]
    nvidia_driver [shape=record,label=<{nvidia_driver|does both rendering<br/>and modesetting}>]
    uvesafb [shape=record,color=chartreuse,label="{uvesab|unversal fb driver ?|does it use kms/drm ?}"]
  }

  subgraph cluster_bootloader {
    style=dashed
    label=<<b>bootloader</b>>
    labeljust=l
    grub -> efi_video_module
  }

  subgraph cluster_gpu {
    style=dashed
    label=<<b>gpu</b>>
    labeljust=l
    vbios [shape=record,label="{VESA VBE API|vbios}"]
    wtf [shape=record,color=chartreuse,label=<???<br/>some component<br/>to handle OS driver<br/>on GPU side>]
    console_quest [shape=oval,color=chartreuse,label="where does this go ?"]
  }

  nvidia_x11_module -> nvidia_driver
  unaccelerated_module -> uvesafb [style=dashed]
  tty_shell_app -> console_driver
  uvesafb -> vbios
  efi_video_module -> vbios
  nvidia_driver -> wtf
  console_driver -> console_quest
}
```


## Problem resolution process

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
* Does the framebuffer reside in the card memory or in the CPU's memory ?

#### How can I poke inside the graphics stack ?

* [FAIL] `perf trace -e=ioctl` does not show anything when switching to a TTY
* [FAIL] There is nothing in `journalctl`
* [FAIL] There are no relevant kprobes to inspect KMS api (cf `/sys/kernel/debug/tracing/events`)

[0]: https://wiki.archlinux.org/index.php/NVIDIA#DRM_kernel_mode_setting

