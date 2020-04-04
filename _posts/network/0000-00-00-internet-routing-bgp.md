---
date: 2019-04-17
title: Network, Routing packets through the internet
categories: [cs_related, network]
---

### Autonomous systems (AS) are the unit of routing for BGP

[BGP][0], the border gateway protocol is a **decentralized** protocol to route packets through the internet.
BGP operates on top of TCP connections between AS routers. 
It allows each peering router to discover the routes available through each of its neighboring ASes ([path vector][4]).
> Fun fact : the protocol first draft was drawn on [2 napkins at lunch][2] !

Some [figures on the network of interconnected AS][3] for 2018:

{:.my-short-table}
|                                    | IPv4     | IPv6     |
|------------------------------------|----------|----------|
| AS count                           | 60k      | 16k      |
| Route count                        | 700k     | 60k      |
| Average Route subnet size          | 20 prefix len => 4k | 32 prefix len |
| Average path len (diameter)        | 6        | 5        | 
| Highly connected nodes (>1k edges) | ~12      | ??       | 


## How routes are represented and propagated

{:.my-table}
| Address prefix   | Next Hop    | Origin AS | AS path(\*) | Preference attributes | Other attributes |
|------------------|-------------|-----------|-------------|-----------------------|------------------|
| 172.217.168.0/24 | 66.1.45.124 | AS15169   | 3302,3356,6666 | MULTI_EXIT_DISC (between AS)<br/>LOCAL_PREF (intra AS) | relating to route aggregation... |

> Note AS\_PATH can be a list of sequences and sets (due to [route aggregation][10])

### BGP route selection model

A BGP speaker will [rank, filter and select][11] incoming route advertissements (adjacent Route Information Base In). It will modify and propagate a subset of those routes (adj rib out).
**To avoid an explosion in the number of routes, only 1 route per destination is forwarded**

For example for a router belonging to AS6.

{:.my-table}
| Adj-RIB-In | Local RIB | Adj-RIB-Out |
|-|-|-|
| `11.22.33.0/24 AS1,3`<br/>`NEXT_HOP 72.12.48.1`   | KEEP | `11.22.33.0/24 AS1,3,6` (append my AS#)<br/>`NEXT_HOP 73.133.159.1` (choose next hop) |
| `11.22.44.0/24 AS1,6,2`<br/>`NEXT_HOP 66.25.35.1` | DISCARD !<br/>Loop in AS_PATH | NO PROPAGATION ! |
| `44.33.11.0/24 AS2`<br/>`NEXT_HOP 66.25.35.1`     | KEEP | `44.33.11.0/24 AS2,6`<br/>`NEXT_HOP 73.133.159.1` |
| `44.33.11.0/24 AS2,3`<br/>`NEXT_HOP 72.12.48.1`   | DISCARD !<br/>Longer AS_PATH | NO PROPAGATION ! |
| `22.33.44.0/24 AS4,3`<br/>`NEXT_HOP 72.12.48.1`<br/>`MULTI_EXIT_DISC 100`    | KEEP | `22.33.44.0/24 AS4,3,6`<br/>`NEXT_HOP 73.133.159.1`<br/>MULTI_EXIT_DISC is NOT propagated |
| `22.33.44.0/24 AS4,3`<br/>`NEXT_HOP 72.12.48.111`<br/>`MULTI_EXIT_DISC 1000` | DISCARD !<br/>Higher discriminator | NO PROPAGATION ! |

Which translates to the following network.

![Network_BGP_Graph.svg]({{ site.images }}/Network_BGP_Graph.svg){:.my-block-img}

### Route [leaks attacks][1]

If an AS peering routers advertise a route via themselves to an IP for a popular service like youtube they can mess-up routing for the whole traffic from neighbour ASes.


## External Vs Internal route propagation

Some big ASes (ex: amazon) will have a network that span multiple continents. So multiple BGP speakers peering with different other ASes.
**Route propagation inside an AS network is subject to different rules**.

![Network_BGP_Internal.svg]({{ site.images }}/Network_BGP_Internal.svg){:.my-block-img}

### Vanilla BGP requires internal speakers be fully connected

This requirement can be bypassed using [route reflection][6] or [confederations][5].

[0]:https://tools.ietf.org/html/rfc4271#section-3
[1]:https://blog.cloudflare.com/why-google-went-offline-today-and-a-bit-about/
[2]:https://www.computerhistory.org/atchm/the-two-napkin-protocol/
[3]:https://blog.apnic.net/2019/01/16/bgp-in-2018-the-bgp-table/
[4]:https://training.apnic.net/wp-content/uploads/sites/2/2016/11/eROU03_BGP_Basics.pdf
[5]:https://tools.ietf.org/html/rfc5065
[6]:https://tools.ietf.org/html/rfc4456
[10]:https://tools.ietf.org/html/rfc4271#section-9.2.2.2
[11]:https://tools.ietf.org/html/rfc4271#section-9.1
