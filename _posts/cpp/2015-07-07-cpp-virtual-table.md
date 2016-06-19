---
layout: diagram
title: C++ Virtual tables
categories : [diagram, cpp]
diagram_list: [ Cpp_Virtual_Table.svg ]
---

Unlike Java in C++ you have to explicitely declare the member functions that will have virtual linkage.

* Virtual linkage only works for reference and pointers. Calls to function members using the object's value will
  be solved at compile time
* Declaring a virtual member function in a class will increase the instance size by the size of the vtable pointer
* Beware of the infamous symbol undefined when using [abstract classes][1]

[1]: https://isocpp.org/wiki/faq/strange-inheritance#link-errs-missing-vtable

