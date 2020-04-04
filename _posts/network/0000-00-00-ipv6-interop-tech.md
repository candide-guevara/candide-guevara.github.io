---
date: 2019-05-05
title: Network, IPv6 interop/transition technologies
categories: [cs_related, network]
---

All interoperability techniques are a combination of the following :
* Dual stack : node (application) has both IPv4 and IPv6 addresses (maybe NOT globally routable)
* Tunneling : encapsulate IPv6 **packets** inside IPv4 or viceversa (cf [RFC4213][4])
* Translation : replace IPv6 **headers** with IPv4 or viceversa (cf [RFC6144][5])

## Framing the problem (cf [RFC6180][6])

The **problem space is huge** ! But you can reduce it to a combination of the following topologies.

![Network_Ipv46_Topologies.svg]({{ site.images }}/Network_Ipv46_Topologies.svg){:.my-block-img}

### Stateless or stateful **translation** (cf [RFC6145][7]) ?

Stateless is of course better in terms of scalability (faster header conversion and less memory on router).
* IPv4 -> IPv6 : It is easier to have a stateless translation by using one of the [countless IPv4 mapping schemes][8].
* IPv6 -> IPv4 : Since you cannot condense 128 into 32 bits you will most likely be [stateful][9] and taking into consideration the 5-tuple.
  * A notable exception is when the node has both an **IPv4 and IPv6 public addresses**

> Note **tunneling often needs no state** since the packet carries both address types.

### Tunneling considerations

[RFC4213][10] forbids a tunnel encapsulator to accept a client large IPv6 packet and fragment it if the IPv4 MTU of the tunnel is lower.
> Otherwise communication will be brittle since the decapsulator may NOT support fragment aggregation (breaks the Postel law)

Without adequate security policies, tunneling can bypass firewalls as follows :

![Network_Tunnel_Spoofing.svg]({{ site.images }}/Network_Tunnel_Spoofing.svg){:.my-block-img}

### DNS considerations

For nodes in IPv4/6 only networks behind a NAT you may need to use a proxy DNS to provide the appropriate A or AAAA records.
This will **break DNSSEC** and breaks user choice.


## Some well known interoperability recipes

### [RFC6333][15]: Dual stack lite

Allows ISP to have a IPv6 core network but still provide IPv4 connectivity with a limited pool of IPv4 addresses.

![Network_Ds_Lite.svg]({{ site.images }}/Network_Ds_Lite.svg){:.my-block-img}

### [RFC3056][14]: 6to4 (similar to 6rd)

Allows tunneling over the IPv4 internet without any static configuration.
It works by **embedding the tunnel endpoints IPv4 address** into the peer IPv6 address.

![Network_6to4.svg]({{ site.images }}/Network_6to4.svg){:.my-block-img}

[IPv6 rapid deployment][13] is based on the same ideas but it uses the ISP assigned prefix instead of `2002::/16`
and keeps tunnel endpoints inside the ISP network (not to rely on others to correctly configure their tunnels).

### [Many, many][3] more ....

* [464XLAT][11] : a IPv4 tunneled over IPv6 aimed at client-server traffic on IPv4 networks connected by the IPv6 internet
* [teredo tunneling][12] : a fancy (ass) mechanism involving several different types of network agents (relays, servers ...)
  * It does tunneling over UDP so it can punch through NATs

### Be careful it is a trap ! 6in4 != 6to4 != 6over4

* 6in4 relies on static admin configuration of tunnel endpoints
* 6to4 see above
* 6over4 is meant for communication inside an AS, it uses IPv4 as a **virtual layer 2**
> this trick allows to use SLAAC across 2 IPv6 segments joined by an IPv4 network

[3]:https://tools.ietf.org/html/rfc7059
[4]:https://tools.ietf.org/html/rfc4213#section-3
[5]:https://tools.ietf.org/html/rfc6144#section-2
[6]:https://tools.ietf.org/html/rfc6180#section-4
[7]:https://tools.ietf.org/html/rfc6145#section-5
[8]:https://tools.ietf.org/html/rfc6052#section-2
[9]:https://tools.ietf.org/html/rfc6146#section-3
[10]:https://tools.ietf.org/html/rfc4213#section-3.2
[11]:https://tools.ietf.org/html/rfc6877#section-4.1
[12]:https://tools.ietf.org/html/rfc4380
[13]:https://tools.ietf.org/html/rfc5969#section-4
[14]:https://tools.ietf.org/html/rfc3056#section-5.1
[15]:https://tools.ietf.org/html/rfc6333#appendix-B
