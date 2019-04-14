---
title: Nosql several database implementations
date: 2015-05-28
categories: [cs_related, database]
---

### CouchDB : Json document oriented NoSQL DB
* RESTFull http api (get, put, post ...)
* Queries done through map reduce in javascript
* NOT partitioned only replication across nodes
* Can act as a simple web server since it servers json (couch apps)
* First implem in C++ then in erlang

### Cassandra - column based DB
* Developed by facebook then apache project
* Structure : keyspace -> column families
* Query : by row you can ask a slice of the columns (no order for keys by default)
* Consistent hashing : data distributed according to hash of key each node is responsible for a range

### NoSQL storage families
* Key/Value (blob)
* Column based (first col primary key)
* Key/Document (like blob but structure of data understood by DB)

### Neo4J : java graph DB
* Storage : data structured in nodes and relationships (directional or not), both can contain a key value property map
* Cypher : new query language to traverse graph
* Visualization : graph data can be exported to visualization tools (gephi, cytospace ...)
* Concurrency : supports ACID transactions
* Sharding : graph db difficult to partition due to traversal going to several nodes
* Indexing : any node/relation property can be indexed

### MongoDB
* Storage : BSON documents (binary json) with custom types (ex dates), limited in size (currently 16Mo). 
  **Documents are schema-less.** Similar structured docs are stored in a collection. A db can have several collections.
* Caching : by default Mongo will try to memory-map ALL data (docs, indexes...) to avoid disk access. It will use all free memory on the machine
* Indexing : supported on any field of a document, even embedded ones. Transparent to the user if the Index field is an array or scalar value.
  Indexes are taken into account for query optim. There are important limitations to be aware of.
* Consistency : in non replicated mode there is strong consistency (write lock prevent reads), if the database is replicated
  there is eventual consistency, since reads routed to the primary if possible. Even in replicated mode we can have good consistency
* Replication : data can be replicated on a set of nodes, with one primary node handling writes.
  Primary election ensures a secondary node is promoted to primary in case of failure
* Querying : dedicated language based on json objects but with features added on top to allow complex queries/updates
  (Ex db.inventory.find( { type: 'food', price: { $lt: 9.95 } } ) we find the food docs which price is less than 9.95).
  **Queries return docs from a single collection.**
* Concurrency : **data modification is atomic at document level**. Hence locking also at doc level.
  Read locks do not block other reads but block writes. Write locks are exclusive. By default clients are configured
  for non-acknowledged writes (fast!) but a sort of dynamo's (r,w,n) can be used to.
* Sharding : transparent to the application since it does not connect directly to the shards but to a query router (mongos),
  that redirects to the appropriate shard(s). Auto/custom sharding criteria supported. Auto sharding when data set grows.
* Map reduce : More for batch type processing. Input can only come from a single collection. Supported on sharded collections.
 
### Couchbase
* From the creators of couchDB and memcached it is mix between a key-value and document store with production features like cross data center replication, clustering ...
* Storage : JSON document store (limit 20Mo). Sets of documents are divided in buckets (=~ database not bound by type).
  A bucket contains design documents which contain several views. Append only store with asynchronous compaction.
* Clustering : all nodes are the same (no master), each node acts a shard and as a replica for data in another shard.
  Client drivers are aware of the topology.
* Sharding : based on hashed document id (no targeted queries even with views).
  Reads on a node are only allowed for the shard of data it is responsible (not for replication data).
* Consistency : strong only for reads using primary key. Replicas and views are eventually consistent.
  Queries using views do not have read-your-write consistency by default.
* Indexing : there are **no indexes but views** which link any user defined key to any value computed from the document.
  Without views Couchbase only support retrieval of docs through the primary Key (like memcached). **Views are stored only on disk**
  (file system cache to speed up). With newer Couchbase version there is N1QL query language for Json docs.
* Map reduce : views are creating using a mapping function on the docs of a bucket. The view value can be reduced by another user function.
* Querying : no optimizer you either query by view key or primary key
* Concurrency : **modification at document level are atomic**. No read/write locks ??.
  To avoid lost updates CAS value checking can be enabled. Unacknowledged writes by default (but configurable)
* Moxy - a memcached proxy / reverse proxy. On client side it can be used to pool connections and hide cluster topology from app logic.
  On server side used by Couchbase to act as drop-in replacement for memcached



