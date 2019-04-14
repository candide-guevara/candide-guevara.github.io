---
title: Network, IP address and VLAN 101
date: 2019-03-30
categories: [cs_related, network]
---

I do not usually deal with VLANs, IPv4/6 ... but when I do, maybe I can remember some of this.

## IPv6 101

### What's the deal with the ':' in IPv6 ?

IPv6's 128 bits are represented as 8 groups of 4 hex chars, separated by `:`.
Consecutive `:` denote 1 or more groups with value 0. `::` can **only appear once** (otherwise ambiguous).
> `0000:0000:0000:0000:0000:0001:0002:0003` => `::1:2:3`  
> `fe80:0001:0000:0000:dead:beef:dead:0000` => `fe80:1::dead:beef:0`

### Network and subnet

`/` notation is used to denote the network prefix.
> `fe80::/64` denotes all addresses like `fe80:0:0:0:X:Y:W:Z`

**Standard dictates maximum prefix length of `/64`** (otherwise stateless configuration protocols break).
* This allows a subnet address to be unique (although not mandatory) across the whole internet !

### MAC, EUI-48, EUI-64, wtf ?!

* MAC = EUI-48
* You can transform EUI-48 into EUI-64
> `de:ad:aa:cc:be:ef` => `dead:aa` + `ff:fe` + `cc:beef`  
> Invert bit at index 6 (start from left)  
> `dead:aaff:fecc:beef` => `11011110 ad:aaff:ccfe:beef` => `11011100 ad:aaff:ccfe:beef` => `dcad:aaff:ccfe:beef`
* EUI-64 transformation is a stateless way to obtain an **unique IP within a subnet**

## Special IP ranges

### Multicast address semantics

Stateless auto configuration in IPv6 is based on **well known multicast groups**.
A multicast address can be decomposed as follows :

```
ff<4-bit flag><4-bit scope><16-bit reserved><64-bit network id><32-bit group id>
```

Where scope denotes the part of the network addressed.
* 0x1 interface local loopback
* 0x2 link local (L2)
* 0x8 organisation local
* 0xe global internet

Some well known link local well known multicast groups :
* All nodes in link : `ff02::1`
* All routers in link : `ff02::2`

{:.my-table}
|         | IPv4 | IPv6 |
|---------|------|------|
| Multicast | `224.0.0.0` - `239.255.255.255` | `ff?:?:?:?:?:?:?:?` |
| Anycast | NO dedicated range | NO dedicated range |
| Link-local | `169.254.?.?/16` | `fe80:0:0:0:?:?:?:?/64` |
| Private | `10.?.?.?/8`<br/>`172.16.0.0/12` - `172.31.255.255/12`<br/>`192.168.?.?/16` | `fc?:?:?:?:?:?:?:?` - `fd?:?:?:?:?:?:?:?` |
| IPv4 mapped | N/A | `::ffff:0:?:?` when translated by network agents<br/>`::ffff:?:?` when mapped by host dual stack |
| Any address | `0.0.0.0` | `::` |
| Localhost | `127.0.0.1` | `::1`<br/>`ff01::` interface local multicast |
| Broadcast | `255.255.255.255` | Deprecated in favor of multicast<br/>`ff0e::` internet scope multicast prefix |

## Isolating L2 segments using VLANs

![Network_VLAN.svg]({{ site.images }}/Network_VLAN.svg){:.my-wide-img}
