---
title: C#, learning the language
date: 2015-11-21
categories: [cs_related]
---

Coming from an Unix background I was reluctant to learn C#. I was forced into it by a work assignement.
However after some days I started to appreciate the design of some APIs and the fancy language features.

## Nice things

Some nice syntactic sugar introduced way before it got to other mainstream languages like C++ or Java.

* Type deduction using `var`
* RAII with `using(resource) {}` blocks
* Attribute getter/setter are easy to implement
```c#
  public class Chocolat {
      // Everyone can read but write protected
      public string Attr { get; private set; }
      // INVALID
      private string Attr { public get; set; }
  }
```

* Fluent API with LINQ (but I am not so fond of the SQL-like syntax)
```c#
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
```

* Extension methods to make static helpers less verbose (no access to private fields)
```c#
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
```

* Out of the box XML serialization, pretty convinient to avoid writing ToString() for debugging
```c#
  public class BananaSplit {
      public string IceCream { get; set; }
      public string Sauce    { get; set; }
      public int    Price    { get; set; }
  }
            
  public static void PrintXmlString() {
      var dessert = new BananaSplit { IceCream = "Vanilla", Sauce = "Chocolate", Price = 25 };
      var serializer = new XmlSerializer(typeof(BananaSplit));
      var output = new StringWriter();
      serializer.Serialize(output, dessert);
      Console.WriteLine(output);
  }
```

* Runtime duck typing with `dynamic`
```c#
  public class Duck1 {
      public void quack () { Console.WriteLine(this.GetType()); }
  }

  public class Duck2 {
      public void quack () { Console.WriteLine(this.GetType()); }
  }

  public class Goose {
      public void cackle () { Console.WriteLine(this.GetType()); }
  }
            
  public static class Program
  {
      // You cannot define a compile time template parameter constraint like 'T is newable and has a quack() method'
      public static void riseAndQuack<T> () where T:new()  {
          // dynamic defers the binding of quack() to runtime using reflection
          dynamic duck = new T();
          duck.quack();
      }
      
      public static void Main() {   
          riseAndQuack<Duck1>();
          riseAndQuack<Duck2>();
          // RuntimeBinderException: 'Goose' does not contain a definition for 'quack'
          // riseAndQuack<Goose>();
      }
  }
```

* Yield methods to create iterators (python got it in 2002 and C# in 2006)

```c#
public class Banana {}

public static IEnumerable<Banana> hoard () {
  // Infinite banana stock !
  while (true)
    yield return new Banana();
}

public static void Main() {
  foreach(var b in hoard())
    Console.WriteLine("Got banana !");
}
```

### More recent features follow the global trend

* Async and await (easier to use than previous BackgroundWorker and ThreadPool)
```c#
  public static async Task<string> ProcessWSCallAsync() {
      Task<string> response = ... // WCF client to call webservice
      do_some_work();
      string result = await response; // yield control at this point to caller
      return result.Trim(); <--------------------|------+
  }                                              |      |
                                                 |      |
  public static void Main() {                    |      |
      var wsResult = ProcessWSCallAsync();       |      |
      do_other_piece_of_work(); <----------------+      |
      var actualResult = wsResult.Result; // Waits and return control to callee
                                          // Does not yield to caller since method is not async
  }
```
```c#
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
```

* Sweet type inference : using Linq and anonymous types, the compiler can check it all
```c#
  // the compiler generates the type on the fly
  var candy1 = new { Name = "chocolat" };
  var candy2 = new { Name = "icecream" };
  var candies = new[] { candy1, candy2 };
  var dessert = candies.Aggregate("", (a,i) => a + " " + i.Name);
```

* A simple way to add metadata to types using Attributes
```c#
  [AttributeUsage(AttributeTargets.Class, Inherited=false)]
  public class YummyAttribute : Attribute {
      public string Taste { get; set; }
  } 

  [YummyAttribute(Taste = "Delicious")]
  public class BananaSplit {}
            
  public static void PrintTaste() {
      var attr = (YummyAttribute)typeof(BananaSplit)
                                 .GetCustomAttribute(typeof(YummyAttribute));
      Console.WriteLine(attr.Taste);
  }
```

## What I do NOT like
No surprise here, most of the things I dislike were just taken from C++

* Methods are not virtual by default, you have to use a combination of virtual/override/new. **The behavoir can vary inside the class hierarchy !!**
```c#
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
```

* `ref` and `out` lets **evil C++ programmers** use side effects
```c#
  public static void side_effect(ref string st, out int i) {
      i = 666;
      st = "bananas";
  }

  public static void Main() {
      int i = 0;
      string st = null;
      // At least you are forced to declare a side effect at the call site
      side_effect(ref st, out i);
      Console.WriteLine("st={0}, i={1}", st, i);
  }
```

* C++ like syntax for namespaces, no need to have multiple namespaces in same file, it just add extra {} cluter
* C++ `public Klass() : base(...) {}`  syntax for class attribute initialisation
* `in` and `out` template parameter modifers and its weird rules to avoid [subtyping problems][0]
* `partial` classes : classes can be defined in several source files, each one containing some methods, attributes ...
* `struct` types are full of quirks : stack allocated (even using new), can implement interfaces but cannot inherit from

## Stuff that is just different

* `delegate` method signature types
```c#
  delegate void do_it();
  delegate T    give_it<T>();
  delegate void take_it<T>(T arg);

  public static string func() { return "monkey"; } 
    
  do_it del1 = () => { Console.WriteLine("do it !"); };
  give_it<string> del2 = func;
  take_it<string> del3 = (s) => { Console.WriteLine(s); };

  del1();
  del3( del2() );
```

* `event` to easily attach actions when something happens
```c#
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
```

* There is no type erasure for generic types
```c#
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
```

* More constraints are available for generic template parameters
```c#
  public class DftConstructible<T> where T:new() {
      public void doit() {
          Console.WriteLine("T t = {0}", new T());
      }
  }

  public static void Main() {
      var k1 = new DftConstructible<List<int>>();
      k1.doit();
  }
```

* Awkward (but safe) rules for user defined structs. You are guaranteed that all members will be initialized and that the value will always reside on the stack.
```c#
  public struct Point {
      public int x ,y;

      // Value types can have non-default user defined constructors
      public Point(int _x, _y) { x = _x; y = _y; }

      // Compilation failure : compiler needs to instantiate all members
      public Point(int arg) { x = arg; }

      // Compilation failure : value types cannot have user defined default constructors
      public Point()  { ... }
  }
  public static Main() {
      // Constructs object but its members are uninitialized
      Point p1;
      // calls default constructor that initializes all members to default value (x=0, y=0)
      // IMPORTANT : even using new, the object is still created on the stack (a value object is always copied)
      var p2 = new Point();
      // Compilation failure : can only call a user defined constructor using new (no funny C++ syntax)
      Point p3(333, 666); // use var p3 = new Point(333, 666);

      //Compilation failure : cannot use p1 until all of its members have been initialized
      Console.WriteLine("p1 coords = {0}, {1}", p1.x, p1.x);

      p1.x = 1; p1.y = 2;
      // Now it is valid to access the object
      Console.WriteLine("p1 coords = {0}, {1}", p1.x, p1.x);
  }
```

[0]: http://docs.oracle.com/javase/tutorial/extra/generics/subtype.html

