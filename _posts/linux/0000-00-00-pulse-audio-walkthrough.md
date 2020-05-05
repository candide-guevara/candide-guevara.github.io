---
title: Linux pulse audio
date: 2016-12-20
categories: [quick_notes, linux, audio ]
---

## Terminology

* module : shared objet providing features (alsa, send audio to network ...)
* sink : destination of audio stream (ex: alsa PCM device)
* monitor : "virtual source" attached to every sink to capture audio
  (ex: save audio from youtube video to file)

    client -> | source -> | sink 
              | module    | monitor

    client -> alsa -> pulse "card" -> alsa

## Controlling pulse audio

* pacmd : command line to see config change parameters and load modules
* paman : pulse audio manager GUI allows you to see clients, modules, sinks ...

## Unresolved

* Why KDE in "Audio and Video" system settings lists hardware devices instead of just pointing to pulseaudio ?

## Sources

* [Arch wiki](https://wiki.archlinux.org/index.php/PulseAudio)
* [PA latency](http://0pointer.de/blog/projects/pulse-glitch-free.html)
* [PA modules](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/)

