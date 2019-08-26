---
title: Golang or "The Emperor's New Clothes"
date: 2018-08-25
categories: [cs_related, golang]
---

I was coming with high hopes to the go language, however I have been mostly disappointed.
Everyone around me looks happy with it and are adamant to critics.
Golang may have its usages, but I think it is a poor tool for an average application developer like myself.
Maybe some day I will see the light, but for now I will consider the emperor is naked.

## The good

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

* Automatic pretty print of complex structs, in different convinient flavors

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

* Automatic analysis to determine storage class of variables. I am all for letting the garbae collector do the heavy lifting, but it is hard not to panic when seeing what looks like dangling pointers.
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

* Embedding is a simple way to compose `struct`s and `interface`s. It does NOT give you polymorphism, which is good a good thing (no slicing, virtual keyword)
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

* You cannot overload in golang (so glad there is no overload resolution)
  * Embedding respects the "no overloading" rule and allows shadowing (or "overriding")

```go
type Nested struct {}
func (*Nested) shadow_method() int { return 999; }

type Record struct {}
func (*Record) shadow_method(int) int { return 111; }

func main() {
  r := Record{}
  // This will NOT work since Record.shadow_method hid Nested.shadow_method even if they have a different signature
  //fmt.Printf("r.shadow(0)=%v, r.shadow()=%v\n", r.shadow_method(0), r.shadow_method())
}
```

* `interface{}` keeps type information
  * virtual dispatch

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


## The bad

* golang has pointer notation, yet some well known types use value notation but have pointer semantics.

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

* no prototypes, no headers : how can I quickly get a glimpse at what methods are defined for the type ?
  * this is one of the advantage of interfaces and explicit implementation

### Where are the batteries ?

* No [map,filter... functions][8] (man I miss C#'s LINQ)
  * Having no generics can really be a double edged weapon
* Unit test framework missing some main features (setUp/tearDown, parametric). It has a DIY approach, so you end up writing more boiler plate code.
* No macros ? I feel macros are like nuclear power, people are strongly against it because they do not get it.


## The ugly

* [`else` cannot be in its own line][0] ? seriously ?
  * If this is the price for not having semicolons, I rather wear my pinky finger until exhaustion.
* no exceptions and no syntax sugar for avoiding tedious `if err != nil`
  * even using [errors as values][2], in practice this not cover many of the usual cases for error checking.

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

### implicit interface implementation

* this looks like a fake good idea to counter the [expression problem][5]
  * not sure what to make of duplication of interface declaration on each consumer
  * all of this and we do not get [extension methods][6]
* asserting type implements interface looks like a [horror tale][3] out of a [pre-c++11 book][4]

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


### Conclusion : maybe it is time to try rust ?


[0]: https://github.com/golang/go/issues/5440
[1]: https://blog.acolyer.org/2019/05/17/understanding-real-world-concurrency-bugs-in-go/
[2]: https://blog.golang.org/errors-are-values
[3]: https://eli.thegreenplace.net/2019/does-a-concrete-type-implement-an-interface-in-go/
[4]: https://erdani.com/index.php/books/modern-c-design/
[5]: https://eli.thegreenplace.net/2016/the-expression-problem-and-its-solutions/
[6]: https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/extension-methods
[7]: https://dave.cheney.net/2018/07/12/slices-from-the-ground-up
[8]: https://github.com/robpike/filter
[9]: https://golang.org/pkg/testing/
[10]: https://blog.golang.org/defer-panic-and-recover
[11]: https://dave.cheney.net/2014/08/17/go-has-both-make-and-new-functions-what-gives
[12]: https://medium.com/justforfunc/why-are-there-nil-channels-in-go-9877cc0b2308

