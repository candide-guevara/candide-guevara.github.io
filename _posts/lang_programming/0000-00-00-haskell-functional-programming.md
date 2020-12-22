---
title: Haskell, and functional programming
date: 2020-06-06
my_extra_options: [ graphviz ]
categories: [cs_related]
---

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box]
  nodesep=0.3
  ranksep=0.5

  monoid [width="2.3" label="Monoid\l
mempty:: a\l\
mappend:: a -> a -> a\l"]

  functor [width="3.1" label="Functor\l
fmap:: (a -> b) -> f a -> f b"]

  foldable [width="3.7" label="Foldable\l
foldl:: (b->a->b) -> b -> t a -> b\l\
foldr:: (a->b->b) -> b -> t a -> b\l"]

  applicative [width="3.3" label="Applicative\l
<*>:: f (a -> b) -> f a -> f b\l\
pure:: a -> f a\l"]

  alternative [width="2.7" label="Alternative\l
<|>:: f a -> f a -> f a\l\
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
Just a >>= f = f a\l\
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

## Functor, applicative, monad laws

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box]
  nodesep=0.6
  ranksep=0.4

  functor [width="3.6"
label="Functor (identity, composition)\l
fmap id = id\l\
fmap (u . v) = (fmap u) . (fmap v)\l"]

  applicative [width="5.8"
label="Applicative (identity, composition, interchange)\l
(pure u) <*> (f a) = fmap u (f a)\l\
(pure u) <*> (pure a) = pure (u a)\l\
(lift .) (f u) (f v) (f a) = (f u) <*> ((f v) <*> (f a))\l\
(f u) <*> pure a = pure (\\u -> u a) <*> (f u)\l"]

  monad [width="4.8"
label="Monad (right/left identity, associativity)\l
return a >>= u = u a\l\
M a >>= return = M a\l\
(M a >>= u) >>= v = (M a) >>= (\a -> u a >>= v)\l"]

  note_app [width="2.8" shape=note color=grey
label="Lifting functions\l
lift (a -> b -> c) = \l\
  (f a) -> (f b) -> (f c)\l"]

note_mon [width="3.0" shape=note color=grey
label="Composing monadic functions\l
u <=< v = \\a -> u a >>= v\l\
(u <=< v) <=< w =\l\
         u <=< (v <=< w)\l"]

functor -> applicative -> monad
applicative -> note_app [color=grey, arrowhead=none, constraint=false]
monad -> note_mon [color=grey, arrowhead=none, constraint=false]

{rank=same applicative note_app}
{rank=same monad note_mon}
}
```

### The `do` blocks

A direct consequence from the monad's associativity law.

> IO monad lets you segregate all pure code from "side-effects".  
> The associativity law lets you reduce all pure code __before__ taking side-effects into account.

```hs
pure_fn :: String -> String -> String
pure_fn s1 s2 = "echo: " ++ s1 ++ " " ++ s2

echo_do = do
  s1 <- getLine
  s2 <- getLine
  print $ pure_fn s1 s2

-- Is equivalent to :

echo_fn :: IO ()
echo_fn = getLine >>= (\s1 ->
            getLine >>= (\s2 ->
              print $ pure_fn s1 s2))
```


## Algebraic data types

```hs
data PairInt = PairIntCtor Int Int

-- "Templated" pair type (like c++ `std::pair<T,V>`)
-- Note the convention of naming the constructor the same as the type.
data Pair u v = Pair u v

-- You can "concat" 2 different types into one (equivalent to std::variant)
data Maybe v = Nothing | Maybe v

-- Fancy syntax to automagivally create getters to the type's fields
-- Ex: `left (Node 1 Empty Empty) = Empty`
data Node v = Empty | Node { val::v, left::(Node v), right::(Node v) }
```

`|` and "struct" are 2 operations on a set of types which behave similar to the 2 operations in a Ring (algebraic structure).
`()` and `Void` could represent `1` and `0` respectively (but the analogy is not perfect).

A simpler interpretation is to count the number of possible values for a type.
* `struct` is the product of its inner types
* `|` is the sum of its inner types


## Type system

Haskell type system is composed of several "bootstrapping" layers.
* Each layer determines what generated tokens valid for the layer below.
* "generated tokens" are the possible recursive expansions of the grammar rules for a given layer.

### Kind, type, value (approximative)

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box]
  nodesep=0.6
  ranksep=0.4

  kind [color=red width="2.6"
label="Kind (meta type)\l
Kind = * | * -> * \l\
      | * -> 'Constraint'\l"]

  t_impl [color=blue shape=oval width="2.6"
label="Typeclass\nImplementation"]

  t_class [color=blue shape=oval width="2.6"
label="Typeclass\n :: * -> Constraint"]

  t_ctor [color=red width="3.2"
label="Type Constructor :: * -> *\l
TCtor = [A-Z]\\w* | TCtor Type\l"]
  
  v_type [width="3.2"
label="Value Type :: *\l
VType = [A-Z]\\w* | TCtor Type\l\
(Special types : (), Void)\l"]

  f_type [width="4.2"
label="Function Type :: *\l
param = [a-z]\\w*\l\
FType = Type -> Type | param -> param\l\
       | (some other combinations ...)\l"]

  fc_type [width="5.0"
label="Function Type (typeclass contraints) :: *\l
TConstraint = Typeclass param | Typeclass TCtor\l\
FType_TC    = TConstraint => FType\l"]

  note_tctor [width="3.4" shape=note color=grey
label="Example:\l
  Maybe v = Nothing | Just v\l\
  Either u v = Left u | Right v\l"]

  note_vtype [width="2.4" shape=note color=grey
label="Example:\l
  Maybe String\l\
  Either Char Int\l"]

  note_ftype [width="2.8" shape=note color=grey
label="Example:\l
  id :: x -> x\l\
  (+) :: Int -> Int -> Int\l"]

  note_fctype [width="3.4" shape=note color=grey
label="Example:\l
  show :: Show a => a -> String\l\
  return :: Monad m => a -> m a\l"]

  note_tclass [width="3.6" shape=note color=grey
label="Example:\l
  class Show a => Klass a where ...\l"]

  kind -> {t_ctor v_type f_type} [constraint=none]
  kind -> t_class
  t_class -> fc_type [constraint=none]
  t_ctor -> v_type
  v_type -> f_type
  f_type -> fc_type
  {t_ctor v_type f_type} -> t_impl [constraint=none]

  t_ctor -> note_tctor [color=grey arrowhead=none contraint=none]
  v_type -> note_vtype [color=grey arrowhead=none contraint=none weight=0]
  f_type -> note_ftype [color=grey arrowhead=none contraint=none]
  t_class -> note_tclass [color=grey arrowhead=none contraint=none weight=2]
  fc_type -> note_fctype [color=grey arrowhead=none contraint=none]

  note_vtype -> t_impl [style=invis]
  fc_type -> note_tclass[style=invis]
  {rank=same f_type t_class}
  {rank=same v_type kind t_impl}
  {rank=same t_ctor note_tctor}
  {rank=same f_type note_vtype note_ftype}
  {rank=same fc_type note_fctype}
}
```

### Typeclass example

You can implement typeclasses for both concrete types and type constructors.

```hs
class Show t => Unboxable t where
  unbox :: t -> String

data Box t = Box t deriving Show

-- Any Box containing a "showable" thing is Unboxable
instance Show t => Unboxable (Box t) where
  unbox (Box t) = show t

main = do
  v <- return $ Box 666
  v2 <- return $ Box False
```

### Function polymorphism

Much like c++ template functions, constraints are akind to concepts.

```hs
-- template<class T>
--   requires requires (T x) { show(x); } // `required` used twice
-- std::string fancy_print(T);
fancy_print :: Show t => t -> String
fancy_print x = "value: " ++ (show x)

-- template<class T>
-- std::optional<T> val_or_deflt(std::optional<T>, T);
val_or_deflt :: (Maybe t) -> t -> (Maybe t)
val_or_deflt Nothing def = Just def
val_or_deflt x def = x
```

### Typeclasses are __not__ c++ classes

TL;DR there is no casting only explicit conversion functions.

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box]
  nodesep=0.4
  ranksep=0.4
  subgraph cluster_num {
    label="typeclass Num"
    color=blue
    fontname=monospace

    subgraph cluster_num {
      label="typeclass Integral"
      color=blue
      fontname=monospace

      integer [width="2.4"
        label="type Integer"]
      int [width="2.4"
        label="type Int"]
    }
    real [shape=box3d width="2.6" color=blue
      label="\ntypeclasses for\nFractional, Real"]
  }
}
```

```hs
-- ERROR : you cannot downcast a typeclass into a type
-- This is feasible with runtime checks in c++ using `dynamic_cast<Int*>`
downcast_type :: Num t => t -> Int
downcast_type x = (x :: Int)

-- ERROR : you cannot downcast a typeclass into child typeclass
-- This is feasible with runtime checks in c++ using `dynamic_cast<Integral*>`
downcast_class :: (Num t, Integral v) => t -> v
downcast_class x = (x :: Integral)

-- ERROR : you cannot upcast a type into a typeclass it implements
-- In c++ you are (always ?) allowed to do that
upcast_type :: Num t => Integer -> t
upcast_type x = x
-- When an **explicit** conversion function exists, it is OK
upcast_type x = fromInteger x

-- ERROR : you cannot upcast a typeclass into its parent typeclass
-- In c++ you are (always ?) allowed to do that
upcast_class :: (Integral t, Num v) => t -> v
upcast_class x = x
```

### Numerical literals "polymorphism"

The actual type of a literal numberical value will only be determined at the "latest moment".
Aka the actual reduction of an arithmetic expression using literals only happens when the type of the expression is known.

```hs
times_three :: Num t => t -> t
times_three x = x * 3

square_int :: Int -> Int
square_int x = x * x

square_flt :: Float -> Float
square_flt x = x * x

-- Only when the expression `4 * 3` is passed to either `square_int/flt` function
-- is the type constrained to be `Int` of `Float`
square_int $ times_three 4
square_flt $ times_three 4
```

### Modules and private members

```hs
module MyMod (
  OpaqueHandle,
  create_fn,
  fn_on_handle
) where

-- Note `PrivCtor` is not exported, the module user cannot create objects directly
data OpaqueHandle = PrivCtor String

-- Public constructor function
create_fn :: Show x => x -> OpaqueHandle
create_fn x = PrivCtor $ "private_state_" ++ (show x)

-- member functions to operate on the private state of the object
fn_on_handle :: OpaqueHandle -> String
fn_on_handle (PrivCtor s) = "inside obj: " ++ s

-----------------------------------------------------------
-- Module consumer

import qualified MyMod as M -- imported name needs Uppercase

main = do
  print $ M.fn_on_handle $ M.create_fn 666
```

