---
title: Radar, Ideas for future posts
published: false
categories: [quick_notes, radar]
---

## Random ideas

 - Taxes are like a payload in the OSI layer
 - logs are like chocolates, eat too much of it and you will get sick
 - processor discovering peripheral mappings is like socializing in a party
 - in house middleware is like soft porn, all those layers hide the real deal in a perverse way
 - Bored at work ? Imagine your are a code monkey in a big banana company
 - [Containers Vs Virtual Machines][1]
 
## Nice oracle features
 * SIMILAR - same function as LIKE but with POSIX regular expressions
 * DATALINK - SQL/MED extension, allows o access data not managed by the DB. Can even be used to access other DB tables in SQL queries

## SQL 2003 types

 {:.my-table}
 | Type            | Usage                                                                                                           |
 |-----------------|-----------------------------------------------------------------------------------------------------------------|
 | DISTINCT        | Gives another name to an already existing type (user or base) and makes it incompatible with its parent. Useful to defined different semantics (ex Blob to store an Image, a Song) |
 | STRUCT          | Structured type composed of fields (ex CREATE TYPE PLANE\_POINT AS (X FLOAT, Y FLOAT) ) |
 | REF             | Persistent pointer to a data object. Same use as in programming, several structs may reference the same data without copying it. |
 | LOCATOR         | Like REF but exists exclusively on client side. Transient reference to a piece of data. Locators may be used by driver implementation for blobs, if the client only has a locator to the blob then all data does not have to be transferred from the server. |
 | XML             | Xml document, comes with useful functions to get an element using xpath or validate the document against a schema |
 | ARRAY/MULTISET  | Multiset behaves like a set : unbounded, intersection and union operators |

## Man of coding steel

dart devil => I cannot win without a proper browser implementation
Dizarro => Not a bad guy, just nobody cares about him. Go and travel the universe, maybe someday in a distant star you will find a user base

## .NET framework

* What does it include ?
* Implementing web services
* Command line tools

## C++ pod and aggregate types

* different type of objects and their initialization

## Set types taxonomy

* Groups
* Rings
* Algebras

## Working with SQL server

* Develpment experience
* Scalability
* Integration packages
* C# user defined functions

## Python internals

* Descriptor protocol
* How to use C api to have your own types
* Class and object [instanciation][2]

[1]: http://stackoverflow.com/questions/16047306/how-is-docker-io-different-from-a-normal-virtual-machine
[2]: https://blog.ionelmc.ro/2015/02/09/understanding-python-metaclasses/

