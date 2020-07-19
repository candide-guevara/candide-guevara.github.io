---
title: Haskell, and functional programming
date: 2020-06-06
my_extra_options: [ graphviz ]
published: false
categories: [cs_related]
---

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box]
  nodesep=0.4
  ranksep=0.8

  monoid [width="2.3" label="Monoid\l
mempty:: a\l\
mappend:: a -> a -> a\l"]

  functor [width="3.1" label="Functor\l
fmap:: (a -> f b) -> a -> f b"]

  foldable [width="3.7" label="Foldable\l
foldl:: (b->a->b) -> b -> t a -> b\l\
foldr:: (a->b->b) -> b -> t a -> b\l"]

  applicative [width="3.3" label="Applicative\l
<$>:: f (a -> b) -> f a -> f b\l\
pure:: a -> f a\l"]

  alternative [width="2.7" label="Alternative\l
<|>:: f a -> f a -> f a\l\
empty:: f a\l
mplus:: f a -> f a -> f a\l\
mzero:: f a\l"]

  monad [width="3.3" penwidth=2 color=red label="Monad\l
>>=:: f a -> (a -> f b) -> f b\l\
>>:: f a -> f b -> f b\l\
return :: a -> f a\l"]

  traversable [width="3.2" label="Traversable\l
traverse:: Applicative f =>\l\
  (a -> f b) -> t a -> f (t b)\l\
sequenceA:: Applicative f =>\l\
  t (f a) -> f (t a)\l"]


  reader [color=blue width="2.7" label="Reader\l
Reader r a = r -> a\l\
f >>= g = \\x -> g (f x) x\l"]

  writer [color=blue width="3.8" label="Writer\l
Monoid w => \l\
(a, w) >>= f = let (a', w') = f a\l\
                in (a', mappend w w')\l"]

  state [color=blue width="3.5" label="State\l
State s a = \\s -> (a,s)\l\
f >>= g = \\s -> let (a, s) = f s\l\
                 in g a s\l"]

  list [color=blue width="3.2" label="List (aka [])\l
[a] >>= f = concat $ map f [a]\l"]

  maybe [color=blue width="2.7" label="Maybe\l
Just a >>= f = Just $ f a\l\
Nothing >>= f = Nothing\l"]

  foldable -> {applicative maybe} [style=invis] # needed to get sane layout
  foldable -> traversable
  monoid -> alternative [dir=none constraint=false]
  functor -> applicative
  applicative -> monad
  applicative -> traversable
  applicative -> alternative
  monad -> maybe
  monad -> list
  monad -> reader
  monad -> writer
  {reader writer} -> state
}
```

### Some laws

### The `do` blocks

## Algebraic data types

### Modules and private members

## Type system

### Kind, type, value

### Typeclass example

### Function polymorphism

