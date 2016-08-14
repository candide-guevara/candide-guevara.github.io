---
layout: post
title: Learning the C# language
categories : [article, windows]
---

Coming from an Unix background I was reluctant to learn C#. I was forced into it by a work assignement.
However after some days I started to appreciate the design of some APIs and the fancy language features.

## Nice things

Some nice syntactic sugar introduced way before it got to other mainstream languages like C++ or Java. All of the following were available since C# 3.0 in 2008.

* Type deduction using `var`
* RAII with `using(resource) {}` blocks
* Attribute getter/setter are easy to implement
{% highlight c# %}
  public class Chocolat {
    // Everyone can read but write protected
    public string Attr { get; private set; }
    // INVALID
    private string Attr { public get; set; }
  }
{% endhighlight %}
* Fluent API with LINQ (but I am not so fond of the SQL-like syntax)
{% highlight c# %}
  var items = new List<int> {1,2,3,4,3};
  var words = new Dictionary<int, string> { {1,"mr"}, {3,"monkey"}, {6,"coucou"} };

  // Only equi-joins are allowed in Linq, use cartesian product for other join predicates
  var fluent = words.Join(items, kv => kv.Key, x => x, (kv,x) => kv.Value)
                    .Aggregate((a,x) => a + " " + x);
  var query1 = from kv in words
               join i in items on kv.Key equals i
               select kv.Value;
          
  Console.WriteLine("fluent={0}\nquery1={1}", fluent, 
                    query1.Aggregate((a,x) => a + " " + x));

  // Notice the easy creation of anonymous types (tuple-like)
  fluent = words.GroupJoin(items, kv => kv.Key, x => x, (kv,wg) => new { w=kv.Value, c=wg.Count()})
                .Aggregate("", (a,x) => a + x + ", ");
  var query2 = from kv in words
               join i in items on kv.Key equals i into wg
               select new { w=kv.Value, c=wg.Count() };
          
  Console.WriteLine("fluent={0}\nquery2={1}", fluent, 
                    query2.Aggregate("", (a,x) => a + x + ", "));
{% endhighlight %}
* Extension methods to make static helpers less verbose (no access to private fields)
{% highlight c# %}
  public static class Extension {
    //NOTICE the this keyword in the method signature
    public static string Print(this List<string> items) {
      return String.Join(", ", items); 
    }
  }

  public static void Main() {
    var items = new List<string> { ... };
    Console.WriteLine( items.print() );
    Console.WriteLine( Extension.print(items) ); // equivalent to the first call
  }
{% endhighlight %}

More recent features follow the global trend.

* Async and await (easier to use than previous BackgroundWorker and ThreadPool)
{% highlight c# %}
  public static async Task<string> ProcessWSCallAsync() {
    Task<string> response = ... // WCF client to call webservice
    do_some_work();
    string result = await response; // yield control at this point to caller
    return result.Trim(); <--------------------|------+
  }                                            |      |
                                               |      |
  public static void Main() {                  |      |
    var wsResult = ProcessWSCallAsync();       |      |
    do_other_piece_of_work(); <----------------+      |
    var actualResult = wsResult.Result; // Waits and return control to callee
                                        // Does not yield to caller since method is not async
  }
{% endhighlight %}
{% highlight c# %}
  // In both cases it is not easy to wait or get some result out of piece_of_work

  public static void WorkerExample() {
    var worker = new BackgroundWorker();
    worker.DoWork = (worker, arg) => {};
    worker.RunWorkerAsync(null); // does NOT return a Task
  }

  public static void ThreadPoolExample() {
    WaitCallback piece_of_work = (arg) => {};
    ThreadPool.QueueUserWorkItem(piece_of_work, null);
  }
{% endhighlight %}

## What I do NOT like
No surprise here, most of the things I dislike were just taken from C++

* Methods are not virtual by default, you have to use a combination of virtual/override/new. **The behavoir can vary inside the class hierarchy !!**
{% highlight c# %}
namespace assembly_name {
  public class Chocolat {
    public virtual doit() { Console.WriteLine("Chocolat"); }
  }

  public class White : Chocolat {
    public override doit() { Console.WriteLine("White"); }
  }

  public class Black : Chocolat {
    public new doit() { Console.WriteLine("Black"); }
  }

  public static void Main() {
    var chocolat = new Chocolat();    // chocolat.doit() = "Chocolat"
    var white = new White();          // white.doit() = "White"
    var black = new Black();          // black.doit() = "Black"
    Chocolat bad_black = new Black(); // bad_back.doit() = "Chocolat"
  }
}
{% endhighlight %}
* `ref` and `out` lets **evil C++ programmers** use side effects
{% highlight c# %}
  public static void side_effect(ref string st, out int i) 
  {
    i = 666;
    st = "bananas";
  }

  public static void Main()
  {
    int i = 0;
    string st = null;
    // At least you are forced to declare a side effect at the call site
    side_effect(ref st, out i);
    Console.WriteLine("st={0}, i={1}", st, i);
  }
{% endhighlight %}
* C++ like syntax for namespaces, no need to have multiple namespaces in same file, it just add extra {} cluter
* C++ `public Klass() : base(...) {}`  syntax for class attribute initialisation
* `in` and `out` template parameter modifers and its weird rules to avoid [subtyping problems][0]
* `partial` classes : classes can be defined in several source files, each one containing some methods, attributes ...
* `struct` types are full of quirks : stack allocated (even using new), can implement interfaces but cannot inherit from

## Stuff that is just different

* `delegate` method signature types
{% highlight c# %}
  delegate void do_it();
  delegate T    give_it<T>();
  delegate void take_it<T>(T arg);

  public static string func() { return "monkey"; } 
    
  do_it del1 = () => { Console.WriteLine("do it !"); };
  give_it<string> del2 = func;
  take_it<string> del3 = (s) => { Console.WriteLine(s); };

  del1();
  del3( del2() );
{% endhighlight %}
* `event` to easily attach actions when something happens
{% highlight c# %}
  public class Klass {
    public delegate void GoForIt(Klass o);
    public event GoForIt events;
    
    public void trigger() { 
      // You can only trigger an event from within the class
      // The events will be executed in the current thread
      events(this);
    }
  }

  public static void Main() {
    var k = new Klass();
    // You can add several listeners to a given event
    k.events += obj => { Console.WriteLine("A lot of"); };
    k.events += obj => { Console.WriteLine("bananas !"); };
    k.trigger();
  } 
{% endhighlight %}
* There is no type erasure for generic types
{% highlight c# %}
  public class Klass<T> {
    public void doit() {
      // T.class, Klass<T>.class are not valid in Java
      Console.WriteLine("T = {0}, Klass<T> = {1}", typeof(T));
      Console.WriteLine("Klass<T> = {0}", typeof(Klass<T>));
      Console.WriteLine("def(T) = {0}", default(T));
    }
  }

  public static void Main() {
    var k1 = new Klass<int>();
    var k2 = new Klass<string>();
    k1.doit();
    k2.doit();
  }
{% endhighlight %}
* More constraints are available for generic template parameters
{% highlight c# %}
public class DftConstructible<T> where T:new() {
  public void doit() {
    Console.WriteLine("T t = {0}", new T());
  }
}

public static void Main() {
  var k1 = new DftConstructible<List<int>>();
  k1.doit();
}
{% endhighlight %}

[0]: http://docs.oracle.com/javase/tutorial/extra/generics/subtype.html

