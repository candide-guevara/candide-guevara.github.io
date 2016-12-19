---
layout: post
title: Understand linux audio stack
categories : [ article, linux ]
css_custom: inline_images
---

Even if the linux audio stack is not as complicated as the graphics stack, I still had a hard time to know how to tweak my config from just reading the official documentation.
I will try to cover different views of the system.

* The stack from application to hardware
* The configuration mechanism
* The logical device hierarchy
* The common intefaces ALSA presents to an application

## The stack from application to hardware

![alsa_stack]({{ site.images }}/Linux_Audio_Stack.svg)

## Mismatch between configuration and logical pcm views

![config_vs_logical]({{ site.images }}/Linux_Alsa_Logical_And_Config_Views.svg)

## An example of configuration

{% highlight shell %}
  pcm.slave0 {
    type slave
    pcm "hw:2,0"
  }

  pcm_slave.slave1 {
    pcm "hw:2,0"
  }

  pcm.alsa_test {
    type plug
    #slave slave0       # KO pcm.slave0 {type slave}
    #slave slave1       # OK pcm_slave.slave1
    #slave.pcm "hw:2,0"
    #slave.pcm "dmix:2,0"

    #slave.pcm "pcm.default"        # not the same as cards.pcm.default
    #slave.pcm "cards.pcm.default"  # works but has never been defined

    #slave.pcm "cards.USB-Audio.pcm.iec958.0:2,4,130,0,2"
    #slave.pcm "cards.USB-Audio.pcm.front.0:2"
    #slave.pcm "cards.USB-Audio.pcm.default:2"

    #slave.pcm "pcm.iec958:2,0"
    #slave.pcm "cards.pcm.iec958:2,0"
  }
{% endhighlight %}

## Interfaces

* `/proc/asound` lists information about the hardware
* `/dev/snd` the pcm,ctl and other hardware devices
* `/var/lib/alsa/asound.state` status of hardware controls
* `aplay` to list alsa devices and play audio to a specific device

## Unresolved questions  

* The configuration seems to have some undocumented mechanisms
  * How do we know that `foo.bar.pcm.thingy` is a pcm interface ?
  * Is there something special about this identifier `pcm_pluginType`
  * The `cards` node has special behaviour, it somehow points to an existing pcm, and it is used for autoloading via `cards.@hooks`
* The link between configuration and hardware is not clear
  * Alsa package contains configuration for each card or card family but somehow there is automatic discovery to select the features in the config that are actually supported

## Sources

* [The different layers of the stack](http://tuxradar.com/content/how-it-works-linux-audio-explained)
* [A helpful overview](http://www.volkerschatz.com/noise/alsa.html)
* And of course [the always helpful arch wiki](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#Configuration)

