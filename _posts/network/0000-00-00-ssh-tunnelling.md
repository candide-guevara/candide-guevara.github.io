---
date: 2020-03-30
title: Network, tunneling with SSH
categories: [cs_related, network]
---

It all started with an seemingly inocent ssh command : 
> `ssh -o "ProxyCommand ssh -o 'ForwardAgent yes' B 'ssh-add && nc %h %p'" C`

Understanding what that command actually did took me a whole day.

## Primer on SSH protocol

SSH is protocol has 3 components :

* [Transport layer (rfc 4253)][0] : encrypts connection (typically TCP) and authenticates ssh server.
  * After this step, the client can request to start a given [service][3]. Standard services 'ssh-userauth' and 'ssh-connection' are described below.
* [Authentication protocol (rfc 4252)][1] : authenticates ssh client on the remote machine.
* [Transport layer (rfc 4254)][2] : multiplexes authenticated user connection into channels to provide interactive shells, tunneling of TCP connections ...

![Network_SSH_components.svg]({{ site.images }}/Network_SSH_components.svg){:.my-block-img}


## Simple tunneling

The following demonstrates how to tunnel both ways using SSH.
* `-T` do NOT create a pseudo terminal
* `-N` do NOT run commands

```bash
### local_host ###
ssh -R 8888:localhost:8888 -L 8889:localhost:8889 -T -N remote_host &
nc -l localhost 8888 &
nc localhost 8889

### remote_host ###
nc -l localhost 8889 &
nc localhost 8888
```

![Network_SSH_tunneling.svg]({{ site.images }}/Network_SSH_tunneling.svg){:.my-block-img}

### Be careful it is a trap ! IPv6

* `nc -l 127.0.0.1` will listen [only for IPv4 connections][4]
* `ssh -R 8888:localhost:8888` __may__ attempt to connect using IPv6

### X11 server

> The Xserver running on __ssh client side__ must be invoked __without__ `-nolisten`. Otherwise it will only accept connections on unix sockets.

This basically works using reverse tunneling. However, SSH must understand the X protocol to a certain degree.

* SSH will create a dummy [Xauthority cookie][5] on the server side.
  * X protocol messages are forwarded to the client side, the cookie will be replaced by the real one.
  * The real cookie will never go through the wire.
* SSH will set `DISPLAY` environment var on the remote shell.
  * X applications use environment var [`DISPLAY`][6] (`hostname:display.screen`) to know which Xserver to connect to.

## ProxyCommand

Instead of using a TCP connection below [SSH transport layer][0], the [stdin/stdout of any program][7] can be used.
This is used to proxy ssh connections through a __bastion host__ (or jump host) running on a different machine.
3 different ways to achieve the same technique :

* `ssh -o "ProxyCommand ssh -T bastion_host nc %h %p" remote_host`
* `ssh -o "ProxyCommand ssh bastion_host -W %h:%p" remote_host`
* `ssh -J bastion_host remote_host` (only on newer ssh program versions)

![Network_SSH_proxycmd.svg]({{ site.images }}/Network_SSH_proxycmd.svg){:.my-block-img}

### Security characteristics

* The proxy only replaces the TCP connection. SSH [transport layer][0] and [user auth][1] will be done on top of it.
  * This means it will only see encrypted traffic flowing through it.
  * No keys must reside on `bastion_host` since [user auth][1] will be done in `local_host`.


## Authentication with ssh-agent

SSH private keys should be encrypted with a passphrase. This way they are stored encrypted on disk.
`ssh-agent` is a convinience program to keep the __unencrypted keys in memory__ for a given duration.
The keys can later be used for several ssh sessions __without user interaction__.
The ssh client can contact the ssh-agent daemon via environment vars :

* `SSH_AUTH_SOCK` : unix socket file used to contact the agent.
* `SSH_AGENT_PID` : PID of the current running agent.

> `ssh-agent` never transmits unencrypted keys to ssh clients. Instead it answers authentication challenges for them.

### ForwardAgent

`ssh-agent` traffic can be [forwarded via reverse tunneling][8]. This allows to keep all private keys on `local_host` even when using several __interactive ssh sessions__ to jump across machines.

![Network_SSH_forwardagent.svg]({{ site.images }}/Network_SSH_forwardagent.svg){:.my-block-img}

> This is NOT the same setup as for ProxyCommand.

### Forward agent vulnerability

An attaquer with root access on `remote_host_1` can use the unix socket to contact the `local_host` agent.
This will allow him to impersonate any user connected to `remote_host_1` using agent forwading.


## Mixing ForwardAgent, `ssh-add` and ProxyCommand

What does this [command][9] do ? `ssh -o "ProxyCommand ssh -A remote_host_1 'ssh-add && nc %h %p'" remote_host_2`

![Network_SSH_forward_add_proxy.svg]({{ site.images }}/Network_SSH_forward_add_proxy.svg){:.my-block-img}

> This can only work if keys are NOT passphrase protected. Otherwise ssh protocol wire data will contain garbage.


## SOCKS proxying

SSH can act as a [SOCKS proxy][10] (`-D` option). A SOCKS proxy acts as an __OSI layer 5 gateway__. It can forward any protocol above TCP (ex: HTTP).

Aside from the SOCKS headers that indicate where the connection should be forwarded to, the upper layers are opaque to the proxy.
For example, a SOCKS proxy will only see encrypted HTTPS traffic flow by.

### Example with HTTP

```bash
curl ifconfig.me
# output: 83.87.183.152
ssh -v -D 1080 -T -N remote_host
curl --socks5 localhost ifconfig.me
# output: 144.37.93.213
```

![Network_SSH_socks_proxy.svg]({{ site.images }}/Network_SSH_socks_proxy.svg){:.my-block-img}

> Note that the client application (here curl) MUST understand SOCKS. It needs to prepend the relevant SOCKS headers.

[0]:https://tools.ietf.org/html/rfc4253
[1]:https://tools.ietf.org/html/rfc4252
[2]:https://tools.ietf.org/html/rfc4254
[3]:https://tools.ietf.org/html/rfc4250#section-4.7
[4]:{% post_url /network/0000-00-00-sockets-api %}/#ipv4-server-ipv6-client-have-no-compatibility
[5]:https://www.x.org/releases/current/doc/man/man7/Xsecurity.7.xhtml#heading3
[6]:https://www.x.org/releases/current/doc/man/man7/X.7.xhtml#heading5
[7]:https://github.com/kennylevinsen/sshmuxd/wiki/ProxyCommand
[8]:http://www.unixwiz.net/techtips/ssh-agent-forwarding.html#fwd
[9]:https://serverfault.com/questions/337274/ssh-from-a-through-b-to-c-using-private-key-on-b
[10]:https://tools.ietf.org/html/rfc1928
