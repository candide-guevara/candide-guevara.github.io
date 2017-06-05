---
layout: post
title: C++ Class topology
categories : [diagram, cpp]
css_custom: inline_images
---

The better way to describe the definition of different kinds of classes is to draw their subsets on the space of all possible c++ classes.
A good textual description can be found [here][0]

![cpp_class_topology]({{ site.images }}/Cpp_Class_Topology.svg)

## Characteristics of each set of classes

### Regular

Behaves as any numerical type : you can default construct, copy and compare it.
{% highlight c++ %}
  // The empty class with the == operator defined is a POD and regular type.
  struct RegularEmpty { 
      bool operator == (const RegularEmpty&) const {}
  };

  // If user provides all needed constructors and operator overrides, then there are not limitations on the members
  // of the class
  struct RegularFullCustom : public ABaseClass { 
      RegularFullCustom() {}
      RegularFullCustom(const RegularFullCustom&) {}
      RegularFullCustom(RegularFullCustom&&) {}

      RegularFullCustom& operator = (const RegularFullCustom&) {}
      RegularFullCustom& operator = (RegularFullCustom&&) {}
      bool operator == (const RegularFullCustom&) const {}

      virtual void someMethod() {}
  };
{% endhighlight %}

### Trivial

* Guarantees a contiguous memory layout
* The layout **can vary** between compilers
* There are no side effects on construction
{% highlight c++ %}
  struct Trivial { 
      Trivial() = default;
      // Trivial classes can contain user defined constructors that are not copy/move/default
      Trivial(const std::string&) {}
  };

  struct Trivial_2 { 
      Trivial() = default;
      // The definiion says that a trivial class does **not contain non-trivial** copy constructors
      // which means you can delete them
      Trivial_2(const Trivial_2&) = delete;
  };
{% endhighlight %}

### Standard layout

* Guarantees a contiguous memory layout
* The layout **is stable** between compilers
{% highlight c++ %}
  struct StdLayout_1 { 
      int m_i;
  };

  struct StdLayout_2 : StdLayout_1 {};

  // Only ONE class in the inheritance tree can have members
  struct NotStdLayout_1 : StdLayout_1 {
    float m_f;
  };
{% endhighlight %}

### Aggregates

Can be brace-list initialized.
{% highlight c++ %}
  struct NotAggregate { 
      NotAggregate() {}
  };

  struct Aggregate { 
      int m_i;
      // Aggregate CAN contain not aggregate classes
      NotAggregate m_notagg;
  };
{% endhighlight %}

### Literal

Literal types can be initialized inline in static constexpr members.
{% highlight c++ %}
  // Any aggregate and trivially copyable type is literal
  struct Literal_1 {
      NotAggregate m_field;
  };

  // You can have virtual functions, private members ... as long as you provide a constexpr constructor
  struct Literal_2 { 
      constexpr Literal_2() : m_i(0) {}
      private:
      int m_i;
      virtual void breaks_most_sets() {}
  };
{% endhighlight %}

## Intersections of several sets

### Plain old data = std layout & trivial

* Stable memory layout
* No construction/destruction side effects

These types can be used for serialization/deserialization across process and different languages.

### Example of intersections

{% highlight c++ %}
  struct DifAccessCtrl { 
      int m_i;
      private:
      float m_f;
  };

  // This is a rare example of an aggregate which is trivial but NOT standard layout
  struct AggAndTrivial {
      DifAccessCtrl m_fld;
  };

  // This class has all properties : Aggregate, Trvial, Std Layout, Regular, Literal
  struct OmniClass { 
      int m_i;
      // Basically any POD with a comparison operator is a regular type
      bool operator == (const OmniClass&) {}
  };

  struct AggAndStdLayout { 
      int m_i;
      ~AggAndStdLayout() {}
  };
{% endhighlight %}

[0]: https://stackoverflow.com/questions/4178175/what-are-aggregates-and-pods-and-how-why-are-they-special

