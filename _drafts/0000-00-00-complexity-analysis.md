---
title: Algorithm complexity analysis
date: 2016-06-18
my_extra_options: [ math_notation ]
categories: [cs_related, math, complexity, algorithm]
---

## Complexity classes

TODO : P / NP / NP-complete and variations using randomness

### Simple data structures complexity

{:.my-table}
| DataStructure   | Access | Insertion | Other                                                                                      |
|-----------------|-----------------------------------------------------------------------------------------------------------------|
| Linked list                     | O(n)     | O(1)     | append O(1) |
| Hash table (balanced bucket)    | O(1)     | O(1) if table does not grow |
| Vector                          | O(1)     | O(n)     | append O(2n) amortized |
| Binary tree (branches balanced) | O(log n) | O(log n) | delete O(log n) |

## Amortized cost analysis

Let $$\phi$$ be a the potential function so that for any operation :

$$ a = t + \phi_i - \phi_{i-1} $$

Where **t** is the real time taken by the operation and **a** the amortized time, then for any sequence of **n** operations :

$$ \sum^n{t_i} = \sum^n{a_i} + \phi_0 - \phi_n $$

If you choose $$\phi$$ wisely **all operations will have a constant amortized time**. If $$\phi_0 - \phi_n$$ is bounded
and negative then you have an upper bound for the total time of all operations.

### Example for vector insertion

Suppose we start with an empty vector of capacity 1 and push **n** elements. We define the potential as follows :

$$ \phi = size - capacity \qquad\mbox{(always a negative value)}$$

When pushing an element and size < capacity we just have to copy 1 item so t = 1 :

$$ 
\begin{align}
a &= 1 + \phi^{cap=m}_{size=k} - \phi^{cap=m}_{size=k-1} \\
  &= 2 
\end{align}
$$

When pushing an element and there is no more capacity, the vector will **double** its size.  
Considering memory allocation is free, we new to copy old items into the new memory so t = m + 1 :

$$ 
\begin{align}
a &= m+1 + \phi^{cap=2m}_{size=m+1} - \phi^{cap=m}_{size=m} \\
  &= (m+1) + (m+1 - 2m - m + m) \\
  &= 2 
\end{align}
$$

The total time for n pushes is :

$$ 
\begin{align}
T_{total} &= \sum{a} + \phi_0 - \phi_n \\
          &= 2n + \phi_0 - \phi_n 
\end{align}
$$

If n is a power of 2 then $$\phi_n = 0$$ so that the total cost of all operations is O(2n)

