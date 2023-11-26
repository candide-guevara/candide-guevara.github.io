---
title: Philo, Rebuilding my Faith
date: 2023-11-26
my_extra_options: [ graphviz ]
categories: [misc]
---

## What is Faith?

I believe that Faith is the source of willpower required to have agency on the world.
Faith must be kept constantly in our minds so that we can draw power from it.
Faith is the set of values that allows us to understand the 3 faces of our identity:

* The vision we have for ourselves
* The way we see others
* Our purpose in the world

Faith is only as good as its believer, we are beings that will not attain absolute truth.
Faith must therefore be constantly shaped to keep us engaged with the world.

## What is **my** Faith?

I believe that I am capable of meaningful interaction with others.

```myviz
digraph {
  overlap=false
  node [fontsize=11 fontname=sans shape=box]

  lifeproj [width="2.8"
    penwidth=2
    label="Life project
Be clear on what you want to achieve"]
  empathy [width="2.8"
    penwidth=2
    label="Empathy
Try to be in unison with others"]
  attention [width="2.8"
    penwidth=2
    label="Attention
Removing your ego when listening
Be curious about others"]
  learn [width="2.2"
    label="Learn and be amazed
By the aspects of the world
that resonate with you"]
  help [width="2.2"
    label="Be part of a community
By helping others"]
  buyin [width="2.2"
    label="Convey your convictions
to inspire others"]
  skill [width="2.6"
    label="Skilfully drive but also follow
the conversation so there is
pleasure in the exchange"]
  topics [width="2.6"
    label="Funny, intelligent, mundane
All are equally important"]
  reflect [width="2.4"
    label="Sincerely reflect back
all the goodness you see in
your interlocutor"]
  dialectic [width="3.0"
    label="Dialectic has a dual purpose
* materialize your thoughts
* understand a different point of view"]
  interact [
    shape=oval
    label="Meaningful interaction"]
  absurd [width="3.2"
    color=red
    penwidth=2
    shape=oval
    label="Be at peace with
the absurd beauty of the world"]

  lifeproj -> {help learn}
  empathy -> topics
  topics -> skill
  attention -> {dialectic reflect}
  {help learn} -> buyin
  {buyin skill dialectic reflect} -> interact
  interact -> absurd

  {rank=same lifeproj empathy attention}
  {rank=same reflect dialectic}
}
```

## What I need to improve

* Have self-confidence to help others
* Attention is exploring with others areas you are not confortable in
* Be the best listener I can

