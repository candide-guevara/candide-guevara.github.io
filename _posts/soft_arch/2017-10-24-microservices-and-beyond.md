---
layout: post
title: Microservices architecture lecture
categories : [ article, architecture ]
---

These are my notes for the 2-day training about microservice architectures given by Sam Newman.
It consisted on a selection of patterns to build a microservice based system and some others to migrate from a monolithic application.
The list of patterns include their pro/cons, domain of applicability and technologies that implement them.


### Definition of [microservice architecture][1]

The microservice architectural style is an approach to developing a single application as a suite of small services, each running in its own process and communicating with lightweight mechanisms, often an HTTP resource API. These services are built around business capabilities and independently deployable by fully automated deployment machinery.

### My feeling about the training

The trainer had excellent presentation skills and a broad knowledge derived from extensive consulting experience.
Although roughly 40% of the content was obvious, 60% did provide some valid insights.
It was mostly a lecture listing patterns, no hands-on training. It would have been nice to have some working code to bring back home ...


## Why microservices ?

Theoritically microservices architectures enable :

* Faster time to market : 1 team owns the service (less coordination), less risk per change
* Availability : services should be designed to mitigate the impact of unreachable dependencies
* Scalability and resiliency : scale horizontally only the services that are in your hotpath

On the other side you will struggle with :

* Testability : the number of dependencies needed to perform integration testing explode
* Monitoring and traceability : many logs, complex service call graphs
* Automation : service discoverability, deployment 
* Consistency : transactions and normalized data models are not available

The layer architecture (UI, business logic, persistence) favors competence based teams (middleware, db..).
This introduces change friction because each minor change has to be coordinated amongst several teams.
[Some studies][17] suggest a strong correlation between shared ownership and defects.


## Domain driven design (DDD)

When designing services you struggle between :

* High cohesion : logic is not duplicated across many services
* Loose coupling : services can evolve independently

Domain driven design is a method to split the system into micro services.
Because business domains change less often than the technology stack => interface stability.

Domain models should be confined to an explicit scope. It is not cost effective to define a model to the company scale.
[Bounded contexts][5] follow this idea by controlling the semantics of a given object across different parts of the organisation.
Example __customer__ model : On a retail site, a customer has different attributes for search, delivery, payment services.
If you build a service to handle all possible attributes of __customer__ then you introduce coupling between search, delivery, payment services.

## DDD methodology : [Event storming][6]

The event storming method is decomposes a system into bounded contexts.
Some guidelines :

* All stakeholders should be invited, not only developers
* You can focus on domain events or capabilities
  * event : client chose item to purchase
  * capability : present to client a list of purchasable items
* Keep the level of detail to what can be understood by a non-expert
* Use the same vocabulary as your customer and be clear on semantics for each (term, context) tuple


## Monolith migration

The most important metric is the number of services on your system.
It correlates to the investement needed in infrastructure to ease the pain of managing lots of independent services.
An interesting example is [gilt][3]. By plotting the number of deployed services vs headcount, you notice it took several years for this company to reduce the cost of adding new sevices.

Table wrapper anti-pattern : one way to decouple a piece of the database is to create that acts as a proxy to the table.
However the coupling introduced by the data schema is not solved by this pattern. 
The service proxying the database should expose methods to transition the data between valid states.

### How to identify code to migrate ?

You need to balance the ease of migration with the rate of change of the sub-system. There is no profit (other than experience) in migrating a sub-system that never changes.
These tools can provide some insights into code dependency, tech debt and even social metrics !

* [code scene][7] : datamines your github to output really interesting stuff
* [ndepends][8] : like [sonarqube][9] but maybe more advanced ?

### Patterns for monolith migration

* [strangler][10] (fairly obvious...)
* [data sharding][11] (no magic here either ...)

### Monoliths for [greenfields][0]

At the end of the day unless you have the right automation and experience, the monolith is always the fatest and cheaper way to start building value for your organisation.
Many fancy companies started like that ([etsy][14]).

Better have a [monolith with strong boundaries][15] in terms of code packaging and database schemas that can be evolved later.


## Service discovery

How do you enable communication between servers ?
Communication entails more than just knowing the endpoint and sending JSON/HTTP.

* Dynamic service discovery (and health pings)
* Call tracing
* Connection pooling
* [Circuit breakers][18]
* Fancy routing : staged rollouts, load balancing

You may distribute client libraries for each service, but it starts to get complicated on a polyglot environment.

### Service mesh (or side car pattern)

Service mesh is middleware to provide the advanced service discovery features above.
Recommended implementations : [linkerd][22], [istio][23].


## Choreography Vs Orchestration

Collaboration styles are related to messaging patterns

* Event based (publish/subscribe) asynchronous communication for choreography
* Request/response synchronous communication for orchestration

{:.my-table}
| Orchestration | Choreogaphy |
|---------------|-------------|
| self documenting business logic | code does not provide a complete picture of the business process |
| centralized error management | how can we even know the process actually finished ? |
| orchestrator has to know about all subcomponents, it will be involved in most of the changes | the only coupling between subcomponents is the event to listen to |
| no need for middleware | message broker/queue needed to distribute (persist?) the events |

The biggest shortcoming of the choreography collaboration is that you will **always need an orchestrator** to check all subcomponents finished correctly.
You need to limit the coupling introduced by this __reconciliation orchestrator__ by only listening to the end events pushed by each subcomponent.

To avoid shared state we can use the [data on the outside][19] pattern.

## Retry policy

On monoliths, most of the calls are local so the failure behaviour is binary, either it works or not.
On the contrary calls crossing microservices boundaries may have transient failures.
However the answer is not always to retry, on a complex call flow this with nested retry attempts can produce very high latency.

* Distinguish between client and servers errors : if the server replies the request is invalid, retrying will not help.
* You need a queue if you want to retry asynchronous flows

### Slow failure

This is on of the worst types of failures because it can block all of its callers.
Indeed, if threads are used by the callers to make service calls, a slow responding (or timing out) service will hog all resources.

* Use the [bulkhead pattern][26] to partition your resources based on who you are calling
* Use a self-healing circuit breaker : it lets a fraction of the trafic reach the faulty service to detect when it is back online
* Set the right timeouts : use the 90th percentile round trip time to have an idea on the order of magnitude
* Try to provide a graceful degraded mode if service is unavailable

If possible you can spool retry operations to be dequeued later or put a queue in the middle so that clients can enqueue and return independently of whether the service is online.


## Tracing, performance/business KPI, monitoring, alerting

To track complex call graphs you need to include a correlation id on each message.
You cannot always delegate this to your service mesh for asynchronous communication.
To avoid pain all log records should be consistent independently of the language used.
Include in your set of KPIs both technical and business metrics.

Do not only build alerts for errors. Define a model to define normal operation and use alerting to warn you when the system is not working normally.
Example : a KPI to indicate normal behavior may be the revenue generated per hour.

Some useful tools :

* [zipkin][29]
* [prometheus][30]


## Security

Microservices are a double edged sword when it comes to security.

* Increased surface of attack
  * Communication between services lends itself to man-in-the-middle or impersonation
  * Polyglot environments have a higher risk of an unpatched vulnerability
* Defence in depth by protecting each service individually an attacker needs to compromise more hosts.
  * [Codespaces horror story][27] : define multiple security domains.

### [Attack trees][28] : a methodology for threat modelling

* The roots of the trees are the goals an attacker may have
* Assign a profit to each goal
* The child nodes are the different methods to reach that goal
  * Iterate by attaching to the method nodes the actions needed
* Annotate each leaf node with the cost for the attacker
  * Propagate the costs to parent nodes by choosing the cheaper child

### Confused deputy attack

You need to enforce permissions based on both user and service.
Otherwise a service that is permissioned to access sensitive information may be used by an attacker.
If the attacker can request data for other users without a strong authentication proof, the data is not secure.


## Random bits of interesting stuff

* [morning paper][12] : a selection + summary of CS related papers
* [pat helland writings][13] : [data on the outside][20]
* [orleans][16]: an alternative for akka in .net (maintened by microsoft and support on azure), soon to have a version 2.0
* [consul][21] : a service discovery packed with features
  * DNS interface to have simple service discovery without any consul specific integration
  * Health checks to keep the list of services consistent
  * Datacenter and network topology (by tomography) aware
  * Also acts as a consistent key-value store
  * Templates : a text file with references to values stored in consul. The references will by resolved to the latest value automatically.
* [sock shop][24] : a demo application that can be deployed to aws, kuberneter, mesos, swarm to compare the different PaaS
* [weave scope][25] : yet another monitoring tool showing the runtime topology of your application and infrasctructure

[0]: https://en.wikipedia.org/wiki/Greenfield_project#Software_development
[1]: https://martinfowler.com/articles/microservices.html
[2]: https://bit.ly/ms-workshop-2017
[3]: https://www.infoq.com/presentations/scaling-gilt
[5]: http://www.informit.com/articles/article.aspx?p=2738465&seqNum=3
[6]: https://lh3.googleusercontent.com/-2x4VNk-s32g/UouhUvPHbWI/AAAAAAAAAi8/oicOlEmD7i4/w1405-h1123-no/Event+Storming+Cards+-+all.jpg
[7]: https://codescene.io/showcase
[8]: https://www.ndepend.com/features/
[9]: https://sonarcloud.io/dashboard?id=roslyn
[10]: https://paulhammant.com/2013/07/14/legacy-application-strangulation-case-studies/
[11]: http://queue.acm.org/detail.cfm?id=1394128
[12]: https://blog.acolyer.org/
[13]: http://queue.acm.org/detail.cfm?id=2884038
[14]: http://highscalability.com/blog/2014/7/28/the-great-microservices-vs-monolithic-apps-twitter-melee.html
[15]: http://samnewman.io/blog/2015/04/07/microservices-for-greenfield/
[16]: https://dotnet.github.io/orleans/Documentation/Introduction.html
[17]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr-2008-11.pdf
[18]: https://martinfowler.com/bliki/CircuitBreaker.html
[19]: https://www.confluent.io/blog/data-dichotomy-rethinking-the-way-we-treat-data-and-services/
[20]: http://cidrdb.org/cidr2005/papers/P12.pdf
[21]: https://www.consul.io/intro/index.html
[22]: https://linkerd.io/overview/
[23]: https://istio.io/about/
[24]: https://github.com/microservices-demo/microservices-demo
[25]: https://www.weave.works/docs/scope/latest/introducing/
[26]: https://stackoverflow.com/questions/30391809/what-is-bulkhead-pattern-used-by-hystrix
[27]: https://www.infoworld.com/article/2608076/data-center/murder-in-the-amazon-cloud.html
[28]: https://www.schneier.com/academic/archives/1999/12/attack_trees.html
[29]: http://zipkin.io/
[30]: https://prometheus.io/docs/introduction/overview/

