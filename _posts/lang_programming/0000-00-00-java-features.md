---
title: Java, Features I appreciate
date: 2015-05-25
categories: [cs_related]
---

## Some new language features
* Suppressed exceptions - if a try block statement throws an exception A and the finally block throws an
  Exception B, only B will be thrown A is suppressed. Throwable class provides API to recover them
* Lambda expressions - any functional inteface (having just 1 virtual method) can be implemented as
  a lambda expression without the need of an anonymous class.
* Streams - lazy iterators on the collection package with a fluent api. Allows transparent parallel iteration,
  map reduce using predicates (lambda) [Java8]
* Defender methods - Give a default implementation of a method interface. Allows to evolve interfaces
  (add new methods) without breaking backward compatibility. However since classes can impl
  Several interfaces => **multiple inheritance allowed** [Java8]
* Try with resource - declares objects implementing AutoCloseable in the try block that will be closed at
  the end no matter if an exception is thrown. Exceptions thrown when closing do not suppress
  Previous exceptions => like python's with statement [Java7]

## Assertions
Java language construct [Java5] **disabled by default (-ea option in VM)**. Here are some interesting design choices
for the assertion implementatio :

* Deactivate at runtime VS compilation : minor perf penalty at runtime VS class files do not contain
  any assertion code => enabling assert would imply recompilation (impossible in prod)
* Language construct VS library : using a library would imply function calling overhead + argument construction 
  (same problem for logging and annoying if guard), language construct simpler and more performance but breaks compatibility.

## Nested classes
* Transient - In java a reference to an object that will not be serialized
* Nested classes - Classes declared inside an outer class or block. Several types exists
* Static nested - instances are NOT bound to outer instance (only access to outer static fields/methods)
* Inner - instances bound to outer instance, access to all fields even if private (serialization: non
  transient ref to outer obj)
* Local - declared inside a block (other than class block), access to outer object fields and final variables
  inside the block (not actual reference but only a copy)
* Anonymous - same properties as local, however class declaration and instantiation are combined in a
  single statement => there can only be 1 instance of such class.

## JAR Packaging
Zip format to packages sources, classes and resources. Meta information about jar package lies in META\_INF/MANIFEST.MF. 
It contains the following data :
* Jar entry point (Main-Class property)
* Specification and implementation versions
* Add extra jar/directory to the classpath
* Sealing (all classes in java pkg come from same jar - for version consistency)
* Digital signing

Manifest is composed of a main section and then 0 or more named sections applying to a pkg or file.
Sections start with property Name: <pkg or file>

