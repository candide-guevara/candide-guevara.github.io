---
layout: post
title: Some acronyms I have come across
categories : [article, note]
---

## Technology acronyms

* STP - spanning tree protocol (avoids layer2 broadcast storm)
* SMP - symmetric multiprocessing : several processor sharing a common memory
* NAS - network attached storage (file level access server)
* SAN - storage area network (block access server) => virtual local drive
* JIT - just in time compiler (optimization for virtual machines)
* DDL/DML - data definition/manage language (subsets of SQL statements)
* RDMA - remote direct access memory. Bypass kernel for network communication (less buffer copies)
* XULWrapper - integrates Mozilla web browser in a graphical Swing component
* Oracle shared pool - contains the in-memory representation of current and past SQL statements (~cache) and some metadata (dict cache) about the tables
* LLVM - tools to build compiler
* A/B testing - perform the same test between two test subjects (A and B) a high number of times, A and B differ by a single small difference
* HANA - SAP's in-memory DB (ACID and support structured, graph and non-structured data)
* JNDI - java naming and directory interface: standard Java API to use naming services like DNS, LDAP...
* NSS - name service switch used by standard libc to choose the data sources to use to resolve queries
* JavaFX - new framework for developing desktop and web UI replacing Swing on java7
* JDBC - java standard API for connectivity to DB (same idea as ODBC)
* Hibernate - ORM (object to/from relational DB) framework for java
* APIC - advanced programmable interrupt controller : in an SMP processor it routes the interrupts to the right processor.
  Each core has a local APIC with a timer for measuring quantums and there is a IO APIC handling interrupts from outside the chip.
* BLOB - binary large object (CLOB - character large object), internal structure unknown to DB
* BWS - business web service : a more coarse grained service use to orchestrate fined grained services, directly accessible to the customer
* LAMP - open source stack for web server composed of linux, apache, mysql and perl/python/php
* BusyBox - single executable providing a set of standard GNU tools (grep, ls, awk ...) directly on top of the c library.
  Used in embedded systems (phone, gps..) because optimized for size
* ETL - extract transform and load, process flow typically used in Business intelligence.
  Extracts the raw data, transforms it so that it can be analyzed and load it in the Business Intelligence DB.
* Expat - XML parser library in C
* RapidJson - json parser library in C++
* Go - typed, compiled, garbage collected language developed by people from C and Java HotSpot. 
  It features built-in concurrent primitives (channels), reflection, interfaces are not implemented by declaration
  (like the implements keyword in java) but by containing all methods the interface lists.
* SNMP - simple network management protocol : used to manage and monitor network devices like routers,
* Switches (even higher OSI layer components) through read/write access to management variables.
* Traps are used by agents running on monitored component to send monitoring data
* WAF - web application firewall : blocks HTTP level attacks (Xsite scripting, SQL injection...)
* OLAP - online analytical processing a part of BI applications dealing with the aggregation of data to present to the user. 
  An OLAP-cube is a representation of how data can be aggregated on several dimensions
* AWS - Amazon web services : a company providing cloud computing solutions. 
  Among popular components S3 (simple storage service), Dynamo (NoSQL data store), EC2 (elastic cloud IaaS)

## Project Management

* Governance - all the aspects defining how software components are developed and released, legislation
  (release cycle, integration/qa phases, patch policy ...) and team structure to split responsibilities
  (developers, pdf/qa, project lead ...)
* DevOps - New way of releasing software to production that does not rely on the typical roles of
  Integrator or operator. Developers load the soft when needed. It relies on automation of the
  deployment process and monitoring to avoid taxing too much of dev time doing ops.

## Android

* AOSP - android open source project : google release of android OS
* ROM - Firmware - Phone OS (the first 2 terms come from the microcontroller era)
* MTD - memory technology device : linux component to drive embedded flash memory chips without an internal controller like SSD
  MTD need special filesystems that take into account wear leveling and asynchronous Garbage collection 
  (flash cells need to be erased before they can be rewritten, Slow process compared to read ~1000)
* MOD - modified OS, a binary distribution (ready to install) of AOSP ported to specific devices with some custom soft on top (ex: Cyanogen)
* Dalvik - Virtual machine for android not completely compliant to Java specs (no Swing)


