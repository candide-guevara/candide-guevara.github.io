---
title: Prolog, Nice puzzle, horrible programming tool
date: 2023-08-12
my_extra_options: [ graphviz ]
categories: [cs_related]
---

## [Glossary of terms][0]

Words defintions are fuzzy because they depend on the context.
Some words are used when speaking purely about syntax.
Others when speaking about programs or when submitting queries in interactive mode.

### Syntax

A `term` is either an `atom`, `variable` or `structure`.

```prolog
fido       % atoms start with lowercase
X          % variables start with uppercase
is_dog(X)  % `is_dog` is the functor for this term
owner_of(fido, Y)
[fido, rex]  % lists are another type of `structure`
2 * 2 + 3    % arithmetic expressions are `atom`s, they get reduced when using operator `is`
```

### Program

* Prolog programs are a sequence of `rule`s (aka `clause`).
* A `rule` is composed of a `head` and a `body`.
* A `fact` is a `rule` with an empty `body`.
* A `predicate` (aka `relation`, `procedure`) is the set of `rule`s sharing the same `functor` name.

```prolog
is_dog(fido).   % `relation` word is used generally for `predicate`s without variables
is_dog(rex).
hates_cats(_).  % It is a `fact` that everybody hates cats
bites(X) :- is_dog(X).  % bites(X) is the `head`, is_dog(X) the `body`
```

### Interactive mode

The prolog engine uses the `rule`s in the program to prove `query`s.
A `query` is composed of `goal`s.

```prolog
?- is_dog(rex), is_dog(fido).      % the `query` is a conjunction (AND) of 2 `goal`s
?- is_dog(rex); is_dog(garfield).  % the `query` is a disjunction (OR) of 2 `goal`s
```

> Prolog was designed for interactive use. A clunky way to use it as an executable is [`:- initialization((goal, halt(0)))`][1].

### Execution

* A `term` is `ground`ed when it does not contain any `variable`.
* A `goal` is satisfied if there exists a `binding` (aka `substitution`) so that the `ground`ed `goal` is true.
* `unification` is the mechanism to pattern match 2 `term`s.
* `term` A is an `instance` of `term` B if A `unifies` with B and A contains less `variables` than B.

```prolog
?- is_dog(X).      % `binding`s X/rex and X/fido satisfy the `goal`
?- is_dog(daisy).  % this `term` is `ground`ed but false
owner_of(rex, X).  % is an `instance` of owner_of(X,Y)
Pair = [X,Y].      % this `unification` extracts the values of a pair
```

### Symmetry between validating and finding bindings

The same prolog program can either compute the set of `binding`s that satifies the `query` or validate that `ground`ed variables are valid.

```prolog
square(X,Y) :- Y is X*X.
?- square(4,X).
% returns 16
?- square(4,15).
% returns false
```


## Derivation trees

To prove a `query` prolog builds a derivation tree out of it.

* Each `predicate` present in the query is expanded to all of it `rule`s recursively.
* The tree is searched in depth first. In prolog words: the search `backtrack`s  to the closest `choice point`.

```prolog
is_dog(X) :- member(X, [fido, rex]).
is_cow(daisy).
eats(X,grass) :- is_cow(X).
eats(X,meat) :- is_dog(X).
```

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=oval]

  query[margin=0.1 label="?- eats(rex,Y)."]
  eats_cow[margin=0.1 label="eats(rex, grass)."]
  eats_dog[margin=0.1 label="eats(rex, meat)."]
  branch_cow[margin=0.1 label="is_cow(rex)."]
  branch_dog[margin=0.1 label="is_dog(rex)."]
  leaf_cow[label="false." color=red, shape=hexagon]
  memb_dog[margin=0.1 label="member(rex, [fido, rex])."]
  branch_rex[margin=0.1 label="member(rex, [rex])."]
  branch_fido[label="rex = fido." color=red, shape=hexagon]
  leaf_rex[label="rex = rex" color=blue, shape=hexagon]
  leaf_empty[label="member(rex, [])." color=red, shape=hexagon]

  query -> {eats_cow eats_dog}
  eats_cow -> branch_cow -> leaf_cow
  eats_dog -> branch_dog -> memb_dog
  memb_dog -> {branch_rex branch_fido}
  branch_rex -> {leaf_rex leaf_empty}
}
```

### Negation needs arguments to be `ground`ed

Negation of a `goal` with free variables is often false.
Prolog cannot prove that all possible `binding`s for the free variables will never be valid.

```prolog
is_dog(X) :- member(X, [fido, rex]).
is_cow(daisy).
eats(X,grass) :- is_cow(X).
eats(X,meat) :- is_dog(X).

?- not(eats(rex,X)).
% returns false
?- member(X, [meat, grass]), not(eats(rex,X)).
% returns X=grass
```

### Pruning subtrees using cut `!`

The cut `!` goal removes all `choice points` to its right (including all other `head`s for the same `predicate`).
However `!` is reset when we reach a `choice point` higher in the stack.
Aka the parent node of the rule containing `!` in the derivation tree.

```prolog
is_prime(X) :- member(X, [2, 3, 5, 7]).
is_odd(X) :- member(X, [3, 5]), !.
is_odd(X) :- member(X, [7, 9]).
odd_prime(X) :- is_odd(X), is_prime(X).
% returns 3
```

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=oval]

  query[margin=0.1 label="?- odd_prime(X)."]
  subgraph cluster_cut {
    label="  is_odd!"
    fontname=monospace
    labeljust=l
    color=green
    style=dashed
    is_odd1[margin=0.1 label="is_odd(X)."]
    is_odd2[margin=0.1 label="is_odd(X)."]
    memb_odd1[margin=0.1 label="member(X, [3])."]
    memb_odd3[margin=0.1 label="member(...)"]
    memb_odd4[margin=0.1 label="..."]
    is_prime[margin=0.1 label="is_prime(3)."]
    leaf_2[label="3 \\= 2" color=red, shape=hexagon]
    leaf_3[label="3 = 3" color=blue, shape=hexagon]

    is_odd1 -> is_odd2 [style=invis]
    {rank=same is_odd1 is_odd2}
  }
  query -> { is_odd1 is_odd2 }
  is_odd1 -> { memb_odd1 memb_odd3 }
  is_odd2 -> memb_odd4
  memb_odd1 -> is_prime
  is_prime -> { leaf_2 leaf_3 }
}
```

```prolog
is_prime(X) :- member(X, [2, 3, 5, 7]), !.
is_odd(X) :- member(X, [3, 5, 7, 9]).
odd_prime(X) :- is_odd(X), is_prime(X).
% returns 3, 5, 7
```

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=oval]

  query[margin=0.1 label="?- odd_prime(X)."]
  is_odd1[margin=0.1 label="is_odd(X)."]
  is_odd2[margin=0.1 label="..."]
  subgraph cluster_cut {
    label="  is_prime!"
    fontname=monospace
    labeljust=l
    color=green
    style=dashed
    is_prime[margin=0.1 label="is_prime(3)."]
    memb_prime1[margin=0.1 label="member(3, [2])."]
    memb_prime2[margin=0.1 label="member(3, [3])."]
    memb_prime3[margin=0.1 label="member(3, [5, 7])."]
    memb_prime4[margin=0.1 label="..."]
    leaf_2[label="3 \\= 2" color=red, shape=hexagon]
    leaf_3[label="3 = 3" color=blue, shape=hexagon]
  }
  query -> { is_odd1 is_odd2 }
  is_odd1 -> is_prime
  is_prime -> { memb_prime1 memb_prime2 memb_prime3 }
  memb_prime1 -> leaf_2
  memb_prime2 -> leaf_3
  memb_prime3 -> memb_prime4
}
```

## Meta-predicates

Meta-predicates are used to dynamically:

* Collapse a subtree of the derivation tree, by returning all possible `binding`s satisfying a `goal`.
* Expand the derivation tree by adding `predicate`s derived from a list.

```prolog
is_odd(X)         :- member(X, [3, 5, 7, 9]).
is_prime(X)       :- member(X, [2, 3, 5, 7]).
prime_or_print(X) :- is_prime(X).
prime_or_print(X) :- format("~w is odd but not prime~n", [X]).

max_odd_prime(X)  :- findall(X, (is_odd(X), is_prime(X)), R),
                     max_list(R, M).
% returns 7
side_effect       :- forall(is_odd(X), prime_or_print(X)).
% prints "9 is odd but not prime"
```

```myviz
digraph {
  rankdir=LR
  node [fontsize=11 fontname=monospace shape=oval]

  query[margin=0.1 label="?- max_odd_prime(X)."]
  max_list[margin=0.15 label="max_list([3, 5, 7], M)."]
  subgraph cluster_cut {
    label="  findall"
    fontname=monospace
    labeljust=l
    color=green
    style=dashed
    is_odd[margin=0.1 label="is_odd(X)."]
    memb_odd1[margin=0.1 label="member(X, [3])."]
    memb_odd2[margin=0.1 label="member(...)"]
    is_prime[margin=0.1 label="is_prime(3)."]
    memb_prime1[margin=0.1 label="member(3, [2])."]
    memb_prime2[margin=0.1 label="..."]
  }
  query -> is_odd
  is_odd -> { memb_odd1 memb_odd2 }
  memb_odd1 -> is_prime
  is_prime -> { memb_prime1 memb_prime2 }
  memb_prime2 -> max_list
}
```

```prolog
is_odd(X)     :- member(X, [3, 5, 7, 9]).
is_prime(X)   :- member(X, [2, 3, 5, 7]).
even_prime(Y) :- is_prime(Y), foreach(is_odd(X), dif(X,Y)).
% returns 2
```

```myviz
digraph {
  rankdir=LR
  node [fontsize=11 fontname=monospace shape=oval]

  query[margin=0.1 label="?- even_prime(Y)."]
  is_prime[margin=0.1 label="is_prime(Y)."]
  subgraph cluster_cut {
    label="  foreach"
    fontname=monospace
    labeljust=l
    color=green
    style=dashed
    dif1[margin=0.1 label="dif(3,Y)."]
    dif2[margin=0.1 label="dif(...)."]
    dif3[margin=0.1 label="dif(9,Y)."]
  }
  leaf[label="Y = 2" color=blue, shape=hexagon]

  query -> is_prime -> dif1 -> dif2 -> dif3 -> leaf
}
```

> fyou [`aggregate/3`](https://www.swi-prolog.org/pldoc/doc_for?object=aggregate/3)! Its magic cannot be explained in terms of the derivation tree.


### SQL GROUP BY equivalent

```prolog
secret_stash(bananas, diddy, 3).
secret_stash(bananas, kong, 4).
secret_stash(bananas, chimpsky, 2).
secret_stash(apples, diddy, 1).
secret_stash(apples, kong, 1).
secret_stash(apples, chimpsky, 1).

print_item([I,Qs]) :- sum_list(Qs, Q), format("~w:~w, ", [I, Q]).
group_by_item :- bagof([Item, Qs],
                       bagof(Q, Owner^secret_stash(Item,Owner,Q), Qs),
                       Inventory),
                 forall(member(M, Inventory), print_item(M)).
% prints: "apples:3, bananas:9"
```

> The `^` operator indicates free variable `Owner` is NOT part of the group by key.


### Add/remove relations at runtime

```prolog
?- forall(between(1,9,X), (Y is X*X, assertz(square(X,Y)))),
   forall(between(1,4,X), retract(square(X,_))),
   forall(square(X,Y), format("square(~w,~w), ", [X,Y])).
% prints: "square(5,25), square(6,36), square(7,49), square(8,64), square(9,81)"
```

## Prolog vs Haskell

Both rely on pattern matching (aka unification) and data types (aka `structure`s).
However Haskell lacks the concept of truth for a relation.
Therefore it can only validate `binding`s, it cannot compute valid instantiations of variables.

```prolog
vehicle("Kia", 200).
vehicle("Zx9r", 250).
vehicle("KTM", 220).
is_faster(X,Y) :- X = vehicle(_,Speed1), Y = vehicle(_,Speed2),
                  call(X), call(Y),
                  Speed1 > Speed2.

?- is_faster(X, vehicle("Kia", 200)).
% returns vehicle("Zx9r", 250), vehicle("KTM", 220)
?- is_faster(vehicle("Subaru", 240), vehicle("Kia", 200)).
% returns false (vehicle is not in the database)
```

```hs
data Vehicle = Vehicle String Integer
kia = Vehicle "Kia" 200
zx9r = Vehicle "Zx9r" 250
ktm = Vehicle "KTM" 220
is_faster (Vehicle _ speed1) (Vehicle _ speed2) = speed1 > speed2

is_faster x kia
-- ERROR (variable x is unknown)
is_faster (Vehicle "Subaru" 240) kia
-- returns True
```

[0]: https://www.swi-prolog.org/pldoc/man?section=glossary
[1]: https://www.swi-prolog.org/pldoc/doc_for?object=(initialization)/1

