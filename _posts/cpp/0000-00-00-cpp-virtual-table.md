---
title: C++ Virtual tables
date: 2015-07-07
categories: [cs_related, cpp]
---

Unlike Java in C++ you have to explicitely declare the member functions that will have virtual linkage.

* Virtual linkage only works for reference and pointers. Calls to function members using the object's value will
  be solved at compile time
* Declaring a virtual member function in a class will increase the instance size by the size of the vtable pointer
* Beware of the infamous symbol undefined when using [abstract classes][1]

![Cpp_Virtual_Table.svg]({{ site.images }}/Cpp_Virtual_Table.svg){:.my-wide-img}

[1]: https://isocpp.org/wiki/faq/strange-inheritance#link-errs-missing-vtable
