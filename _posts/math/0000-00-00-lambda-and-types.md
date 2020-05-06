---
title: Math, Lambda, notes about type systems
date: 2016-06-06
my_extra_options: [ math_notation ]
categories: [cs_related]
---

## The set of valid types

The set of valid types $$\mathbb{T}$$ is composed of :

* An initial set of countable atomic types : $$T\nu = \{ X, Y, ... \}$$
* You can compose types : $$\forall A, B \in \mathbb{T} \quad (A \Rightarrow B) \in \mathbb{T}$$

> If the type of an integer is __int__ then the type of the addition operation is : $$\quad int \Rightarrow int \Rightarrow int$$

## Church's system

Church's type system looks a lot like typed programming languages (C++ or Java) in the sense that every variable has a type from the beginning.
Let A and B be types, with $$x_a, y_a, ...$$ and $$x_b, y_b, ...$$ the set of variables of each type. Then you can construct the set of terms $$\Lambda^A\ and\ \Lambda^B$$ :

$$\begin{align}
  & x_a, y_a, ... \in \Lambda^A\\
  & s \in \Lambda^{A \Rightarrow B}\ and\ t \in \Lambda^A \quad \Rightarrow st \in \Lambda^B\\
  & s \in \Lambda^A \quad \Rightarrow \lambda x_b.s \in \Lambda^{B \Rightarrow A}
\end{align}$$

Then for each type you can define the reduction $$\rightarrow^A _ {\beta}\ in\ \Lambda^A$$.

> Example : $$\quad (\lambda x_a.x_a)y_a \rightarrow^A _ {\beta} y_a$$  
> Invalid terms : $$\quad \lambda x_a.x_a \in \Lambda^{A \Rightarrow A} \quad \Rightarrow (\lambda x_a.x_a)(\lambda x_a.x_a)$$ does not have a type  
> However : $$\quad (\lambda x _ {a \Rightarrow a}.x _ {a \Rightarrow a})(\lambda x_a.x_a) \in \Lambda^{A \Rightarrow A}$$

TODO : Does Church system has the following properties ?

* Decide if any term has a type.
* Any typable term is also strongly normalizing.

## Curry's system

Curry's type system is based on inference. A term has a type if you can find a basis $$\Gamma = {x:A_1, ..., x_n:A_n}$$ from which you can deduce the type.
This means that the same term can have an __infinite number of different types__. The rules for type deduction are :

$$\begin{align}
  & \Gamma = \{ x : A \} \vdash x : A\\
  & \Gamma = \{ s : A \Rightarrow B,\ t : A \} \vdash st : B\\ 
  & \Gamma = \{ s : A \} \setminus \{ x : B \} \vdash \lambda x.s : B \Rightarrow A\\
\end{align}$$

> Variable x can have any type : $$\quad \{ x:A \} \vdash x : A \quad or \quad \{ x : B \Rightarrow A \} \vdash x : B \Rightarrow A $$  
> Church numerals : $$\quad \Gamma = \{ \} \vdash \lambda fx.x : (A \Rightarrow A) \Rightarrow A \Rightarrow A \quad and \quad \lambda fx.f(f(fx)) : (A \Rightarrow A) \Rightarrow A \Rightarrow A $$  
> Some terms are untypable : there is no basis in which $$xx\ or\ \Omega$$ have a type

With this definition we can attribute an infinite number of types to the same term (not only by renaming type variables). There is however a concept of __principal type__.
A term has a principal type if any other type valid for that term can be obtained by substitution.

> Principal type for $$c_0$$: $$\quad T_0 = c_0 : B \Rightarrow A \Rightarrow A \quad T_0[B/A\Rightarrow A] = (A \Rightarrow A) \Rightarrow A \Rightarrow A$$  
> Principal type for $$c_1$$: $$\quad T_1 = c_0 : (B \Rightarrow A) \Rightarrow B \Rightarrow A \quad T_1[B/A] = (A \Rightarrow A) \Rightarrow A \Rightarrow A$$  

### Properties of typable terms in Curry's system

* If a term is typable then any subterm is also typable
* Subject reduction theorem : terms sharing a common type are closed under reduction. However typability is __not closed under $$\beta$$ equality__
    * For terms s,t and type A : $$\quad \Gamma \vdash s : A\ and\ s \twoheadrightarrow _ {\beta} t \quad \Rightarrow \quad \Gamma \vdash t : A$$

> Integer increment can be defined as $$I _ + = \lambda nfx.f(nfx)$$ with type $$int \Rightarrow int$$  
> All $$c_n$$ then share the same type : $$I _ +^nc_0 \twoheadrightarrow c_n$$ and $$I _ +^nc_o$$ has type $$int$$ $$\quad \Rightarrow c_n : int$$  
> All equal terms do NOT share the same type : $$\quad c_4 \twoheadleftarrow c_2c_2\ and\ c_4 : int \quad$$ but $$c_2c_2$$ is untypable

* If a term has a type then is it __strongly__ normalizable (the opposite is not always true).

> Term $$(\lambda x.xx)y$$ is strongly normalizable but $$(\lambda x.xx)y \rightarrow xx$$ does not have a type

* Principal type algorithm : the question whether any term has a type is decidable and if it is the case you can compute its principal type.
    * $$\forall s \in \Lambda$$ is there $$\Gamma$$ and $$A \in \mathbb{T}$$ so that $$\Gamma \vdash s : A$$ => decidable
    * $$\forall s \in \Lambda$$ and $$A \in \mathbb{T}$$ is there $$\Gamma$$ so that $$\Gamma \vdash s : A$$ => decidable
    * $$\forall A \in \mathbb{T}$$ is there $$s \in \Lambda$$ and $$\Gamma$$ so that $$\Gamma \vdash s : A$$ => decidable

### Extending typable terms to be Turing complete

* There is not fixed point combinator term that is typable. This in fact means that __only a small subset__ of computable functions can be expressed in this subset

> The Turing fixed point combinator $$\Theta$$ has the property : $$\forall f \in \Lambda \quad \Theta f \twoheadrightarrow f(\Theta f)$$  
> Then $$i\Theta \twoheadrightarrow i(\Theta i) ... \twoheadrightarrow i^n(\Theta i)$$ has an infinite reduction sequence so it is not typable

* If you extend the set of typable terms with a constant Y and the following axioms :

$$\begin{align}
  & \forall \sigma \in \mathbb{T} \quad Y : (\sigma \Rightarrow \sigma) \Rightarrow \sigma\\
  & \forall s \in \Lambda \quad Ys \rightarrow s(Ys)
\end{align}$$

* You get a system that can express __all__ computable functions
    * Normal forms are unique (Church-Rosser)
    * Left-most reduction is sufficient
    * Subject reduction type theorem holds

> Left-most : $$\quad (\lambda xy.y)Yi \twoheadrightarrow _ {left} i$$  
> Some terms are NOT normalizable anymore : $$\quad Yi \twoheadrightarrow i^n(Yi)$$

