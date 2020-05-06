---
title: Rant, Complaining about code
date: 2015-12-03
categories: [misc]
---

Everywhere I go people complain. Over and over I hear :

* "This is a piece of crap"
* "What were these people thinking when they wrote it ?"
* "Surely the work of a trainee in a miserable internship"
* "Even my grand mother can do better than that"

Sure, I also bitch about code. But I am trying to stop.
I believe it will just make your life miserable, working with a code base you hate every day.
Also, your rants may undermine the work of a fellow collegue. Yeah that nice guy/lady you have lunch with.

It is like cleaning your home. The moment you stop, dirt will just slowly creep back in. You just cannot beat dust.
As soon as you release something you cannot spend all of your time refactoring. Up to you to decide, either learn 
to cope with it or live in your own aseptic bubble isolated from other coders.

Also why do you think you have the canonical definition of "good code" ? Maybe the guys before were masters of
template meta-programming. The fact that you and me cannot understand what the f\*\*k they meant does not mean 
they were not efficient at maintining it.

Legacy code (were original authors have vanished) gets by far the largest share of complaints. Maybe this
neat library you like did not exist at the time and they had to code it themselves. Or even better, maybe they were
actually smarter and had a better grasp of the context. They deliberately chose not to use a given library/framework
because they knew about some important limitation you have not encountered yet.

Often when I ask code haters why don't they just rewrite it, I get an interesting answer:

* The code is so full of quirks I cannot make iso functional !

I believe this is just a proof of how good the code actually is. By going through countless cycles of bug->debug->patch
the source has gained the ability of coexisting in peace with its environment. The cyclomatic complexity may hit the
roof with all of those `if (something) // cf BUG 123498`, but this is not a sign of flawed code. Its the war scars of
a veteran code base that has survived throughout the years.

Bottom line, I think it is healthier to bitch about people that bitch about code.

