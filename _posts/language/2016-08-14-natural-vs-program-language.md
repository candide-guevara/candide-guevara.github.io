---
layout: post
title: Natural Vs Programming languages
categories : [ article, language ]
---

Learning natural languages versus mathematics or programming really stresses different parts of my brain.
After many years of learning different stuff you start to understand how your brain does it.

# Conscious and unconscious learning

Somehow we can argue that natural languages are more "human" than programming languages.
For example in spanish the verb __to be__ has a distinct form for each tense (soy/era/fui/seré).
Despite the sheer quantity of verbal forms, I rarely have to think about which one to use when I am speaking.

In comparison, I always struggle to know which is the name of the method to get the lenght of a sequence in C#. Is it __Count, Size, Lenght__ ? Is it a property or a method ?
Let alone spelling correctly a TSQL **MERGE** statement without looking at the documentation. No matter how many times I have done it !!
My human intuition does not work in this scenario. Thank god nowadays IDE autocompletion basically writes 90% of the code.

Many other tasks are also trival for natural languages speakers. Like expressing different nuances by changing word other. Or infering the correct meaning of a word depending on the context.
Yet these are exactly the same things that will get frowned upon a code review because they are considered unreadable.

## Examples : express natural language with code

* "Je lui ai collé un gros pain" : in French it actually means to "punch someone" but literally "I glued on him a big bread"  
  Now show this to your colleagues :

{% highlight c# %}
  public void bread (Context ctx) {
    if (ctx == HIT_SOMEONE)
      throw new Exception("Ouch!");
    else
      eatIt();
  }
{% endhighlight %}

* The verb "to be" is heavily overloaded with many meanings.  
  Now try to get this pass a code review:

{% highlight c# %}
  public class Person {
    Feeling  _currentFeeling;
    Location _currentLocation;
    Action   _currentAction;

    public bool is (Feeling);
    public bool is (Location);
    public bool is (Action);
  }

  Person p = new Person();
  print( p.is(happy) == true );
  print( p.is(thinking) == true );
  print( p.is(inParis) == true );
{% endhighlight %}

This may be a good proof that compilers and human understand information in completely different ways.
I barely know what subject means, and I cannot build a syntax tree of every sentence I read. Nevertheless I can still understand them.

## Intuition Vs Rule application

Getting back to the conscious/unconscious argument, the fact I struggle to understand some pieces of codes shows that I do not use the same parts of my brain for languages vs code.
When I read code I am forcing myself consciously to think like the compiler. C++ template declarations are a good example.

{% highlight c++ %}
  template <class Vector>
  typename Vector::value_type maxElementInVector(Vector& container) {
    /* bla bla */
  }

  void doSomething () {
    std::vector<int> nums {3, 4, 2, 8, 15, 267};
    maxElementInVector(nums);
  }
{% endhighlight %}

It is a common mistake to forget __typename__ in `template <class Vector>`.
In written english the keyword is redundant because you can infer Vector::value\_type is a type and not a variable from the semantics and context. 

* Semantics : there is "type" in `value_type`
* Context : the token is at the beginning of the function signature. A place where normally return types are.

## Mimicking human reasoning in compilers

Furthermore, when language designers try to get smart and bake many of the mechanism we unconsciously use to disambiguate expressions it gets even more intricate for humans.
Think about [C++ symbol resolution][0], the standard defines many well know mechanisms to determine which function you want to call.

* ADL : pull the different meanings of a word by looking at the sentence
* SFINAE : If it does not make sense, then it is not what you meant
* Partial ordering : select the meaning that best fits the context

I guess you cannot (and you should not) make the compiler smart like a human. It will all fall apart when you realize that compilation must be produce always the same results.
It is socially acceptable to have misunderstandings during a conversation. You are not expected to master grammar perfectly in order to communicate. You just need a feeling for the rules.
You can ask your interlocutor to rephrase, the compiler expects an exact formulation.

Maybe only master programmers truly have the same intuition about words and code.

## What properties of natural language may be useful in programming

One thing I feel progamming languages ought to develop are ways to better express relations between statements.

* Concurrency : it is easy to say two things happen at the same time. Like this "While I cook my brother opens the wine"  
  Using only vanilla features of the language, you can express this in code :

{% highlight c# %}
  public void prepareDinner () {
    Thread.Start(cookRoutine);
    Thread.Start(wineRoutine);
  }
{% endhighlight %}

In this case the relation between the two statements is that they belong to the same function. It is obvious that they are needed to prepare a meal.
But to understand they happen in parallel you have to make the effort of simulate that piece of code.

* Sequence : actions must follow a certain sequence. Like this "Marinate the pork loin before roasting it"  
  A naive approach to put this in code : 

{% highlight c# %}
  public Meat cookDeliciousPork (Meat loin) {
    marinate(loin); // 1
    roast(loin);    // 2
    return loin;
  }
{% endhighlight %}

If you are not familiar with the domain you are working in you may be tempted to invert statements 1 and 2. There is nothing telling you it will break the recipe.
A more functional approach can solve this though.

{% highlight c# %}
  public Meat cookDeliciousPork (Meat loin) {
    Meat marinatedLoin = marinate(loin);     // 1
    Meat roastedLoin = roast(marinatedLoin); // 2
    return roastedLoin;
  }
{% endhighlight %}

Less error prone but you still have to make an effort to see statement 2 depends on 1. You need to notice that 1 produces the variable consumed by 2.

# Rant: Old dogs do not learn new tricks ?

On a different subject, does your age affect the way you assimilate new languages ?
I have heard many people say that you cannot easily learn a new language when you are old.
It may be true of pronunciacion, after a decade living in France I have not managed to lose my accent.

However it is quite the opposite when focusing on grammar. Even if I learned faster when I was a kid, I never asked myself questions like :

* Why the same verbal forms are used in different tenses (in italian/spanish imperative and present)
* How english and spanish express the same nuance in different ways
    * cuando __era__ joven __tenía__ un perro / When I __was__ young I __used to__ have a dog
* How programming languages are regular compared to natural languages
    * You do not need tenses because the past and future of a program execution is collapsed into its present memory state.
    * The "english-like" programming languages get the worst of both : difficult to memorize and no expressivity gain. I am looking at you SQL !!
* Would programming languages be radically different if there were not English-based ?
    * Ruby was invented by a Japanese but I do not know it enough to see any fundamental differences to Python.

At the end it will take me more time but the result is a deeper understanding of the particular language I learned. As a bonus I also get a better idea of how languages relate to each other.
Or maybe I was just a dumb child ...

[0]: {% post_url 2015-07-07-cpp-symbol-resolution %}


