---
date: 2019-04-30
title: Network, sockets API programming
categories: [cs_related, network]
---

## [Call sequence][0] for server/client

![Network_Socket_API.svg]({{ site.images }}/Network_Socket_API.svg){:.my-block-img}

### Socket address structure "polymorphism"

```c
// More info at : man 7 ip/ipv6

struct sockaddr {
  sa_family_t     sin6_family; 
  char sa_data[14];
}

struct sockaddr_in {
  sa_family_t    sin_family; // AF_INET
  in_port_t      sin_port;

  struct in_addr sin_addr;
  struct in_addr {
    uint32_t    s_addr;
  };
};

struct sockaddr_in6 {
  sa_family_t     sin6_family;   // AF_INET6
  in_port_t       sin6_port;
  uint32_t        sin6_flowinfo; // RFC6294 admits this do not have a really consistent semantic
  uint32_t        sin6_scope_id; // holds nic id for link local addresses

  struct in6_addr sin6_addr;
  struct in6_addr {
    unsigned char   s6_addr[16];
  };
};
```

### The case for flow labels

The main idea is to be able to apply some kind of policy to the packets identified by the tuple : `(src_addr, dst_addr, flow_lbl)`
This enforces layer isolation since policy only have to look at layer 3. Applying policy based on the 5-tuple `(src_addr, src_port, dst_addr, dst_port, protocol)`
implies looking at transport layer.


## Interoperability IPv4/IPv6

### IPv6 server IPv4 client have some compatibility

{:.my-short-table}
| server listen addr | client connect addr | result |
|-|-|-|
| `::`                | `127.0.0.1`               | OK (client addr: `::ffff:127.0.0.1`) |
| `::`                | `<if routable addr ipv4>` | OK (client addr: `::ffff:<routable if>`) |
| `::1`               | `127.0.0.1`               | FAIL (err: connection refused) |
| `<routable ipv6>`   | `<anything ipv4>`         | FAIL (err: connection refused) |

### IPv4 server IPv6 client have NO compatibility

{:.my-short-table}
| server listen addr | client connect addr | result |
| `127.0.0.1`         | `::1`                     | FAIL (err: connection refused) |
| `0.0.0.0`           | `::1`                     | FAIL (err: connection refused) |
| `0.0.0.0`           | `<if routable addr ipv6>` | FAIL (err: connection refused) |
| `<routable ipv4>`   | `<anything ipv6>`         | FAIL (err: connection refused) |

### The strange case of link local addresses

{:.my-short-table}
| server listen addr | client connect addr | result |
| `<link-local ipv6>` | `<link-local ipv6>`       | FAIL (err: cannot bind srv socket, invalid arg) |
| `<link-local ipv6>`<br/>sockopt bind to nic dev | `<link-local ipv6>`       | OK |
| `<link-local ipv4>` | `<link-local ipv4>`       | OK |

You can check the addresses assigned to a NIC (and their scope) using the [ip command][1].

[0]:https://beej.us/guide/bgnet/html/multi/index.html
[1]:https://access.redhat.com/articles/ip-command-cheat-sheet

