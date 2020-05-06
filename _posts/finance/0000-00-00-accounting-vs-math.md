---
title: Finance, accounting Vs math
date: 2016-06-25
categories: [misc]
---

It looks to me like accounting and mathematics have the opposite approach to explain things.

## Math : defition -> property

In mathematics you start by defining the objets you work with. Then, out of the defintions you deduce interesting properties.
For example : You define what a bounded sequence of number is. Then you can prove that you can find a subsequence out of it that converges.

The advantage of this method is that there are no exceptions. The problem is that sometimes a property only holds for an __undefinable__ subset of the objects matching a defition : "it almost always works". In that case you must use approximation and heuristics.

## Accounting : property -> definition

In accounting you start from the idea of a figure that represents some important aspect of reality. Then you determine a calculation method to obtain a number which approximates it.
For example : you want to determine the value of all final goods and services produced by an economy, aka GDP. You can approximate this by the money spent by households on consumption, government expenditure in infrastructure, corporate investment in production means ... To remove the money spent on goods produced outside the economy (ex: prime materials, machinery...) you remove the sum of all imports.

Although this is a logical reasoning, contrary to mathematics you __cannot state a fact out of a formula__. Even if GDP has declined it may not mean the economy is less productive.
In this sense accounting looks a lot more like software engineering. If on your application monitoring dashboard you see that cpu and memory consumption increased with the new release, it might not mean the code is less efficient.

## Implications

* Any accounting figure does __not mean anything by itself__, you only get relevant information by looking at its evolution across space and time.
    * You can compare GDP figures across similar countries or to the previous years.
    * Figures can be compared only if we make sure that the method used to calculate it stays the __same across time and other companies/countries__.
* Accounting is basically a __dimension reduction problem__ : summarize a complex reality by projecting it into a set of numerical indexes
    * Looking at a company fundamentals can give you an idea of its health. But it will never tell the full truth.
* Each time you calculate a new figure from previous results, it will less accurately describe reality.
    * Company net profits are calculated from revenue, operating costs, taxes, depreciation ... However each of these only approximates the real quantity.
    * As a result net profits carries all the __noise__ contained in the underlying figures.

