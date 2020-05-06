---
title: Distributed systems, Microservice architecture
date: 2015-07-11
categories: [cs_related]
---

This is a mix of [Lewis and Fowler article][1] and my own experience on microservices.

## Services Vs Monoliths

{:.my-table}
| Monolith (Cons) | Services (Pros) |
|----------|----------|
| Build and deploy the whole application after any change | Build and deploy only affected components |
| Slow release cycle to integrate all code in monolith | Faster and uncorrelated releases of smaller services |
| Built using a single stack | Each service can use its own stack (ex: language) |
| Scale by deploying multiple copies of the monolith | Scale by deploying **only** many instances of bottle neck services |
| Programming interface to separate components | Service contracts to separate components (better isolation) |

{:.my-table}
| Monolith (Pros) | Services (Cons) |
|----------|----------|
| Simple to deploy and need few infrastructure | Complex to deploy and relies on infrastructure (service routing, application containers ...) |
| Allow fine grained coop between components (call overhead low) | Coarsed grained collaboration between services (network latency) |
| Consistent versioning between components (more predictable interactions) | Business flows got through different services and versions (many untested interactions) | 

## SOA Vs Micro services

{:.my-table}
| Service Oriented Architecture | Microservices |
|----------|----------|
| More strict contracts (ex: based on webservices) | Contracts designed to be easily changed (tolerant reader pattern, ex: adding optional fields to protocol buffer) |
| Orchestration delegated to service Bus | Services decide on their dependencies |
| N/A | Heavy user of virtualisation and container technologies |

## Dumb pipes and Smart end-points ?!
I think there are a number of advanced features any service bus should have.

* Service routing : route messages between services to the right node.
* Load aware routing : spread load across service instances
* Session affinity : queries from a client go to the same node to avoid over-replicating state.
* Flow tracing : monitor the service call tree for a given external client query

Some other can be implemented as services.

* Service discovery : this can be implemented as a meta-service
* Circuit breakers

## Technical architecture should be a mirror of human organisation
Services are a way to break Conway adage : "Large systems designed by companies will mirror their communication structures"

{:.my-table}
| Stack layers | Team organisation |
|----------|----------|
| Decentralized source control and data stores | Release when you are ready, do not wait for the rest of the company | 
| Full stack (presentation/backend/database) | Less team involved (more agility) to develop new features. Team are dedicated to a business product, not a layer of the system |
| Release and deploy automation | You build it, you run it. Developers get experience on operation constraints |

## Concept map

![Arch_Microservice_Concepts.svg]({{ site.images }}/Arch_Microservice_Concepts.svg){:.my-block-wide-img}

[1]: http://martinfowler.com/articles/microservices.html
