---
title: Haskell, Learning retrospective
date: 2019-10-05
categories: [quick_notes]
---

* case conventions : upper for types, type constructors and value construnctors
* what are functions ? a single expression
* pattern matching and `:` constructor
  * multi body functions
  * `where` and `let` clauses
  * `@` keyword to reference the **whole match**
* list comprehensions : map, input, predicate
* private members by not declaring the data type constructor
* type polymorphism methods = different constructors or type functions
* data types algebra : AND -> tuples, OR -> variant types
* type and typeclasses ( `->`/`=>` operators)
  * class and instances out of type constructors
* kinds, type, value, // function signature and type kind
  * `constraint` kind what is that ? how do typeclasses mix with kinds ?
* How `do` blocks are syntax sugar for monad chaining
  * how to identify "delayed read on closed handle" and understand when evaluation is done
  * strict `$!` and weak head normal form
  * tail recursion can be used as an iterator, normal recursion no
  * example express `do t <- getLine; f <- getLine; let w = words t in return $ map (== f) w` using application monads
  * use c++ template+command pattern to mimic monads deferred evaluation graph
  * adding `fail` in the middle of `do` block aborts the rest. Same for runtime errors (pattern matching), differs from >>=
  * Be careful it is a trap ! `do n <- [1,2]; ch <- ['a','b']; return (n,ch)`
* Topology of functor, applicative, monad, monoid monad (with constraints and unenforced properties)
* Mind blow : monad foldM to return all possible sums of array members

## Rant

* State monad just reintroduces the hated side effects ?
* `do` blocks semantics vary depending on the type (syntax depends on context ?)
* Error message inconsistencies

```
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

## WTF

* wtf cannot declare signatures in ghci ?
* declare type function with type parameter belonging to a typeclass

* How does haskell distinguish between substitution and pattern matching ? (both use `=`)
* Lazy execution model, how can I be sure recursive functions are lazily evaluated (ressembles the `yield` model in python)
* Partial functions not defined on a certain constructor are not catched at compile time

## Exercise

* sort : bubble (how to transform to recursion a fundamentally imperative algo) vs quick
* function composition with the caesar encryption
* week days + time of day as data type to show the way we derive behaviours like Ord, Eq ...
* composition of monads : Maybe + Writer

