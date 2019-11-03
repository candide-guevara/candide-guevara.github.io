---
title: Math, Lambda, notes about untyped calculus
date: 2016-06-05
my_extra_options: [ math_notation ]
categories: [cs_related, math]
---

As with other theories we have to define a set terms and the rules used to relate pairs terms between them.

## Lambda terms

Let $$\nu$$ be a infinite countable set of variables $$ \nu = \{ x, y, z, ... \} $$.
The set of valid lamdba terms $$\Lambda$$ is a super set of $$\nu$$ defined by the following induction rules :

$$\begin{align}
  & x \in \nu \Rightarrow x \in \Lambda \\
  & s, t \in \Lambda \Rightarrow st \in \Lambda \\
  & x \in \nu\ and\ s \in \Lambda \Rightarrow \lambda x.s \in \Lambda
\end{align}$$

> Some examples of lambda terms : $$\quad x$$, $$\ xyz$$, $$\ \lambda x.yz$$

### Combinators

Lambda terms with no [free variables][1] are called combinators or "closed terms".  
The set of all combinators is written $$\Lambda^0$$

$$\begin{align}
  & i = \lambda x.x \quad (identity)\\
  & t = k = \lambda xy.x \quad \mbox{(discard second argument, true combinator)}\\
  & f = \lambda xy.y \quad \mbox{(discard first argument, false combinator)}\\
  & \Omega = (\lambda x.xx)(\lambda x.xx)\\
  & s = \lambda xyz.xz(yz)\\
  & c_n = \lambda fx.f(f(...(fx)...)) = \lambda fx.f^nx \quad \mbox{(Church numerals)}
\end{align}$$

### Relationships between lambda terms

There are 2 types of relation between terms : identity (notation : $$\equiv$$) and equality (notation : $$=$$)

* 2 terms are __identical__ if by renaming their [bound variables][1] you obtain the __exact__ same terms character by character.  

> Examples : $$\quad I \equiv \lambda x.x \equiv \lambda y.y \quad$$ $$\lambda xyz.xxzy \equiv \lambda abc.aacb$$

* 2 terms are __equal__ based on the notion of $$\beta$$ reduction :

$$\begin{align}
  & (\lambda x.s)X \xrightarrow[\beta]{} s[x := X] \qquad \mbox{all occurences of 'x' in s have been replaced by 'X'}
\end{align}$$

> Examples : $$\quad (\lambda x.x)s \xrightarrow[\beta]{} s$$,
$$\ (\lambda xyz.xz(yz))abc \xrightarrow[\beta]{} ac(bc)$$,
$$\ \Omega \xrightarrow[\beta]{} \Omega$$

* We also have the standard properties you can expect from an equivalence relation :
    * However there is __NO__ associativity or commutativity

$$\begin{align}
  & \forall s \in \Lambda \Rightarrow s = s \\
  & s = t \Leftrightarrow t = s \\
  & s = t\ and\ v \in \Lambda \Rightarrow sv = tv\ or\ vs = vt \\
  & s = t\ and\ t = v \Rightarrow s = v \\
  & s = t \Rightarrow \lambda x.s = \lambda x.t
\end{align}$$

* $$\lambda \beta \eta$$ theory is a super set of the lambda theory adding the following reduction rule :

$$\forall s \in \Lambda\ and\ x \notin FV(s) \Rightarrow \lambda x.sx = s$$

### Weak/Head/Normal forms for $$\lambda$$ terms

* A $$\lambda$$-term is simply a term that starts with $$\lambda$$ (ignoring parenthesis)
  * Also known as "top level abstraction"

> Example : $$\quad \lambda x.xyz,\ (\lambda xz.xx)y$$

* Normal form (NF) : a term which cannot be $$\beta$$ reduced any further

> Example : $$\quad x,\ xyz,\ \lambda x.xx$$

* Head Normal form (HNF) : a term in NF which is also a $$\lambda$$-term

> Example : $$\quad \lambda x.xx,\ \lambda x.x(\lambda y.y)$$

* Weak Head Normal form (WHNF) : a $$\lambda$$-term whose "head" cannot be reduced
  * Lazy evaluated terms have WHNF in haskell

> Example Head: $$\quad (\lambda x.xx)y\ $$ the head term is $$\lambda x.xx$$  
> Example Head: $$\quad xxy\ $$ the head term is $$x$$  
> Example WNHF: $$\quad \lambda x.(\lambda y.y)x,\ \lambda xy.x(iy)$$

### Grammar construction rules for NF

* Any lambda term matches 1 of the following patterns
  * reducible : $$\quad (\lambda y.s)tu_1..u_n \mid \lambda x_1...x_m.(\lambda y.s)tu_1..u_n \quad n,m \in N$$
  * normal form : $$\quad xu_1..u_n \mid \lambda x_1...x_m.xu_1..u_n \quad n,m \in N$$

* Which translates to the following grammar rules for NF
  * $$N_F = x \mid xN_F...N_F \mid \lambda x.N_F$$

> Example : $$\quad \lambda x.x(\lambda y.y)\ $$ can be decomposed using the rules $$\quad \lambda x.N_F \to xN_F \to \lambda x.N_F \to x$$

### Normalization strategies

* A term is __normalizable__ if it can be reduced to a term in normal form
* A term is __strongly normalizable__ if any reduction strategy ends into a normal form

> Normal : $$\quad \lambda x.x$$,\ $$\ x(\lambda y.yy)z\ $$ (application from left to right)  
> Normalizable : $$\quad (\lambda xy.y)\Omega \twoheadrightarrow \lambda y.y$$ (but not strongly normalizable)  
> Strong normalizable : $$\quad [\lambda x.(\lambda y.y)x]z \twoheadrightarrow z$$

* The set of normalizable and head-normalizable terms is __disjoint__

> $$i(x\Omega) \twoheadrightarrow x\Omega\quad$$ is not normalizable but is head normalizable  
> $$ki\Omega \twoheadrightarrow i\quad$$ is a normalizable but not head normalizable


## Important theorems

* Fixed point : $$\forall s \in \Lambda\ \exists\ t$$ so that $$st = t$$

> Example : $$\quad (\lambda xy.xy)zz = (\lambda y.zy)z = zz$$

* $$\beta$$ reduction has the Church-Rosser property : if a term has a normal form it is __unique__
    * Corollary : if $$s = t \Rightarrow \exists u\ like\ s \twoheadrightarrow u\ and\ t \twoheadrightarrow u$$
    * Corollary : if $$s = t\ and\ t\ is\ normal \Rightarrow s \twoheadrightarrow t$$

> Example : $$\quad with\ c_1 = \lambda uv.uv \quad (\lambda x.c_1c_1x)y = (\lambda x.c_1x)y\ or\ c_1c_1y \quad \mbox{but at the end ... } = \lambda u.uy$$

* s = t $$\Leftrightarrow$$ there exists a chain of terms $$u_1, u_2, u_3\ ...\ $$ so that using beta reduction : 

$$\begin{array}
& s & \      & \   & \        & u_2 & \   & u _ {n-1} & \        & \   & \        & t \\
  & \searrow & \   & \swarrow & \   & ... & \         & \searrow & \   & \swarrow & \ \\
  & \        & u_1 & \        & \   & \   & \         & \        & u_n & \        & \ 
\end{array}$$

* Normalization theorem : reducing the left-most redex of a term yields its normal form if it has one.  
  However __if a term does not have a normal form, left-most reduction is NOT enough__ to prove it.

> Reduction strategy OK : $$(\lambda xyz.z)\Omega\Omega \twoheadrightarrow _ {left} \lambda z.z$$  
> Reduction strategy KO : $$\omega = \lambda x.xxx \quad \omega\omega \rightarrow _ {left} \omega\omega\omega \twoheadrightarrow _ {left} \omega^n$$

* The theory equating all un-normalizable combinators  is __inconsistent__ : $$\lambda\beta + \{ s = t \ if\ s,t \in \Lambda^0\ \mbox{and s,t NOT normalizable} \}$$
    * You can prove that : $$\quad \forall s,t \in \Lambda \Rightarrow s = t$$
* On the contrary the theory equating all combinators which do not have a __head__ normal form is consistent

### Lambda calculus can express all computable functions

* Lambda theory is turing-complete. Any [__partial recursive__][2] function $$\phi$$ can be expressed as a lambda term $$\Phi$$.
    * If $$\phi(x_1,x_2...) = X$$ then : $$\Phi(x_1', x_2'...) \twoheadrightarrow X'$$
    * If $$\exists x_1,x_2... \in N$$ were $$\phi$$ is not defined then : $$\Phi(x_1', x_2'...) \twoheadrightarrow t$$ and t __unsolvable__

> We can express multiplication by 2 using : $$\quad T _ {2x} = \lambda xuv.xu(xuv)$$  
  Example : $$\quad T _ {2x} . c_2 = \lambda uv.c_2u(c_2uv) = \lambda uv.(\lambda x.u^2x)(u^2v) = \lambda uv.u^4v = c_4$$

* Functions which are not computable (halting function) cannot be expressed as a $$\lambda$$ term  

__Proof__ : Let A and B be 2 partitions of $$\Lambda$$ defined as follows : 

$$\begin{align}
  & a \in A \Leftrightarrow a = \lambda x.x = i \\
  & b \in B \Leftrightarrow b \neq i
\end{align}$$

We have $$i \in A\ and\ \Omega \in B$$, suppose there exists a term f with the following property :

$$\begin{align}
  & \forall a \in A \quad fa = \lambda xy.y \\
  & \forall b \in B \quad fb = \lambda xy.x
\end{align}$$

We then define g as follows : $$g = \lambda x.(fx)i\Omega\ $$, by the fixed point theorem we have :

$$\begin{align}
  & \exists\ u \in \Lambda \quad gu = u = (fu)i\Omega \\
  & u \in A \quad \Rightarrow \quad fu = \lambda xy.y \quad \Rightarrow \quad u = \Omega \Rightarrow u \in B \\
  & u \in B \quad \Rightarrow \quad fu = \lambda xy.x \quad \Rightarrow \quad u = i \Rightarrow u \in A \\
\end{align}$$


## References

[Oxford University Computing Laboratory, Andrew D. Ker](http://www.cs.ox.ac.uk/andrew.ker/docs/lambdacalculus-lecture-notes-ht2009.pdf)  
[Introduction to Lambda Calculus, Henk Barendregt and Erik Barendsen](http://www.cse.chalmers.se/research/group/logic/TypesSS05/Extra/geuvers.pdf)

[1]: https://en.wikipedia.org/wiki/Lambda_calculus_definition#Free_and_bound_variables
[2]: https://en.wikipedia.org/wiki/%CE%9C-recursive_function#Definition

