---
layout: diagram
title: C++ Symbol resolution
categories : [diagram, cpp]
diagram_list: [ Cpp_Symbol_Resolution.svg ]
---

It is quite an involved process to go from a symbol to a piece of executable code. 
Each time the compiler finds a name it has to go through name lookup, template resolution, overload resolution...
As usual with C++ it does work intuitively 90% of the time. The other 10% serious pain is inflicted to the programmer's brain :-(

## Links
* [Overload resolution](http://accu.org/index.php/journals/268)
* [Universal references](https://isocpp.org/blog/2012/11/universal-references-in-c11-scott-meyers)

