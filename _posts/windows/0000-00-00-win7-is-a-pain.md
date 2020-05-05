---
title: Windows problems setting up virtual machine
date: 2016-12-12
categories: [quick_notes, windows, rant]
---

## Fix Windows 7 update

They say that linux is complex to setup. Well looks like you struggle too in windows 7 "ultimate" ...

### How to launch a admin prompt

https://technet.microsoft.com/en-us/library/cc947813(v=ws.10).aspx

### How to fix error on eventlog

https://support.microsoft.com/en-us/kb/2545227

### How to install patch for windows update

* http://superuser.com/questions/951960/windows-7-sp1-windows-update-stuck-checking-for-updates
* You need to manually unselect the language packs

### How to delete /c/Windows/Logs/CBD

* These files will get huge and stop the upload process
* vboxmanage convertfromraw windows7.img windows7.vdi --format VDI --variant Fixed
* vboxmanage clonemedium disk --format RAW windows7.vdi windows7.img


Then wait for several hours for the update process to finish.
It takes about ten times more time to update win7 than to fully install fedora ...

