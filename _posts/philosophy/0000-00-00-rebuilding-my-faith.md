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
I believe that I can grow deep roots in the place of my choosing by investing my time to help others.
I believe that through hard work I can reach the level of self confidence required to pay deep attention to others, without being distracted by my ego.

```myviz
digraph {
  overlap=false
  node [fontsize=11 fontname=sans shape=box]

  lifeproj [width="2.8"
    ordering=out
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
  skill [width="2.4"
    label="Skilfully drive but also follow
the conversation so there is
pleasure in the exchange"]
  topics [width="2.4"
    label="Funny, intelligent, mundane
All are equally important"]
  reflect [width="2.2"
    label="Sincerely reflect back
all the goodness you see in
your interlocutor"]
  dialectic [width="3.0"
    label="Dialectic has a dual purpose
* materialize your thoughts\l* understand a different point of view\l"]
  interact [
    shape=oval
    label="Meaningful interaction"]
  ataraxia [width="3.2"
    color=red
    penwidth=2
    shape=oval
    label="I do not want Ataraxia
I want the freedom to choose
my way through adversity"]
  confidence [width="2.4"
    label="Self-confidence
Feel equal to anyone
Listen and suspend judgement"]
  faith [width="2.4"
    label="Build a strong Faith
Constantly hone your values
And act accordingly"]

  faith -> lifeproj
  lifeproj -> {help learn}
  empathy -> topics
  topics -> skill
  attention -> {dialectic reflect}
  {help learn} -> buyin
  {buyin skill dialectic reflect} -> interact
  interact -> ataraxia
  ataraxia -> confidence [constraint=false]
  ataraxia -> faith [constraint=false]
  buyin -> faith [style=invis]
  reflect -> confidence [style=invis]
  dialectic -> confidence [style=invis]
  confidence -> attention

  {rank=same lifeproj empathy attention}
  {rank=same reflect dialectic}
  {rank=same ataraxia faith confidence}
}
```

## What I need to improve

* Have self-confidence to help others
* Attention is exploring with others areas you are not confortable in
* Be the best listener I can

