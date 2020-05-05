---
title: Linux, Hunting error logs during boot
date: 2020-04-12
categories: [quick_notes, linux]
---

I have this obession to know about kernel errors/warnings, even if my PC works fine.
At least you learn some interesting stuff.

## Huge pages

```
pmd_set_huge: Cannot satisfy [mem 0x383ff0000000-0x383ff0200000] with a huge-page mapping due to MTRR override.
```

* [MTRR][7] memory type range register, used by processor to determine type of memory (uncacheable, write-back...) behind an address range.
  * [MTRR][7] are mostly deprecated to PAT (page table attributes) which offers higher granularity
* [Memory range overlaps][8] between huge pages and MTRR caused the huge page to be split.
* However in this case, MTRR are set by the BIOS, they cannot be changed by the OS (even with kernel param `enable_mtrr_cleanup`)
  * Changing 32bit or 64bit PCI mapping on the BIOS influences `/proc/mtrr`

```
# 32bit PCI mapping
reg05: base=0x0f0000000 ( 3840MB), size=   32MB, count=1: write-through
# lspci
03:00.0 VGA compatible controller: NVIDIA Corporation GM204 [GeForce GTX 970] (rev a1) (prog-if 00 [VGA controller])
  Memory at f0000000 (64-bit, prefetchable) [size=32M]

# 64bit PCI mapping
reg05: base=0x383ff0000000 (58982144MB), size=   32MB, count=1: write-through
```

### Huge page conclusion

* Not sure what was linux attempting to map with a 1GB page.
* Not a big deal, I can live with a few extra 4K pages.

## UDEV

```
systemd-udevd[412]: /usr/lib/udev/rules.d/51-android.rules:549 The line takes no effect, ignoring.
systemd-udevd[453]: sdb: /etc/udev/rules.d/60-schedulers.rules:2 Failed to write ATTR{/sys/devices/pci0000:00/0000:00:1f.2/ata5/host4/target4:0:0/4:0:0:0/block/sdb/queue/scheduler}, ignoring: Invalid argument
cfg80211: Process '/usr/bin/set-wireless-regdom' failed with exit code 1.
```

### UDEV conclusion

* Bad formed android rules are caused by adb, not a big dealio
* Looks like the block device scheduler changed name from `noop` to `none` => FIXED
* 'regdom' refers to [regulatory domain][6] limitations on powerbands and tx power. Wifi works and has expected speeds.


## Firmware bugs

```
TSC ADJUST: CPU0: -8605093541 force to 0
TSC ADJUST differs within socket(s), fixing all errors
  #2  #3  #4  #5  #6
MDS CPU bug present and SMT on, data leak possible. See https://www.kernel.org/doc/html/latest/admin-guide/hw-vuln/mds.html for more details.
  #7  #8  #9 #10 #11
```

* TSC : [timestamp counter][3], a x86 register.
  * MDS : [Microarchitectural Data Sampling][4], a side channel attack.

### Firmware conclusion

* Boot param [`libata.noacpi`][5] to avoid TSC adjust warnings => __PC fails to boot__
* MDS mitigation flushes some buffers, it may impact perf, maybe disable ?


## EDAC : Error Detection And Correction

```
EDAC sbridge: CPU SrcID #0, Ha #0, Channel #0 has DIMMs, but ECC is disabled
EDAC sbridge: Couldn't find mci handler
EDAC sbridge: Failed to register device with error -19.
```

* EDAC are a set of [linux modules][0] to interface with hardware with error correcting capabilities and report error rates.
  * For example PCI bus or ECC memory
  * EDAC module may be statically linked (aka not displayed by `lsmod`), check `/lib/modules/$(uname -r)/modules.builtin`
  * Most desktops do not have ECC (check `sudo dmidecode -t 17`)
* [sbridge][1] refers to sandy bridge (intel arch). Turns out that `edac_sbridge` is the module config also for Haswell procs. 
* mci refers to [memory controller information][2] a linux `struct`.

### EDAC conclusion

* Nothing to worry since I do not have ECC.
  * try kernel boot param `edac_report=off` to see if logs get less verbose


## USB

```
usb 2-2.4: config 1 has an invalid interface number: 3 but max is 2
usb 2-2.4: config 1 has an invalid interface number: 3 but max is 2
usb 2-2.4: config 1 has an invalid interface number: 3 but max is 2
usb 2-2.4: config 1 has no interface number 2
hid-generic 0003:1852:7022.0005: No inputs registered, leaving
hid-generic 0003:1852:7022.0005: hidraw2: USB HID v1.00 Device [GFEC ASSP MyAMP] on usb-0000:00:14.0-2.4/input0
```

* USB devices present themselves using [configurations,interfaces, endpoints][9]
  * In this case my USB DAC present 1 configuration with 3 interfaces (audio control, audio stream, audio stream hidef)
  * Although I paid good money for it, the firmware devs did not comform to the USB spec, interface [ids should be sequential][10]
* HID human interface device : a type of USB interface
  * Again this complains about my USB DAC
  * Looks like the input declaration on the [report descriptor][11] are okish though
  * cf `hexdump -C "/sys/bus/usb/devices/<device>/<interface>/<id>/report_descriptor"`

### USB conclusion

* USB dac works fine, even the HID (not sure why since no inputs got detected)
* For the price I paid for the damn audio card, I would have expected usb2 support ...


## KDE

```
kscreen.kded: UPower not available, lid detection won't work
kded5[1037]: kscreen.kded: PowerDevil SuspendSession action not available!
powerdevil: Xrandr not supported, trying ddc, helper
backlighthelper[1229]: powerdevil: no kernel backlight interface found
powerdevil: org.kde.powerdevil.backlighthelper.brightness failed
powerdevil: The profile  "AC" tried to activate "DimDisplay" a non-existent action. This is usually due to an installation problem, a configuration problem, or because the action is not supported

kf5.kpackage: No metadata file in the package, expected it at: "/usr/share/wallpapers/Breath/contents/images/"
plasmashell[1093]: file:///usr/share/plasma/wallpapers/org.kde.image/contents/ui/main.qml:76:9: Unable to assign [undefined] to QStringList
plasmashell[1093]: file:///usr/share/plasma/wallpapers/org.kde.image/contents/ui/main.qml:75:9: Unable to assign [undefined] to int
plasmashell[1093]: file:///usr/share/plasma/wallpapers/org.kde.image/contents/ui/main.qml:75:9: Unable to assign [undefined] to int
plasmashell[1093]: file:///usr/share/plasma/wallpapers/org.kde.image/contents/ui/main.qml:76:9: Unable to assign [undefined] to QStringList
plasmashell[1093]: trying to show an empty dialog
plasmashell[1093]: file:///usr/share/plasma/shells/org.kde.plasma.desktop/contents/views/Desktop.qml:146:19: QML Loader: Binding loop detected for property "height"

plasma-nm: Unhandled active connection state change:  1

kdeinit5[1374]: kf5.kio.kio_tags: tag fetch failed: "Failed to open the database"
kdeinit5[1374]: kf5.kio.kio_tags: "tags:/" list() invalid url
```

* [xrandr][19] (Resize and Rotate) is a configuration tool for xsrever screens.
  * [ddc][20] (Display Data Channel) is a protocol to communicate with the monitor
* There are too many power management options.
  * To handle power events (like poweroff button) you can use [powerdevil][17], [acpid][18], [sytemd-logind][14], [TLP][15], [upower][16] (this one looks more like middleware)
* [kpackage][21] is an API for installation and loading of additional content (ex: scripts, images...)
  * no idea about this metadata deal ...
* [QML][22] is a declarative language that to build GUIs.
* [plasma-nm][23] is the networkmanager applet frontend
* [KIO][24] is an API for file access (local or via network)

### KDE Conclusion

* most warning related to power saving are not applicable to a desktop => dump powerdevil
* Do not care about KDE bugs (KIO, QML or applets), the stuff I use works fine


## Misc Cr\*p

```
thermal thermal_zone0: failed to read out thermal zone (-61)
kauditd_printk_skb: 20 callbacks suppressed
```

* `thermal_zone0` looks to be related to wifi (cf `/sys/class/thermal/thermal_zone0/type`)
  * Since this is pcie adapter into the mobo maybe it just cannot be read (even running `sensors-detect` again)
* kauditd is the kernel part of the [auditing framework][12]. kauditd communicates with user space via a [netlink socket][13].
  * Not sure why this is firing since I disabled all rules in '/etc/auditd/rules.d' (there is not even `/var/log/audit/*.log`)
  * Maybe somehow `systemd-journal` is getting those audit events ? (I disabled `audit.service` unit)

### Misc Cr\*p conclusion

* `auditd` is not needed
* although temperature sensors are broken for wifi card, it works ok

[0]:https://www.kernel.org/doc/html/v4.10/admin-guide/ras.html#edac-error-detection-and-correction
[1]:https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/edac/Kconfig#n225
[2]:https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/edac.h#n480
[3]:https://en.wikipedia.org/wiki/Time_Stamp_Counter
[4]:https://www.kernel.org/doc/html/latest/admin-guide/hw-vuln/mds.html
[5]:https://bugzilla.kernel.org/show_bug.cgi?id=199583
[6]:https://wiki.archlinux.org/index.php/Network_configuration/Wireless#Respecting_the_regulatory_domain
[7]:https://www.kernel.org/doc/html/latest/x86/mtrr.html
[8]:https://lwn.net/Articles/635357/
[9]:http://www.linux-usb.org/USB-guide/x75.html
[10]:https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/usb/core/config.c#n690
[11]:https://www.usb.org/sites/default/files/documents/hid1_11.pdf
[12]:https://wiki.archlinux.org/index.php/Audit_framework
[13]:https://en.wikipedia.org/wiki/Netlink
[14]:https://wiki.archlinux.org/index.php/Power_management#Power_management_with_systemd
[15]:https://wiki.archlinux.org/index.php/TLP
[16]:https://upower.freedesktop.org/docs/
[17]:https://docs.kde.org/trunk5/en/kde-workspace/kcontrol/powerdevil/index.html
[18]:https://wiki.archlinux.org/index.php/Acpid
[19]:https://wiki.archlinux.org/index.php/Xrandr
[20]:https://en.wikipedia.org/wiki/Display_Data_Channel
[21]:https://api.kde.org/frameworks/kpackage/html/index.html
[22]:https://doc.qt.io/qt-5/qmlapplications.html
[23]:https://github.com/KDE/plasma-nm
[24]:https://api.kde.org/frameworks/kio/html/index.html

