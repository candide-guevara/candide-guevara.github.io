---
date: 2019-05-24
title: Network, basic tooling examples
categories: [cs_related, network]
---

Some dummy examples of how to use common tools like `tcpdump`, `ip rule|route`, `iptables`, `netcat`....

> `iptables` is THE default firewall choice : `nftables` is unlikely to gain traction and [`bpfilter`][0] is still experimental

### Dropping packets sent to a network

```sh
# get the ip of a well knwon site
dig wikipedia.org
net=91.198.174.0
target_ip=91.198.174.192

# create a custom routing table to blackhole packets
ip route add blackhole "$net"/24 table 66
# create a rule using that routing table 66
ip rule add to "$net"/24 table 66
# check it worked
curl "http://$target_ip"
# restore to normal state
ip rule del to "$net"/24 table 66
ip route flush table 66
```

### Changing the source address of outgoing packets

```sh
old_ip=192.168.1.101
new_ip=192.168.1.102
net=91.198.174.0
target_ip=91.198.174.192

# add another address to your interface
ip addr add "$new_ip"/24 dev "$dev"
# append a rule to the nat table changing the source ip
iptables -t nat -A POSTROUTING -d "$net"/24 -j SNAT --to-source "$new_ip"
# connect to $target_ip binding source address to $old_ip
netcat -s "$old_ip" "$target_ip"
# check with tcpdump the src address is $new_ip
tcpdump -nn net "$net"
# restore to normal state
iptables -t nat -F
ip addr del "$new_ip"/24 dev "$dev"
```

### Listing open/listening sockets on local machine

```sh
lsof -i -U -nP
# -i list ipv4 and ipv6 sockets
# -U list unix sockets
# -nP do not resolve IP addresses nor port numbers

netstat -x64 -anp
# -x64 list unix, ipv4 and ipv6 sockets
# -a list listenning and established connections
# -n do not resolve IP addresses nor port numbers
# -p show program name and PID

ss -anp
# -a list listenning and established connections
# -n do not resolve IP addresses nor port numbers
# -p show program name and PID
```

## Packet handling architecture

![Network_Tooling.svg]({{ site.images }}/Network_Tooling.svg){:.my-block-img}

To know the details on the order of evaluations of `iptables` rules cf [this table][1]

[0]:https://lwn.net/Articles/747551/
[1]:https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture#which-chains-are-implemented-in-each-table
