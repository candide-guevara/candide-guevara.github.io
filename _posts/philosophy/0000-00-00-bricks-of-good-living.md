---
title: Philo, Bricks for a good life
date: 2021-02-05
my_extra_options: [ graphviz ]
categories: [misc]
---

```myviz
digraph {
  //layout=neato
  //nodesep=0.6
  overlap=false
  node [fontsize=12 fontname=sans shape=box]
  //edge [len=0.8]

  faith [width="4.2"
    color=red
    penwidth=2
    label="Faith is cyclical
Faith motivates us to pursue the good life.
But it must be shaped by life experience itself."]
  balance [width="4.2"
    label="Keep improving your definition of balance.\nStrive to meet that goal."]
  self_others [width="4.2"
    label="Happiness comes both from individual freedom\nand a sense of belonging to something larger."]
  shame [width="4.2"
    label="There is no shame in being inferior to others.\nThere is shame in not meeting your potential."]
  accept [width="4.2"
    label="Accept you will lose because life is unfair.\nBut that nevers make the attempt meaningless."]
  tragedy [width="4.2"
    label="Life's a tragedy, you cannot control everything\nEndure hardships, do not waste your time\npondering why things are the way they are."]
  reflection [width="4.2"
    color=red
    penwidth=2
    label="Any of your actions that go against your values\nreflect on your perception of the world\nmaking it more hostile."]
  frugal [width="4.0"
    label="Be frugal with your energy.
You are a finite being. Exercise your freedom by
focusing on the things that matter to you."]
  absurd [width="4.6"
    color=red
    penwidth=2
    label="Absurdity is beautiful
Pain and sadness are the root of better things to come
if you act to counter the true nature of the problem."]
  explore [width="4.2"
    label="Do not get frustrated when you meet a wall.\nDiscover the many others paths that will\ngive meaning to your life."]
  frustration [width="3.8"
    label="The frustrations of your human condition\nwill hurt you if you are too self centered.\n"]
  virtue [width="3.8"
    label="No matter how flawed each individual is,\nsociety can transcend the human condition\nif everyone pursues virtue."]
  help [width="3.8"
    label="Everytime you help someone else you\nget a sense of belonging to a community.\nYou fight the fear of being on your own"]

  faith -> {balance tragedy}
  tragedy -> explore
  explore -> absurd
  explore -> frugal
  tragedy -> accept
  balance -> accept
  balance -> self_others
  accept -> shame
  help -> reflection [dir=back]
  self_others -> help
  shame -> frustration
  {help frustration absurd} -> virtue

  {rank=same virtue reflection}
  {rank=same frustration absurd}
}
```

## Sometimes there is no joy in virtue

And without joy, no amount of willpower can give you the energy to carry on :/

## Balance and virtues

```myviz
digraph {
  rankdir=LR
  node [fontsize=12 fontname=sans shape=box]

  selflessness [shape=oval
    label="Selflessness,\nYou are part of something larger.\nRepay the blessings you have received.\n "]
  selfimprove [shape=oval
    label="Self improvement,\nUse your freedom wisely.\nShape your life to give it meaning.\n "]
  forgiveness [width="4.0"
    label="Forgiveness,\nLife should not always be a struggle.\nAccept yourself, save energy for what matters."]
  endurance [width="4.0"
    label="Endurance,\nDo not always yield to the path of lower effort."]
  humility [width="4.0"
    label="Humility,\nAccept you have to take small steps.\nDo not let pride inhibit action."]
  patience [width="4.0"
    label="Patience,\nDo not be discouraged by slow progress.\nProgression is not linear,\ncontinue despite setbacks."]
  selfquest [width="3.6"
    label="Self questioning,\nDo I like the color I am giving to my life ?\nHow can I find joy in pursuing a moral life ?"]
  modesty [width="3.6"
    label="Modesty,\nWillpower only goes so far,\nyou are also the product of luck.\nTake this into account when judging others."]
  gratitude [width="3.6"
    label="Gratitude,\nAcknowledge the good\nothers have brought to your life.\nThere is a symbiotic relation between\nyou and others."]

  selflessness -> selfimprove [weight=3 dir=both]
  selflessness -> selfquest [dir=back]
  selfquest -> selfimprove [minlen=2 constraint=none]
  modesty -> selflessness
  gratitude -> selflessness
  selfimprove -> endurance [dir=back]
  selfimprove -> forgiveness [dir=back]
  selfimprove -> humility [dir=back]
  selfimprove -> patience [dir=back]
}
```

