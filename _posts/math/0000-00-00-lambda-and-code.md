---
title: Math, Lambda theory vs programming
date: 2016-06-07
my_extra_options: [ math_notation ]
categories: [cs_related, math]
---

Some simple examples of how you can relate the results of lambda calculus to some actual code.

### Untypable expressions in strongly typed languages

In C++ you cannot a function with itself as argument. Unless you disable type checking by casting to `void*`.

{% highlight c++ %}
  void* func (void* arg) {
    return arg;
  }

  int main (void) {
    func( reinterpret_cast<void*>(func) );
    return 0;
  }
{% endhighlight %}

### Unsolvable terms as unterminating computations

When you run the python equivalent to the $$\Omega$$ combinator, you get a stack overflow error. Program evaluation is related to $$\beta$$ reduction of terms.

{% highlight python %}
  def omega (f):
    return f(f)

  Omega = omega(omega)
{% endhighlight %}

### Limitations of stringly normalizable types

The following program cannot be expressed as a typable term because it loops.

{% highlight python %}
  def loop_if_one (number):
    if 0 + number:
      while True: pass
    return 0  

  loop_if_one (0)
  loop_if_one (1)
{% endhighlight %}

However if we add the Y fixed point combinator to the set of typable terms we can write something like this.

$$\begin{align}
  & A _ + = \lambda n_1n_2fx.n_1f(n_2fx) \quad \mbox{addition of church numerals}\\
  & \Phi = \lambda z.(A _ +c_0z)Yc_0\\
  & \Phi c_0 \rightarrow (A _ +c_0c_0)Yc_0 \twoheadrightarrow c_0Yc_0 \rightarrow c_0\\
  & \Phi c_n \rightarrow (A _ +c_0c_n)Yc_0 \twoheadrightarrow Y^{n-1}(Yc_0) \rightarrow Y^{n-1}(c_0Yc_0) ...
\end{align}$$

### Expression evaluation and subject reduction theorem

* You always assume that an expression type will not change as it is evaluated by the processor

> Arithmetic : `3*2 : int` and `6 : int`  
> Function calls : `square_root(2) : int` and `4 : int`

* However this relies on the fact that the evaluation order is not random

> The ternary operator evaluates first the condition, then the corresponding operand  
> Otherwise this expression `y == 0 ? y : 1/y` may not have a type

### Decide if a term has a valid type

Template argument deduction and SFINAE may rely on the fact we can always tell if something has a valid type given the context.

{% highlight c++ %}
  template <class T, class V>
  typename enable_if<!is_same<T,V>::value>::type func_candidate (T t1, V t2) {
    printf("func_candidate : T != V\n");
  } 

  template <class T, class V>
  typename enable_if<is_same<T,V>::value>::type func_candidate (T t1, V t2) {
    printf("func_candidate : T == V\n");
  }

  int main () {
    func_candidate(666,666);
    func_candidate(333,333.3);
    return 0;
  }
{% endhighlight %}

Can we say that the compiler checks if is_same<T,V> has a valid type ?

* For $$\Gamma = \{ S:\sigma\Rightarrow\sigma\Rightarrow\sigma,\ t:int,\ v:int \}$$ and term $$Stv$$
* For $$\Gamma = \{ S:\sigma\Rightarrow\sigma\Rightarrow\sigma,\ t:int,\ v:double \}$$ and term $$Stv$$

