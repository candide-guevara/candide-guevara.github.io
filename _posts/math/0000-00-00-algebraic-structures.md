---
title: Math, Algebraic structures
date: 2019-09-10
my_extra_options: [ math_notation, graphviz ]
categories: [cs_related]
---

## A taxonomy of algebraic structures

```myviz
digraph {
  splines=ortho
  subgraph cluster_plus {
    label="properties for `+` operation"
    style=dashed
    assot1 [shape=box, color=red,     label="assotiative\na+(b+c) = (a+b)+c"]
    commu1 [shape=box, color=blue,    label="commutative\na+b=b+a"]
    unitt1 [shape=box, color=magenta, label="identity\nx + 0 = x"]
    inver1 [shape=box, color=green,   label="all elements\nhave an inverse"]

    assot1 -> inver1 -> unitt1 -> commu1 [style=invis]
    {rank=same assot1 inver1 unitt1 commu1}
  }

  subgraph cluster_time {
    label="properties for `*` operation"
    style=dashed
    zerodv [shape=box, color=darkgreen, label="No zero divisor\na*b=0 => a=0||b=0"]
    assot2 [shape=box, color=red,       label="assotiative\na*(b*c) = (a*b)*c"]
    commu2 [shape=box, color=blue,      label="commutative\na+b=b+a"]
    distri [shape=box, color=orange,    label="distributive\na*(b+c) = a*b+a*c"]
    unitt2 [shape=box, color=magenta,   label="identity\nx + I = x"]
    inver2 [shape=box, color=green,     label="all elements but 0\nhave an inverse"]

    zerodv -> assot2 -> inver2 -> unitt2 -> commu2 -> distri [style=invis]
    {rank=same zerodv assot2 distri unitt2 inver2 commu2}
  }

  monoid [shape=record, label="{Monoid|Semi group if no identity}"]
  groupp [shape=box, label="Group"]
  abelgr [shape=box, label="Abelian group"]
  ringgg [shape=record, label="{Ring|Rng if no identity}"]
  domain [shape=record, label="{Integral Domain|Domain if not commutative}"]
  fieldd [shape=box, label="Field"]
  module [shape=record, label="{Module|scalar is a ring}"]
  vector [shape=record, label="{Vector space|scalar is a field}"]

  assot1 -> monoid [color=red]
  unitt1 -> monoid [color=magenta]
  monoid -> groupp [weight=100]
  inver1 -> groupp [color=green]
  groupp -> abelgr [weight=100]
  commu1 -> abelgr [color=blue]
  abelgr -> module
  abelgr -> vector
  abelgr -> ringgg [weight=100]
  assot2 -> ringgg [color=red, constraint=false]
  unitt2 -> ringgg [color=magenta, constraint=false]
  distri -> ringgg [color=orange, constraint=false]
  ringgg -> domain [weight=100]
  commu2 -> domain [color=blue, constraint=false]
  zerodv -> domain [color=darkgreen, constraint=false]
  domain -> fieldd [weight=100]
  inver2 -> fieldd [color=green, constraint=false]

  iduniq [shape=none, margin="0,0", label="identity is unique\nand commutes"]
  ivuniq [shape=none, margin="0,0", label="inverse is unique\nand commutes\n a+(-a) = (-a)+a = I"]
  zeroml [shape=none, margin="0,0", label="Zero multiplication\na*0 = 0"]
  inver1 -> ivuniq [dir=none, weight=0]
  unitt1 -> iduniq [dir=none, weight=0]
  zeroml -> distri [dir=none]

  fieldd -> inver2 [minlen=2, style=invis]  
  {rank=same fieldd zeroml}
}
```

### Constructed structures

```myviz
digraph {
  groupp [shape=box, label="Group"]
  cosett [shape=parallelogram, label="Coset"]
  subgrp [shape=box, label="Subgroup"]
  kernel [shape=box, label="Kernel"]
  simple [shape=box, label="Simple group"]
  normal [shape=box, label="Normal group"]
  quogrp [shape=record, label="{Quotient|group or ring}"]

  ringgg [shape=box, label="Ring"]
  ideall [shape=box, label="Ideal"]
  untgrp [shape=box, label="Group of Units"]
  fieldd [shape=box, label="Field"]
  extent [shape=record, label="{Extension|ring or field}"]
  polyno [shape=box, label="Polynomial ring"]
  ratiof [shape=box, label="Rational function field"]

  groupp -> subgrp [weight=3]
  groupp -> quogrp
  groupp -> untgrp
  subgrp -> cosett [style=dashed]
  subgrp -> kernel
  subgrp -> simple
  subgrp -> normal
  normal -> quogrp [style=dashed]

  ringgg -> ideall [weight=3]
  ringgg -> quogrp 
  ringgg -> untgrp [style=dashed]
  ringgg -> extent
  ideall -> quogrp [style=dashed]
  fieldd -> extent
  extent -> polyno
  extent -> ratiof

  {rank=same groupp ringgg fieldd}
}
```

## Structure examples

### Cyclic groups

```mytex
Let\ x \in G\ and\ x \neq 0
\langle x \rangle = \{ ... x^{-2}, x^{-1}, 0, x, x^2 ... \}\quad is\ a\ cyclic\ subgroup\ of\ G
For\ example\ :
\langle 1 \rangle = \mathbb{Z}\ with\ addition
```

### Symmetric groups

* $$S_n$$ is the group of all permutations of n elements.
* Cardinality $$\|S_n\| = n!$$
* Every element in $$S_n$$ can be written as composition of **disjoint cycles**
* Every element in $$S_n$$ can be written as composition of **transpositions**

```mytex
a \to c
b \to e \quad can\ be\ written\ as\ cycles \quad (a\ c\ d)(b\ e)
c \to d \quad or\ as\ transpositions \quad (c\ a)(c\ d)(b\ e)
d \to a
e \to b
```

* $$P \in S_n$$ is an **even permutation** iff it can only be decomposed as a even number of transpositions.
  * Equivalent defintion : $$\{(x,y) \mid x < y\ and\ P(y) > P(x)\}$$ has an **even cardinality**
* The alternating group $$A_n$$ is the subgroup of even permutations in $$S_n$$

### Matric groups: general and linear

* $$GL_n(\mathbb{R})$$ is the general linear group of $$n \times n$$ matrices with real coefficients.
  * Definition : $$\{A \in M_n \mid det(A) \neq 0\}$$
* $$SL_n(\mathbb{R})$$ is the special linear group of $$n \times n$$ matrices with real coefficients.
  * Definition : $$\{A \in M_n \mid det(A) = 1\}$$
  * $$SL_n(\mathbb{R})$$ is a subgroup of $$GL_n(\mathbb{R})$$
  * Reminder : $$\forall A,B \in M_n \quad det(AB) = det(A)det(B)$$


## Theorems

### Subgroup cardinality (Lagrange theorem)

For all finite groups, the cardinality of any subgroup divides the cardinality of the group.

```mytex
\mbox{Let H be a proper subgroup of G : } H=\{1 ... h_n\} \subset G \mbox{ and G finite} 
\forall x_1 \in G \setminus H \implies x_1H=\{x_1 ... x_1h_n\} \cap H = \emptyset
\forall x_2 \in G \setminus H \setminus x_1H \implies x_2H \cap x_1H = \emptyset
\implies \exists \{x_1...x_k\} \in G \mbox{ so that } \bigcup x_iH = G \mbox{ and } |G| = k \times |H|
```

$$x_1H...x_kH$$ is called a **coset** decomposition of G.

### Normal subgroups and quotient groups

```mytex
Let\ H \subset G\ and\ \{H, x_2H ... x_kH\}\ a\ coset\ decomposition\ of\ G
Define\ the\ operation\ +_q\ on\ \{0, x_2 ... x_k\}\ as\quad (x_i +_q x_j) \to x_l\quad tq\ x_i+x_j \in x_lH
Then\ +_q|\{0, x_2 ... x_k\}\ is\ a\ group
\iff H\ is\ a\ normal\ subgroup
\iff \forall y \in G \quad yHy^{-1} = H
```

`G` is a simple group if its only normal groups are `{0}` and `G`.

### Kernel of a homomorphism

An **homomorphism** is a function $$f:G_1 \to G_2$$ so that $$\forall x,y \in G_1\quad f(x + y) = f(x) + f(y)$$.  
An **isomorphism** is a bijective homomorphism.

* Corollary : homomorphism respects identities $$f(0_1) = 0_2$$
* Corollary : homomorphism respects inverses $$f(a^{-1}) = f(a)^{-1}$$

Kernel is the subgroup of elements in $$G_1$$ that map to the identity in $$G_2$$.

```mytex
ker(f) = \{x \in G_1 \mid f(x) = 0_2\}
```

### Cayley theorem : every group is isomorphic to a permutation group

For finite groups this means that every group is isomorphic to a subgroup of $$S_n$$.  
Here is how you can construct an isomorphic group :

```mytex
Let\ G = \{0, x_1 ... x_n\}
\forall x \in G \quad x+G = \{x, x+x_1 ... x+x_n\} = G
Let\ P_x\ the\ permutation \quad \{0, x_1 ... x_n\} \to \{x, x+x_1 ... x+x_n\}
\forall x,y \in G \quad P_x \circ P_y = P_{x+y}
```

