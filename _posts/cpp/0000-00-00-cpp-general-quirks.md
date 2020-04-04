---
title: C++ Tricky rules
date: 2015-07-16
categories: [cs_related, cpp]
---

## Binding parameters to arguments

{:.my-table}
| param\arg | T | T& | const T& | T&& | V/V&... |
|-----------|---|----|----------|-----|---------|
| T         | bind directly | bind to copy(T&) | bind to copy(T&) | bind to move(T&&) | bind to conversion(V) |
| T&        | FAIL | bind directly | FAIL | FAIL | FAIL |
| const T&  | add const and bind | add const and bind | bind directly | add const and bind | add const and bind to conversion(V) |
| T&&       | bind directly | FAIL | FAIL | bind directly | bind to conversion(V) |

## C++ quirks
Coding in C++ is like being a clown carrying a loaded shotgun, you are just destined to shot yourself in the foot.
Hopefully the following diagrams will describe with just enough detail to get 95% of my use cases right :

* Different contexts where type deduction applies and their flavors
* Capturing variables with lambdas

## Links
* [Type deduction and why you should care](https://www.youtube.com/watch?v=wQxj20X-tIU)

![Cpp_Lambda_Capture.svg]({{ site.images }}/Cpp_Lambda_Capture.svg){:.my-block-wide-img}
![Cpp_Template_Deduction_Contexts.svg]({{ site.images }}/Cpp_Template_Deduction_Contexts.svg){:.my-block-wide-img}
