---
date: 2020-04-10
title: Network, Connecting racks on a datacenter
categories: [cs_related ]
---

Being a filer admin entails speaking with datacenter engineers. Hopefully this will help with some of the acronynms.

## Connecting to TOR switches

![Network_Rack_Cabling.svg]({{ site.images }}/Network_Rack_Cabling.svg){:.my-block-img}

### Transceivers modules

![SFP_Module](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/SFP_SR_CISCO.jpg/337px-SFP_SR_CISCO.jpg){:.my-inline.img}
![QSFP_Module](https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/QSFP28-100G-SR4.jpg/640px-QSFP28-100G-SR4.jpg){:.my-inline.img}

As seen on the diagram above, each module may implement a different ethernet physical layer.
This decoupling allows switches and other networked devices to support both copper and fiber.

### What are the "modes" in multimode fiber ?

> Contrary to my initial belief, multimode has NOT higher bandwidth. It is just cheaper.

A mode refers to the angle of incident of the light source into the fiber.
Not to be confused [wavelength division multiplexing][0].
The reason to have multimode is __cheaper manufacturing__ : light sources need to be less precise and fiber cores have a higher radius compared to single mode.

AFAIK, [mode division multiplexing][1] is not used to increase bandwidth.
On the contrary multimode fibers are limited in range and frequency due to [intermodal dispertion][2].

## Patch panel connections

> Do NOT confuse _fiber polarity_ with _light polarisation_ !

Dual LC, as the name implies, has 2 fibers for full duplex.
Problemo : how do you make sure __RX/TX fibers go from device to device__ correctly ?

![Dual_LC_Cable](https://img-en.fs.com/community/upload/wangEditor/201911/08/_1573185648_GFr5V6kMjh.jpg){:.my-inline.img}
![MPO_Trunk_Cable](https://img-en.fs.com/community/upload/wangEditor/201911/08/_1573185614_8oDxRsU5GT.jpg){:.my-inline.img}

This problem gets complicated when connecting devices __across racks via patch panels__.
There are different [connectivity methods][3], below is just one of them.

![Network_PatchPanel_Cabling.svg]({{ site.images }}/Network_PatchPanel_Cabling.svg){:.my-block-img}

[0]:https://en.wikipedia.org/wiki/Wavelength-division_multiplexing
[1]:https://www.rp-photonics.com/mode_division_multiplexing.html
[2]:https://www.rp-photonics.com/intermodal_dispersion.html
[3]:https://community.fs.com/blog/understanding-polarity-in-mpo-system.html

