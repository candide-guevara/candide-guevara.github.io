---
title: Golang, Or "The Emperor's New Clothes"
date: 2019-08-25
my_extra_options: [ graphviz ]
categories: [cs_related]
---

I was coming with high hopes to the go language. It is not a bad language, but for application development there are far better options.
Unless it is super efficient, I cannot understand why Google uses that purpose, you can be much more productive with C#.
Maybe some day I will see the light, but for now I will consider the emperor is naked, given all the (non justified?) hype around the language.

## The good

* Automatic pretty print of complex structs, in different convenient flavors

```go
type Record struct {
  afield int
  anotherone string
}

func main() {
  r := Record{ 666, "999" }
  fmt.Printf("%v\n", r)   // Output: {666 999}
  fmt.Printf("%T\n", r)   // Output: pkg.Record
  fmt.Printf("%+v\n", r)  // Output: {afield:666 anotherone:999}
  fmt.Printf("%#v\n", r)  // Output: pkg.Record{afield:666, anotherone:"999"}
}
```

* Automatic analysis to determine storage class of variables. I am all for letting the garbage collector do the heavy lifting, but it is hard not to panic when seeing what looks like dangling pointers.
  * A friendlier notation for old-timers would have been nice.

```go
func new_p_int() (*int) {
  var a int = 666
  return &a // do not panic, the compiler's got your back
}

func main() {
  a := new_p_int()
  fmt.Printf("a=%p, *a=%v\n", a, *a)
}
```

* You cannot overload in golang (so glad there is no overload resolution)
  * Embedding respects the "no overloading" rule and allows shadowing (or "overriding")

```go
type Nested struct {}
func (*Nested) shadow_method() int { return 999; }

type Record struct { Nested }
func (*Record) shadow_method(int) int { return 111; }

func main() {
  r := Record{}
  // This will NOT work since Record.shadow_method hid Nested.shadow_method even if they have a different signature
  //fmt.Printf("r.shadow(0)=%v, r.shadow()=%v\n", r.shadow_method(0), r.shadow_method())
}
```

### Composition and polymorphism are separate concepts

In C++ you can achieve both composition and polymorphism with inheritance.

* `struct` is NEVER polymorphic, which is good a good thing (no slicing, virtual keyword)
  * on the contrary `interface` are polymorphic

```go
type If1 interface {
  method1() int
}
type If2 interface {
  method1() int
  method2() int
}

type Klass struct { /* defines method1, method2 */ }

func main() {
   var i2 If2 = &Klass{}
   var i1 If1 = i2 // works !
   // Even if Klass implements ALL interfaces, what counts is `i1` interface type.
   //var i3 If2 = i1
}
```

* Embedding is a simple way to compose `struct`s and `interface`s
  * It has some pitfalls (cf "the bad section")

```go
type INested interface {
  inner_method() int
}

type IRecord interface {
  INested
  a_method()
}

type Nested struct {
  innerfield int
}
func (*Nested) inner_method() int { return 999; }

type Record struct {
  Nested
  afield int
}
func (*Record) a_method() {}

func main() {
  r := Record{Nested{666}, 333}
  // Record "inherited" the methods from Nested so it does implement IRecord
  var ir IRecord = &r
  // No polymorphism : Record is NOT a Nested struct
  //var n Nested = r
  fmt.Printf("r.inner=%v, ir.inner()=%v\n", r.innerfield, ir.inner_method())
  // Output: r.inner=666, ir.inner()=999
}
```

* `interface{}` acts like a type safe `void*`. It keeps type information so we can do type assertions when casting.
  * It has some pitfalls (cf "the bad section")

```go
type Klass1 struct {}
func (*Klass1) doit(int) int { return 111; }
 
type Klass2 struct {}
func (*Klass2) doit(int) int { return 222; }
 
func main() {
  r1 := Klass1{}
  r2 := Klass2{}
  var i1 interface{} = r1
  var i2 interface{} = r2
  
  r1 = i1.(Klass1)
  // there are no unsafe casts
  //r2 = i1.(Klass2)
  // to avoid panic use a type assertion
  r2, ok := i1.(Klass2)

  fmt.Printf("i1=%#v, i2=%#v, ok=%v\n", i1, i2, ok)
  // Output:
  // i1=main.Klass1{}, i2=main.Klass2{}, ok=false
}
```

### A strong enforcement of convention over configuration

Paternalistic but it ensures uniformity across different projects.

* Exported types start with **upper case** letters
* Package private types start with **lower case** letters
* Convention for [directory structure][15], all packages must be rooted in `GOPATH` environment variable.
  * executable packages **must** be named `main`

```make
# Example project structure
# /home/candide/go_workspace/
#     src/thismodule/
#         code.go
#         code_test.go
#     src/thatmodule
#         code.go
#         code_test.go
#         main/
#             thatmodule.go <-- package name must be "main"
#     pkg/<platform_arch>
#         thismodule.a
#         thatmodule.a
#     bin/
#         thatmodule        <-- exe are dropped at the root

export GOPATH:=/home/candide/go_workspace
MODULES:=thismodule thatmodule thatmodule/main

# Be careful it is a trap ! `go build` compiles but does NOT create any artifact
build:
	go install $(MODULES)
test:
	go test $(MODULES)
```

* Conventions for unittesting, examples and benchmarks with [`go test`][9]

```go
/* somemodule.go */
func Doit(a int) { ... }

/* somemodule_test.go */
func TestDoit(t *testing.T) { ... }
func ExampleDoit(t *testing.T) { 
  ...
  // Output: <expected stdout>
}
func BenchmarkDoit(b *testing.B) {
  for i := 0; i < b.N; i++ { ... }
}
```



## The neutral

* Channels are an interesting feature but they are not a [magic solution][1]. Concurrency will still bite you.
  * They are [surprisingly difficult][12] to use for some trivial cases like merging streams.

```go
func producer(ctx context.Context) chan int {
  c := make(chan int)
  go func() {
    // do something fancy that takes time ...
    select {
    case c <- 666:
    // without this case the producer could deadlock if no one reads from the channel
    case <- ctx.Done():
    }
  }()
  return c
}

func main() {
  d := time.Now().Add(50 * time.Millisecond)
  ctx, _ := context.WithDeadline(context.Background(), d)
  c := producer(ctx)

  select {
  case i := <- c:
  fmt.Println("prod returned", i)
  case <- ctx.Done():
  fmt.Println("prod ignored", ctx.Err())
  }
}
```

* `interface{}` can act both as a value or reference type (depending on inner concrete type). Thankfully it follows sane semantics.
  * However when assigning between `interface{}` variables you cannot tell if doing a value copy or not

```go
type Klass struct { a int }
func (*Klass) doit() int { return 222; }

func main() {
  kp := Klass{666}
  var i1 interface{} = kp   // copy of kp
  var i2 interface{} = &kp  // reference to kp
  k1 := i1.(Klass)          // copy of i1
  k2 := i2.(*Klass)         // reference to i2,kp
  kp.a = 111
  k1.a = 222
  k2.a = 333

  // from the type of `i2` you cannot tell if this is a value copy or not
  i3 := i2
  fmt.Printf("i1=%v, i2=%v, k1=%v, k2=%v, kp=%v\n", i1, i2, k1, k2, kp)
  // Output:
  // i1={666}, i2=&{333}, k1={222}, k2=&{333}, kp={333}
}
```

### goroutines vs async/await

I clearly do not have enough experience using goroutines but it bothers me that simple things are not as easy as using `async/await`

* Waiting for multiple coroutines to finish, requires modifying the coroutines themselves. You lose the **central point of control**.

```go
// Note sync.WaitGroup is useless for the goroutines, it is needed solely by their caller
func thisTakesForever (grp *sync.WaitGroup) { grp.Done() }
func betterGoGrabACoffee (grp *sync.WaitGroup) { grp.Done() }

func main() {
  grp := new(sync.WaitGroup)
  grp.Add(2)
  go thisTakesForever(grp)
  go betterGoGrabACoffee(grp)
  grp.Wait()
}
```

```c#
// Note sync void function => async Task function
private async Task thisTakesForever() { ... }
private async Task betterGoGrabACoffee() { ... }

public void SomeLogic() {
  var t1 = thisTakesForever();
  var t2 = betterGoGrabACoffee();
  Task.WaitAll(t1, t2);
}
```

* Merging streams returning elements as **soon as they are ready**.
  * The [C# implementation][18] is maybe more involved, but you can use generic to code it only once.
  * Here are 3 different techniques to implement this in golang : simple select, wrapping channel with goroutines, reflection

```go
func producerGenerator(d int, data []int) (chan int) {
  ch := make(chan int)
  go func() {
    for _,i := range(data) {
      time.Sleep(time.Duration(d) * time.Millisecond)
      ch <- i
    }
    close(ch)
  }();
  return ch
}

func linearConsumer(chs ...chan int) int {
  sum := 0
  for _,ch := range chs {
    for i := range ch { sum += i }
  }
  return sum
}

func consumerOnlyTwo(ch1, ch2 chan int) int {
  d,sum := 0,0
  open1,open2 := true,true

  for open1 || open2 {
    select {
      case d,open1 = <-ch1:
        if(open1) { sum += d }
        // Note that nil channels always block when attempting to read
        if(!open1) { ch1 = nil }
      case d,open2 = <-ch2:
        if(open2) { sum += d }
        if(!open2) { ch2 = nil }
    }
  }
  return sum
}

func consumerGoRoutines(chs ...chan int) int {
  sum := 0
  grp := new(sync.WaitGroup)
  grp.Add(len(chs))

  merger := func(ich chan int) {
    for d := range ich { sum += d }
    grp.Done()
  }

  for _,ch := range chs { go merger(ch) }
  grp.Wait()
  return sum
}

func consumerReflection(chs ...chan int) int {
  sum := 0
  cases := make([]reflect.SelectCase, len(chs))
  dones := make([]bool, len(chs))

  for i,ch := range chs {
    cases[i].Dir = reflect.SelectRecv
    cases[i].Chan = reflect.ValueOf(ch)
  }
  for !All(dones) { // All is NOT in the stdlib (MacGyver)
    idx, d, open := reflect.Select(cases)
    dones[idx] = !open
    if open { sum += int(d.Int()) }
    // If we do not nullify the channel, its corresponding case will fire non-stop
    if !open { cases[idx].Chan = reflect.ValueOf(nil) }
  }
  return sum
}

func main() {
  ch1 := producerGenerator(70, []int{1,2,3})
  ch2 := producerGenerator(50, []int{4,5,6})
  consumerOnlyTwo(ch1, ch2)
}
```


* Stack traces do NOT automagically go beyond the goroutine boundary.

```go
func someLogic() {
  ch := make(chan int)
  go goroutine(ch)
  <- ch
}

func goroutine(ch chan int) {
  panic("oops")
  ch <- 666
}

func main() {
  someLogic()
  // Output:
  // panic: oops
  // 
  // goroutine 4 [running]:
  // main.goroutine(0xc000018180)
  //         /usr/lib/go/src/my_module.go:49 +0x39
  // created by main.someLogic
  //         /usr/lib/go/src/my_module.go:44 +0x58
}
```

```c#
public static void SomeLogic() {
  var t = somethingDangerous();
  Task.WaitAll(t);
}

private static async Task somethingDangerous() {
  Task.Delay(66);
  throw new Exception("oops");
}

public static void Main() {
  SomeLogic();
  // Output:
  // [System.Exception: oops]
  //    at Program.<somethingDangerous>d__0.MoveNext() :line 15
  // 
  // [System.AggregateException: One or more errors occurred.]
  //    ...
  //    at Program.SomeLogic() :line 10
  //    at Program.Main() :line 25
}
```

### Dependency inversion by implicit interface implementation

The common approach for dependency inversion is for the producer to provide a separate package (depending **only** on other interfaces) with the interface to its concrete implementation.

On the contrary, golang encourages private interfaces. Service consumers are free to define the piece of the service they need, and depend only on that part.

```myviz
digraph {
  node [shape="box"]
  newrank=true;

  subgraph cluster_normal {
    label="Java/C#"
    style="dashed"
    client1 [label="service consumer2"]
    client2 [label="service consumer1"]
    backend [label="service implementation"]
    interface [label="interface"]
    client1 -> interface [label="depends_on"]
    client2 -> interface [label="depends_on"]
    backend -> interface [label="implements", contraint=false]
    { rank=sink; backend; }
  }
  subgraph cluster_golang {
    label="Golang"
    style="dashed"
    subgraph cluster_client3 {
      label="service consumer2"
      style="solid"
      interface3 [label="interface2"]
      interface5 [label="interface3"]
    }
    subgraph cluster_client4 {
      label="service consumer1"
      style="solid"
      interface4 [label="interface1"]
    }
    backend2 [label="service implementation"]
    backend2 -> interface3 [label="implements", contraint=false]
    backend2 -> interface4 [label="implements", contraint=false]
    backend2 -> interface5 [label="implements", contraint=false]
    { rank=min; interface3; interface4; interface5; }
    { rank=sink; backend2; }
  }
  { rank=same; client1; interface3; }
  { rank=same; backend; backend2; }
}
```

This is a very new idea for me. I like it because :

* It allows clients to factor out unrelated services that happen to have some functionality in common.
* It allows you to use dependency injection **even** if the service implementation you depend on only provided a concrete class.

```go
type Socket struct { /* socket methods ...*/ }
type BlockDevice struct { /* block device methods ...*/ }

// on a separate source repo
type IFileLike interface {
  Open(string) int
  Read([]byte, int) int
}

func client_logic(if IFileLike) { /* do stuff */ }

func main() {
  client_logic(&Socket{});
}
```

```c#
public class Socket { /* socket methods ...*/ }
public class BlockDevice { /* block device methods ...*/ }

// on a separate source repo
public interface IFileLike {
  public int open(string path);
  public int read(byte[] buf, int len);
}

private void client_logic(IFileLike if) { /* do stuff */ }

public static void Main() {
  // You are screwed since the authors of Socket and BlockDevice did not implement any common interface from the beginning.
  // client_logic(new Socket());
}
```

But in real life, I am afraid this will happen :

* Let's be honest, this is an open invitation for people to copy-paste interface code around. Those copies will derive over time.
  The end result may well be that the isolation allowed by implicit implementation may hinder interoperability.

```go
/*** in module1.go ***/
type PersitentStore struct {}
func (*PersitentStore) ReadValue(key string) []byte { ... }
func (*PersitentStore) ListKeys(pat string) []string { ... }
func (*PersitentStore) MultiReadValue(keys []string) [][]byte { ... }

/*** in module2.go ***/
type IFancyReader interface {
  ListKeys(pat string) []string
  MultiReadValue(keys []string) [][]byte
}
func ReadAllKeysMatching(r IFancyReader, pat string) { ... }

/*** in module3.go ***/
type ISimpleReader interface {
  Read(key string) []byte
}

// works pretty well with ISimpleReader since it does not use the persistent store advanced capabilities.
func DoSomethingPrettySimple(r ISimpleReader) { ... }

func DoSomethingSpectacular(r ISimpleReader) {
  // At this point you realize ISimpleReader will not cut it. You need to duplicate IFancyReader in this module too.
  // __ FACE PALM __
  //keys := ReadAllKeysMatching(r, ".*")
}
```

* Explicit implementation has a readability advantage.
  * In C# if I come across a class implementing [IEnumerable][5], I know exactly how to use it.
  * Most of the design work and documentation was already done by the interface author.
  * On the other hand, in golang I need to look at the source to understand how to use the class.
  * Having interfaces close to the calling code, prevents building a **common language** throughout the whole source.
* Asserting a struct implements an interface looks like a [horror tale][3] out of a [pre-c++11 book][4]
* At least we could have gotten [extension methods][6], but all of the struct methods must be declared in its package.

These short comings, in my opinion, make this mechanism unsuitable for large corporate code bases where employees are rewarded for fast delivery, not quality.



## The bad

* golang has pointer notation, yet some well known types use value notation but have pointer semantics.
  * `error` is in fact an interface. How can I guess that if it starts with a lower case ?

```go
func mutator(m map[int]int, sl []int, ch chan int, err error) {
  m[666] = 666
  err = fmt.Errorf("mutated")
  sl[0] = 666
  ch <- 666
}

func main() {
  var m map[int]int = nil
  var sl []int = nil
  var ch chan int = nil
  var err error = nil

  m = make(map[int]int)
  sl = []int{333,444}
  ch = make(chan int, 2)
  // error type is a snowflake, it can be assigned nil but has value semantics
  err = fmt.Errorf("not_mutated")

  mutator(m,sl,ch,err)
}
```

* [`slice` ambiguity][7] : arrays and slices have very similar notation but one has value semantics the other no.

```go
func mutator(b1 []int) {
  b1[3] = 222
}

func main() {
  a1 := [5]int{0,0,0,0,0}
  a2 :=  []int{0,0,0,0,0}
  a3 := a1    // value copy !
  a4 := a2    // reference copy !
  a3[0] = 666
  a4[1] = 333

  var a5 []int
  // This hopefully does not compile, you cannot convert arrays to slices silently.
  //mutator(a1)
  //a5 = a1
  a5 = a1[:]
  a5[2] = 111
  fmt.Printf("a1=%v, a2=%v, a3=%v, a4=%v, a5=%v\n", a1, a2, a3, a4, a5)
}
```

* declaring methods taking self as a value (not a pointer) completely changes the behavior of methods with side effects. Notation should be more visible.
  * Is this a poor replacement for a `const` keyword ?

```go
type Record struct {
  afield int
}

func (r Record) mutate_fiasco() {
  r.afield = 666
}

func (r *Record) mutate_ok() {
  r.afield = 666
}

func main() {
  r := Record{}
  r.mutate_fiasco()
  fmt.Printf("r=%v\n", r) // Output: r={0}
}
```

* type inference at declaration is good, but why `:=` ? Notation should be more visible.
  * for once C++ has the right mix of brevity and unambiguity with the `auto` keyword 

```go
something := producer() // ok
something  = producer() // complains `something` has not been declared
```

* `new` and `make` are [constructor functions][11] taking an argument type. `make` is only valid on slices, maps, channels. `new` works everywhere but returns a pointer to "initialized" memory. 
  * Here again, the "fake" value type (slice,map,channel) make the behavior of those functions surprising (although consistent in some twisted contrived way)

```go
// The rule is new(T) is equivalent to the statements
var t T
p_t := &t 
// The problem is that each type nil value behaves differently.

func main() {
  a := new(int)
  b := new(map[int]int)
  c := make(map[int]int)
  d := new(chan int)
  e := new([]int)
  f := make([]int, 3)

  // b contains a "nil map" which will paninc if used
  //(*b)[0] = 0
  c[0] = 0

  // Writing and reading to a nil channel does NOT panic but blocks forever ...
  go func() { (*d) <- 666 }()
  //<- (*d)

  f[0] = 666
  // the nil slice has a zero length so it is kind of useless
  //e[0] = 666

  fmt.Printf("*a=%v, *b=%v, c=%v\n", *a, *b, c)
  // Output: 0, map[], map[0:0]
}
```

* Embedding of pointer types, breaks encapsulation and initialization

```go
type Nested struct {
  innerfield int
}

type Record struct {
  *Nested
  afield int
}

func main() {
  r := Record{}
  // This will panic since the embedded pointer is nil
  //fmt.Printf("r.inner=%v\n", r.innerfield)
}
```

* [Method sets and receivers][14] make working with interfaces fiddly : methods defined with receiver `T*` cannot be called from type `T` => `T` may NOT implement the same interfaces as `T*`
  * Now combine this with [type embedding][13] (does the embedded define its methods on value or pointer ?), you seem to be always better of with pointer receivers and storing pointers into interface types.

```go
type If interface {
  doit() int
}

type KlassPointer struct {}
func (*KlassPointer) doit() int { return 111; }

type KlassValue struct {}
func (KlassValue) doit() int { return 222; }

func main() {
  var ip1 If = &KlassPointer{}
  var iv1 If = KlassValue{}

  // KlassPointer* implements If NOT KlassPointer
  //var ip2 If = KlassPointer{}

  var iv2 If = &KlassValue{}
  // Be careful it is a trap : panic at runtime, the compiler will accept a cast *KlassValue -> KlassValue
  //kv := iv2.(KlassValue)

  // This is OK both KlassPointer* AND KlassPointer implement the empty interface
  var ii interface{} = KlassPointer{}
  // However, cannot call **pointer method on temp object**
  //ii.(KlassPointer).doit() // cannot call pointer method on temp object
}
```

### Dude, where are my batteries ?

* No [map,filter... functions][8] 
  * Having no generics can really be a double edged weapon
  * Plain old for loops are no match for a powerful API like LINQ

```c#
int[] numbers = {1,2,3,4,5,6,7,8};
var r = numbers.Where(i => i % 2 == 0)
               .Select(i => i*i)
               .Aggregate((agg, i) => agg + i);
```

* Unit test framework missing some of the features you know and love (setUp/tearDown, parametric). 
  * The [testing docs][9] advise a rather MacGyver-ish approach

```go
func setupClass() { ... }
func setup() { ... }

func unitTest1(t *testing.T) { ... }
func unitTest2(t *testing.T) { ... }

func parametricUnitTest(t *testing.T) {
  var data = []struct {
    name string
    param int
  } { ... }
  for _,d := range data {
    t.Run(d.name, func(t *testing.T) {
      // do something with `d.param`
    })
  }
}

func TestSuite(t *testing.T) {
  setup()
  t.Run("unitTest1", unitTest1)
  t.Run("unitTest2", unitTest2)
  t.Run("unitTest3", parametricUnitTest)
}

func TestMain(m *testing.M) {
  setupClass()
  os.Exit(m.Run())
}
```

* No macros ? I feel macros are like nuclear power, people are strongly against it because they only see the bad side (good luck trying to replace fossil fuels with wind power :-)
  * This is the first thing I write when coding small c programs, it makes c more concise than golang code in many cases.

```c
#define DIE_IF_NEGATIVE(result, func, ...) \
  result = func(__VA_ARGS__); \
  if (result < 0) { \
    perror(#func "@" STR(__LINE__)); \
    exit(1); \
  }

int main() {
  int fd;
  DIE_IF_NEGATIVE(fd, open, "/middle/of/nowhere", O_RDONLY);
  // continue doing awesome stuff ...
  return 0;
}
```

You could do something similar using `panic` if only golang had macros.



## The ugly

* [`else` cannot be in its own line][0], seriously ?
  * If this is the price for not having semicolons, I rather wear my pinky finger until exhaustion.
  * Not sure if related, but [google's golang style guide][16], tends to ban `else` clauses

```go
/* this will NOT compile */
if something_good {
} 
else { // <-- breaks !
}
```

* Naming return variables and allowing implicit return values

```go
func this_actually_compiles() (brain_fck int) {
  brain_fck = 666
  return
}

// You could argue that named return vars, reduce boiler plate when returning errors (or their abscence).
// I think error passing is so broken this will not do any more than confuse readers.

func implicit_return() (answer interface{}, err error) {
  stuff, err := do_something_risky()
  if err != nil {
    return // nil, err
  }
  return magic(stuff) //, nil
}
```

### Please repeat yourself : `if err := nil`

* No exceptions and no syntax sugar for avoiding tedious `if err != nil`
  * [errors as values][2] advocates a MacGyver-ish approach. All of the cases in the article do not require any code with exceptions.

* User defined errors are tedious. You can either use `errors` package. But the errors become constants (you cannot add a custom message).

```go
func trySomething() error {
  if err := operation1(); err != nil { return os.ErrPermission }
  if err := operation2(); err != nil { return os.ErrInvalid }
}

func someLogic() error {
  if err := trySomething(); err != nil {
    if errors.Is(err, os.ErrPermission) {
      // recover and continue
    }
    return err // nope, can't handle this one
  }
}

func main() {
  if err := someLogic(); err != nil {
    fmt.Printf("this is a definite fiasco: %v", err)
  }
}
```

* Or create them yourself and distinguish between them using type switches.

```go
type mybase struct { s string }
func (e mybase) Error() string { return e.s }

type mywarn struct { mybase }
type myfail struct { mybase }

func trySomething() error {
  if err := operation1(); err != nil { return &mywarn{"acceptable but not good"} }
  if err := operation2(); err != nil { return &myfail{"we are screwed"} }
}

func someLogic() error {
  err := trySomething()
  switch err.(type) {
    case nil:
    case mywarn: // recover and continue
    default: return err // nope, can't handle this one
  }
}

func main() {
  if err := someLogic(); err != nil {
    fmt.Printf("this is a definite fiasco: %v", err)
  }
}
```

* You will have to unleash you inner MacGyver (again) if you want stack traces.
  * Ironically after 30 years, Herb Sutter might have found the holy grail for C++ [zero overhead exceptions][19], which is just the technique below except that it is done by the compiler automagically.
    Once that is implemented in C++, golang will look pretty silly ...

```go
func top_stack() error {
  return fmt.Errorf("oops\n%s", debug.Stack())
}

func middle_stack() error {
  if err := top_stack(); err != nil {
    return err
  }
}

func main() {
  if err := middle_stack(); err != nil {
    fmt.Printf("this was a fiasco: %v", err)
  }
}
```

### [defer/recover][10] : terrible solution for RAII, error recovery

* half-baked solution for equivalent `C# using + exceptions` (more verbose and contrary to `using` defer statement order may cause bugs)

```go
func CopyFile(dstName, srcName string) error {
    src, err := os.Open(srcName)
    if err != nil {
        return err
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return err
    }
    defer dst.Close()

    io.Copy(dst, src)
}
```

```c#
public void CopyFile(string dstName, string srcName) {
    using (var src = File.Open(srcName))
    using (var dst = File.Create(dstName)) {
      src.CopyTo(dst);
    }
}
```

* recovering from panics does not look super reliable compared to a `catch` clause.

```go
func main() {
  defer func() {
    if r := recover(); r != nil {
      fmt.Println("Detected panic from dodgy_code.")
    } else {
      fmt.Println("Returned normally from dodgy_code.")
    }
  }()
  dodgy_code(nil)
}

func dodgy_code(arg interface{}) {
  fmt.Println("dodgy_code got arg", arg)
  panic(arg)
  // Output:
  // dodgy_code got arg <nil>
  // Returned normally from dodgy_code.
}
```

* does not follow the block semantics of C++ (I thought there was consensus that javascript hoisting was not a great idea)

```go
func main() {
  v := 1
  {
    v := "chocolat"
    fmt.Println("Hello, block", v)
    // defer is **hoisted** to the function block !!
    defer func() { fmt.Println("bye, block", v) }()
  }
  fmt.Println("Hello, playground", v)
  // Output:
  // Hello, block 1
  // Hello, playground 12
  // bye, block 1
}
```

* wtf, can modify the return value

```go
func a_trap(in int) (out int) {
  out += 333
  defer func() { out++ }()
  return in
}

func main() {
  fmt.Println("be careful", a_trap(666))
  // Output:
  // be careful 667
}
```

* error prone variable capture rules for deferred expressions

```go

func main() {
  v := "first"
  defer fmt.Println("unwrapped", v)
  defer func() { fmt.Println("wrapped", v) }()
  defer func(w string) { fmt.Println("explicit", w) }(v)
  v = "second"
  // Output:
  // explicit first
  // wrapped second
  // unwrapped first
}
```


## Features I need to try

* race detector functionality
* who more efficient compared to C# ?


### Conclusion : maybe it is time to try rust ?


[0]: https://github.com/golang/go/issues/5440
[1]: https://blog.acolyer.org/2019/05/17/understanding-real-world-concurrency-bugs-in-go/
[2]: https://blog.golang.org/errors-are-values
[3]: https://eli.thegreenplace.net/2019/does-a-concrete-type-implement-an-interface-in-go/
[4]: https://erdani.com/index.php/books/modern-c-design/
[5]: https://docs.microsoft.com/en-us/dotnet/api/system.collections.ienumerable?view=netframework-4.8
[6]: https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/extension-methods
[7]: https://dave.cheney.net/2018/07/12/slices-from-the-ground-up
[8]: https://github.com/robpike/filter
[9]: https://golang.org/pkg/testing/
[10]: https://blog.golang.org/defer-panic-and-recover
[11]: https://dave.cheney.net/2014/08/17/go-has-both-make-and-new-functions-what-gives
[12]: https://medium.com/justforfunc/why-are-there-nil-channels-in-go-9877cc0b2308
[13]: https://stackoverflow.com/questions/40823315/x-does-not-implement-y-method-has-a-pointer-receiver
[14]: https://golang.org/ref/spec#Method_sets
[15]: https://golang.org/doc/code.html
[16]: https://github.com/golang/go/wiki/CodeReviewComments#indent-error-flow
[17]: https://dave.cheney.net/2016/06/12/stack-traces-and-the-errors-package
[18]: {% post_url lang_programming/0000-00-00-c-sharp-adv-async %}/#asynchronous-streams
[19]: https://wg21.link/p0709r2

