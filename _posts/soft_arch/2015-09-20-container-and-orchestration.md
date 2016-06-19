---
layout: post
title: Containers and orchestration jungle
categories : [article, architecture, container]
---

Different container technologies and orchestration solutions for container deployment are announced every day.
It looks similar to the number of different component you can put on top of Hadoop. There are just so many
that you cannot keep track of them. To understand what each project is about you need a good knowledge of the
different parts of a container PaaS infracstruture.

## Competing technologies

### Containers
* Appc : container specification effort started by CoreOS. Contributors from Google, Redhat, Twitter...
* Docker : both a container image and build/deployment daemon
* Rocket (rkt) from CoreOs
* LXC (linux containers) : can be used by docker to run containers

### Orchestration
* Apache Mesos
* Google Kubernetes
* CoreOS Fleet

### All-in-one solutions
* Openshift / atomic
* Tectonic

### Other components
* etcd : distributed property storage using RAFT concensus algorithm. Used by Kubernetes

### Interesting articles
* Josh Berkus articles on [LWN][1]
* What's the deal between [Atomic and Openshift][2] ? 
* Conference videos : [CoreOS Fest][3], [Container Camp][4], [DockerCon][5]
* Container technologies : [Docker vs LXC][6]

[1]: https://lwn.net/Archives/GuestIndex/
[2]: https://blog.openshift.com/geard-the-intersection-of-paas-docker-and-project-atomic/
[3]: https://coreos.com/fest/
[4]: https://www.youtube.com/channel/UCvksXSnLqIVM_uFB7xyrsSg/playlists
[5]: https://www.youtube.com/user/dockerrun/playlists
[6]: https://www.flockport.com/lxc-vs-docker/

