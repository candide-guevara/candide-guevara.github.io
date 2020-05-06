---
title: Linux, Xorg server and desktop session configuration
date: 2016-05-01
categories: [cs_related]
---

Just as involved as the kernel boot process, there are many stages and files involved in setting up the graphical desktop session.

* Xserver configuration [files][3] apart from the infamous xorg.conf
* Session manager configuration [files][4] **potentially superseeding the Xorg equivalents**
* Desktop system [enviroment][1] [variables][2]

![Linux_Startx_Config.svg]({{ site.images }}/Linux_Startx_Config.svg){:.my-block-wide-img}

[1]: https://userbase.kde.org/Session_Environment_Variables
[2]: https://userbase.kde.org/KDE_System_Administration/Environment_Variables#Troubleshooting_and_Debugging
[3]: https://wiki.archlinux.org/index.php/X_resources
[4]: https://wiki.archlinux.org/index.php/Xprofile
