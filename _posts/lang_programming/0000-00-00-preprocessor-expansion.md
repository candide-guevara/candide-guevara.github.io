---
title: C preprocessor makes you loose your mind
date: 2015-12-08
categories: [cs_related, c_lang]
---

## Useful tips
* `gcc -E` to output preprocessor expansion to stdout
* `__COUNTER__` (gnu extension) expands to an unique number
* `__FILE__` and `__LINE__` predefined macros (standard)
* `__func__` (C99/C++11 standard) and `__PRETTY_FUNCTION__` (gnu extension) "magic" variables (technically not macros)

{% highlight c++ %}
  struct a {
   void sub (int i)
     {
       std::cout << "__func__ = " << __func__ << std::endl;
       std::cout << "__PRETTY_FUNCTION__ = " << __PRETTY_FUNCTION__ << std::endl;
     }
  };

  => __func__ = sub
  => __PRETTY_FUNCTION__ = a::sub(int)
{% endhighlight %}

## Concatenation and stringification
* `#` to stringify macro arguments
* `##` to concatenate macro arguments

### !! Remember : concatenation and stringification **INHIBIT expansion** !!

    #define file_line      __FILE__ ## __LINE__
      file_line => __FILE____LINE__

    #define ERR_NO_BANANAS 666
    #define print_err(error)   printf("ERROR:" #error)
      print_err(ERR_NO_BANANAS) => printf("ERROR:" "ERR_NO_BANANAS")

## Model for function macro evaluation
    
    #define yes  HELL YEAH
    #define ask_about(something, answer)  do you like something ? answer
    #define like_bananas(answer)          ask_about(bananas, answer)
    
    like_bananas(yes)  // what does this expands to ?

* Replace function with macro body  
  `like_bananas(yes) => ask_about(bananas, answer)`

* Replace macro parameter with call arguments  
  `ask_about(bananas, answer) => ask_about(bananas, yes)`

* Perform argument expansion (unless concatenate/stringify)  
  `ask_about(bananas, yes) => ask_about(bananas, HELL YEAH)`

* Recurse and attempt to expand result again  
  `ask_about(bananas, HELL YEAH)  => do you like something ? answer`  
  `do you like something ? answer => do you like bananas ? HELL YEAH`

Notice macro evaluation order is **the opposite** of code evaluation.

    #define f_macro(arg)  __COUNTER__
    #define paste(arg)    prefix_ ## arg

    paste(f_macro()) => prefix_f_macro()

Even if argument pre-scan gives the wrong impression. Notice pre-scan does a **full recursive** argument evaluation.

    #define f_macro(arg)  argument:__COUNTER__ inner:arg
    #define rec_exp(arg)  body:__COUNTER__ arg

    rec_exp(f_macro(__COUNTER__)) => body:2 argument:1 inner:0

## The classical paste problem

    #define paste(a,b)     a ## b
    #define bad_id(token)  paste(token, __COUNTER__)
  
    bad_id(monkey) => monkey__COUNTER__

    #define paste_helper(a,b)  paste(a,b)
    #define good_id(token)     paste_helper(token, __COUNTER__)
  
    good_id(monkey) => monkey0

## Variadic macros
Use `...` to define a variable number of arguments for a function macro. You can refer to the argument pack using `__VA_ARGS__`. 
Notice `##__VA_ARGS__` does not concatenate tokens. In this case it will just remove the comma for empty argument packs.

    #define LOG(fmt, ...)  printf(fmt, ## __VA_ARGS__)

    LOG("salut");
    LOG("Hey %s %s", "mr", "monkey")

## Self-referent macros
Macros are expanded recursively, however a given function macro can only be expanded **once**. If it is encountered again during expansion, it will NOT be expanded again.

    #define paste(a, ...)   a paste( __VA_ARGS__ )
    #define paste_1(a, ...) a paste_2( __VA_ARGS__ )
    #define paste_2(a, ...) a paste_1( __VA_ARGS__ )

    paste(1,2,3,4,56)   => 1 paste( 2,3,4,56 )
    paste_1(1,2,3,4,56) => 1 2 paste_1( 3,4,56 )
    paste_2(1,2,3,4,56) => 1 2 paste_2( 3,4,56 )

## [Other pitfalls][0]
* Duplication of side effects
* Expansion/concatenation to invalid tokens (ex `monkey ## . ## bananas`)
* Fixing semi colon problem by wrapping macro in `do { ... } while(0)`

[0]: https://gcc.gnu.org/onlinedocs/cpp/Macro-Pitfalls.html#Macro-Pitfalls

