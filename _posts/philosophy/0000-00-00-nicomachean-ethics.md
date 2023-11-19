---
title: Philo, Nicomachean ethics
date: 2023-11-18
my_extra_options: [ graphviz ]
categories: [misc]
---

Boxes in <span style="color:blue">blue</span> correspond to my ideas.

```myviz
digraph {
  layout=dot
  rankdir=BT
  node [fontsize=11 fontname=sans shape=box]

  eudaimonia [shape=oval
    width=2.2
    color=red
    penwidth=2
    label="Eudaimonia
Human flourishing"]
  good [width=1.4
    label="What is good?"]
  induction [width=2.0
    label="Induction on the question
of what is the purpose
of any action."]
  telos [width=2.0
    label="Telos
Live to fulfill your purpose"]
  virtue [width=2.2
    label="Virtue
is the golden mean between
excessive behaviours"]
  practice [width=1.8
    label="Practical
application of virtue
not only knowledge"]
  phronesis [width=2.2
    color=red
    penwidth=2
    label="Phronesis
allows to determine the
correct action for a situation"]
  notfixed [width=2.2
    label="There is no set of
fixed laws to describe virtue."]
  experience [width=2.0
    label="Life experience
nourishes our phronesis"]
  endoxa [width=1.6
    label="Endoxa
Cultural context"]
  reason [width=2.0
    label="Reason gives us
the ability to understand
what virtue is"]
  cardinal [width=1.2
    label="Cardinal virtues
* Phronesis
* Courage
* Justice
* Temperance"]
  joy [width=1.6
    color=red
    penwidth=2
    label="Acting virtuosly
should bring joy"]
  fakeit [width=1.8
    label="If you practice
virtue you will develop
an appreciation for it"]
  education [width=1.8
    label="Education
brings us to appreciate
virtuous action"]
  wealth [width=2.6
    label="Wealthy and healthy individuals
that are not burdened with pain
have the discretion for virtue"]
  politic [width=2.5
    label="Politics
must understand eudaimonia to
allow the flourishing of all"]
  civility [width=2.2
    color=blue
    label="Civility
is phronesis applied to the
flourishing of social order"]
  society [width=2.4
    color=blue
    label="A virtuous society
enjoys more freedom because
it requres less laws"]
  lifetime [width=2.4
    label="Considered over a lifetime
Only the trail our life leaves on
the world can be judged"]
  carryon [width=1.8
    color=blue
    label="Only joy can keep us
engaged with virtue
during a lifetime"]
  categorical [width=2.5
    color=blue
    label="Kant's categorical imperative
is sound theoretically but
cannot provide infinite willpower"]
  selfish [width=2.2
    label="Selfish pursuit
Flourish for my sake only ?"]
  friends [width=2.8
    label="Friendship
* Imperfect if for advantage/pleasure
* True if you act for the other's sake"]
  equality [width=2.6
    label="True friendship
can only grown between equals
since your friend is another self"]
  dialectic [width=2.6
    color=blue
    penwidth=2
    label="Wisdom can only be
achieved through dialectic
the reflection of yourself in others"]

  eudaimonia -> virtue [dir=back, style=invis]
  telos -> virtue [dir=back, constraint=false]
  eudaimonia -> telos [dir=back]
  good -> eudaimonia
  induction -> good
  virtue -> practice [dir=back]
  virtue -> phronesis [dir=back]
  virtue -> cardinal [dir=back]
  cardinal -> phronesis [dir=back, constraint=false]
  phronesis -> notfixed [dir=back]
  phronesis -> civility [dir=back]
  civility -> society [dir=back]
  notfixed -> reason [dir=back]
  notfixed -> experience [dir=back]
  notfixed -> endoxa [dir=back]
  endoxa -> experience [style=invis]
  practice -> joy [dir=back]
  joy -> fakeit [dir=back]
  joy -> education [dir=back]
  joy -> wealth [dir=back]
  {wealth education} -> politic [dir=back]
  society -> politic
  lifetime -> eudaimonia
  selfish -> eudaimonia
  friends -> eudaimonia
  categorical -> lifetime
  carryon -> lifetime
  equality -> friends
  dialectic -> equality

  {rank=same eudaimonia good}
}
```

### Sources

* [History of Philosophy without any gaps](https://www.historyofphilosophy.net/aristotle-ethics)
* [The Panpsycast Philosophy Podcast](https://thepanpsycast.com/panpsycast2/2017/8/3/aristotle-part-i)
* [The Art of Manliness](https://www.artofmanliness.com/character/etiquette/podcast-934-beyond-mere-politeness-the-art-of-true-civility/)

