---
title: Windows, Active directory brain dump
date: 2019-03-24
categories: [cs_related]
---

On each new place I work there has to be an active directory.
Thank god I do not have to manage it, but I got tired of not understanding AD jargon.
(man I cannot believe I spent so much time learning this `cr*p`)

## Kerberos

It needs a ton of shared secrets for symmetric encryption.

### IMPORTANT : tickets are opaque tokens to the client

Otherwise the client could impersonate the KDC (key distribution server) or the services.

![Active_Directory.svg]({{ site.images }}/Active_Directory.svg){:.my-block-wide-img}
![Kerberos_Authentication_Permission.png]({{ site.images }}/Kerberos_Authentication_Permission.png){:.my-block-wide-img}
