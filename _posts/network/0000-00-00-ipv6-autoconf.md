---
date: 2019-05-02
title: Network, IPv6 auto configuration
categories: [cs_related, network]
---

## Stateless auto configuration (SLAAC)

SLAAC is preferred over DHCPv6 for simple setups. It also replaces ARP for discovering layer 2 addresses given an IP.
It is based on a new set of [ICMPv6][0] message [Neighbor Discovery][1] and [Router Advertisement][2] types.

![Network_SLAAC.svg]({{ site.images }}/Network_SLAAC.svg){:.my-block-img}

The advantage of this method is that it requires **no dedicated server for keeping state** (although each node has to get smarter to handle solicitations/advertisements).

[0]:https://tools.ietf.org/html/rfc4443
[1]:https://tools.ietf.org/html/rfc4861#section-4
[2]:https://tools.ietf.org/html/rfc6106#section-5
