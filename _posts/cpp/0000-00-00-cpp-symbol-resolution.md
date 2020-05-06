---
title: C++, Symbol resolution
date: 2015-07-07
categories: [cs_related]
---

It is quite an involved process to go from a symbol to a piece of executable code. 
Each time the compiler finds a name it has to go through name lookup, template resolution, overload resolution...
As usual with C++ it does work intuitively 90% of the time. The other 10% serious pain is inflicted to the programmer's brain :-(

## Links
* [Overload resolution](http://accu.org/index.php/journals/268)
* [Universal references](https://isocpp.org/blog/2012/11/universal-references-in-c11-scott-meyers)

![Cpp_Symbol_Resolution.svg]({{ site.images }}/Cpp_Symbol_Resolution.svg){:.my-block-wide-img}
