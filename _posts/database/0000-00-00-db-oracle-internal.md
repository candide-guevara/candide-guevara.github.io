---
title: Database Oracle internals training
date: 2015-05-27
categories: [cs_related, database]
---

Trainer contact : Bernard.soleillant@setra-conseil.com

## Glossary
* Oracle RAC - real application cluster, several oracle DB connected to an array of Disks and acting as a single DB for clients
* Consistent get - read the right data block in cache according to the transaction isolation level
* Heap table - normal type of table where rows follow no particular order
* IOT - index ordered tables, rows are stored in primary key order
* FBI - function based index. Can be used in requests where the WHERE clause uses functions on the columns
* Bind peeking - delays execution plan decision until the first bind variables to have real values
* Adaptive cursor sharing - decides whether to calculate a new plan depending on selectivity (needs histograms)
* PL/SQL - procedural sql, oracle extension to give SQL elements of a procedural Language (if, loops, functions ...)
* Table cluster - stores tables linked by a foreign key relationship together (same Segment) so that join are faster and less space is needed.
* Trigger - Java or PL/SQL procedure invoked for certain DML on certain objects and users or DDL per user.

![DB_Oracle_Tracing.svg]({{ site.images }}/DB_Oracle_Tracing.svg){:.my-wide-img}
![DB_Oracle_Components.svg]({{ site.images }}/DB_Oracle_Components.svg){:.my-wide-img}
![DB_Oracle_Memory.svg]({{ site.images }}/DB_Oracle_Memory.svg){:.my-wide-img}
![DB_Oracle_Storage.svg]({{ site.images }}/DB_Oracle_Storage.svg){:.my-wide-img}
