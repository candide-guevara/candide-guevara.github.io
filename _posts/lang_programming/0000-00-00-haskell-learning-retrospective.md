---
title: Haskell, Learning retrospective
date: 2019-10-05
categories: [quick_notes]
---

### Quick notes on important points

* case conventions : upper for types, type constructors and value construnctors
* Functions are simply a handy way to name an expression
* pattern matching and `:` constructor
  * multi body functions
  * `where` and `let` clauses
  * `@` keyword to reference the **whole match**
* list comprehensions : map, input, predicate
* How `do` blocks are syntax sugar for monad chaining
  * how to identify "delayed read on closed handle" and understand when evaluation is done
  * strict `$!` and weak head normal form
  * tail recursion can be used as an iterator, normal recursion no
  * IO monads deferred evaluation graph can be implemented with the command pattern in standard languages
  * adding `fail` in the middle of `do` block aborts the rest. Same for runtime errors (pattern matching), differs from >>=
  * Be careful it is a trap ! `do n <- [1,2]; ch <- ['a','b']; return (n,ch)`
* Mind blown : monad foldM to return all possible sums of array members
* Mind blown : implementing [confluent data structures][1] using zippers

### Thigs I do not like

* `do` blocks semantics vary depending on the type (syntax depends on context ?)
* Printf debugging impractical when using `let` blocks (example of using trace)
* Appending to a list the [wrong way][0] is quadratic
* Error message inconsistencies

```hs
data A = A deriving Show
data B = B deriving Show
data C = C deriving Show
data D = D deriving Show

class If1 t where ; meth1 :: x -> t
class If2 t where ; meth2 :: x -> t
instance If1 A where ; meth2 x = A
instance If2 B where ; meth2 x = B

apply_func :: If1 a => (Either a b) -> (b -> Either a c) -> Either a c
apply_func (Right x) f = f x
apply_func (Left x) _ = Left x

f :: If2 b => b -> Either a C
f b = Right C

:t apply_func (Right B) f
  apply_func (Right B) f :: If1 a => Either a C
:t apply_func (Right B :: Either D B) f
  error:
    • No instance for (If1 D) arising from a use of ‘apply_func’
:t apply_func (Left A) f
  error:
    • Ambiguous type variable ‘b0’ arising from a use of ‘f’
      prevents the constraint ‘(If2 b0)’ from being solved.
```

### WTF

* block declarationin ghci is cumbersome (you need to use `:{` `:}`)
* declare type of a function whose parameter belongs to a typeclass

* How does haskell distinguish between substitution and pattern matching ? (both use `=`)
```hs
Just a = Just 1
a = f x
```

* Lazy execution model, how can I be sure recursive functions are lazily evaluated (ressembles the `yield` model in python)
* Partial functions not defined on a certain constructor are not catched at compile time

## Exercises

* Week days + time of day as data type to show the way we derive behaviours like Ord, Eq ...
* Simple regex compiler and evaluator

[0]:http://learnyouahaskell.com/for-a-few-monads-more
[1]:http://learnyouahaskell.com/zippers#a-very-simple-file-system
