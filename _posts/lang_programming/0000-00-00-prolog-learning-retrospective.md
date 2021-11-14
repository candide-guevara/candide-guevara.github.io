---
title: Prolog, Learning retrospective
date: 2021-07-09
categories: [quick_notes]
---

## Questions to solve

* Difference `is`, `=`, `==` and `=:=`.
* Relation of implication to cut and conditional branches.
* functions like `max` actually have a return value (aka not predicates) ?

## Built-ins to

* Get min/max of a list.
* Get all bindings solving a goal inside a list.

## Important concepts

* Vocabulary: clause/goal, atom/variable, grounded/free variable.
* Unification and pattern matching (types and lists).
* Derivation tree.
  * How cut acts on the derivation tree traversal.
  * How "local" is `!`
  * How to build derivation trees composing 'and' and 'or' rules.
* Derivation tree Vs Clause tree (aka a proof of a goal).
  * Do not like 'and'/'or' are inverted in representation.
* Interpretation as predicate logic (specially for `not` clauses).
* Relation with haskell : arithmetic types and functors.
  * Predicate notation can be used to pattern match structs of data.
* Finding values that satify a property Vs verifying a property values hold.
* Reflection : `functor`, `clause`.
* Constructing language atoms using custom operators and pattern match on them.

## WTF

* `Warning: Singleton variables: [X]`
* How to understand when free variable will generate bindings to atoms ?
* Documentation method signatures what is `-`, `+`, `?`
  * `union(+,+,-), member(?Elem, ?List)`
* `^` existential quantifier : `bagof(Z,X^Y^p(X,Y,Z),Bag).`
* Keeping state : accumulator Vs self-modifying using `assert/retract`

```prolog
leaf_1(X) :- not(is_parent(X,_)). %only works if grounded%
leaf_2(X) :- is_parent(_,X), not(is_parent(X,_)).
```

