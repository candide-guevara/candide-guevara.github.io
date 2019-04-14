---
title: Database transactions isolation levels
date: 2015-05-23
categories: [cs_related, database]
---

Recap of some of the different consistency guarantees you get on different relational databases.
In particular for Oracle the second image explains how the redo logs and undo table are used to
guarantee some ACID properties.

![DB_Transaction_Read_Consistency.svg]({{ site.images }}/DB_Transaction_Read_Consistency.svg){:.my-wide-img}
![DB_Oracle_Transaction_Persistency.svg]({{ site.images }}/DB_Oracle_Transaction_Persistency.svg){:.my-wide-img}
