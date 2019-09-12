---
title: Graphviz some examples
date: 2019-09-10
my_extra_options: [ graphviz ]
categories: [cs_related]
---

A few examples of dot language to render fancy graphs.

* [Dot language reference][0]
* [viz.js fiddle][1]

## Layout

### Choosing layout engine

{:.my-split-h}
```dot
# The default layout is top to bottom. Lower rank is on top.
digraph {
  a -> {b c d}
  b -> {e f g}
}
```

{:.my-split-h}
```myviz
digraph {
  a -> {b c d}
  b -> {e f g}
}
```


{:.my-split-h}
```dot
# Change the flow of default layout from left to right.
digraph {
  rankdir=LR
  a -> {b c d}
  b -> {e f g}
}
```

{:.my-split-h}
```myviz
digraph {
  rankdir=LR
  a -> {b c d}
  b -> {e f g}
}
```


{:.my-split-h}
```dot
# Change engine to a force based layout.
digraph {
  layout=neato
  a -> {b c d}
  b -> {e f g}
}
```

{:.my-split-h}
```myviz
digraph {
  layout=neato
  a -> {b c d}
  b -> {e f g}
}
```


{:.my-split-h}
```dot
# A couple of option to expand/compress the resulting node layout.
digraph {
  layout=neato
  edge [len=0.8] # change edge length
  overlap=false  # prevents nodes from overlapping each other

  # These options MIGHT work on other implementations
  #overlap_scaling=0.5
  #overlap_shrink=true

  a -> {b c d}
  b -> {e f g}
}
```

{:.my-split-h}
```myviz
digraph {
  layout=neato
  edge [len=0.8]
  overlap=false
  a -> {b c d}
  b -> {e f g}
}
```


{:.my-split-h}
```dot
# A couple of option to expand/compress differently on x and y dimensions.
digraph {
  layout=neato
  overlap=false # you NEED THIS for `sep` to take effect
  sep="+30,-5"  # expands 30 pixels on the x direction, but shrink y by 5

  a -> {b c d}
  b -> {e f g}
}
```

{:.my-split-h}
```myviz
digraph {
  layout=neato
  overlap=false
  sep="+30,-5"
  a -> {b c d}
  b -> {e f g}
}
```

Attributes `overlap`, `sep`, `len` only work for neato engine.

### Playing with rank

{:.my-split-h}
```dot
# Each node is assigned a higher rank than the highest ranked node
# that point to it (also works for undirected edges).
digraph {
  a -> {b c}
  b -> d
  # resulting rank : a=0, b=1, c=1, d=2
}
```

{:.my-split-h}
```myviz
digraph {
  a -> {b c}
  b -> d
}
```

{:.my-split-h}
```dot
digraph {
  a -> {b c}
  b -> d
  {rank=min d}
}
```

{:.my-split-h}
```myviz
digraph {
  a -> {b c}
  b -> d
  {rank=min d}
}
```

{:.my-split-h}
```dot
digraph {
  a -> {b c}
  b -> d
  {rank=same b d}
  {rank=max a}
}
```

{:.my-split-h}
```myviz
digraph {
  a -> {b c}
  b -> d
  {rank=same b d}
  {rank=max a}
}
```

{:.my-split-h}
```dot
digraph {
  # these edges are not used for ranking.
  a -> {b c} [constraint=false]
  b -> d
}
```

{:.my-split-h}
```myviz
digraph {
  a -> {b c} [constraint=false]
  b -> d
}
```

### Playing with subclusters

{:.my-split-h}
```dot
digraph {
  # It is a trap ! subgraph MUST start with cluster.
  # clusterrank=none will deactivate drawing the cluster boundary.
  subgraph cluster_cl {
    a -> {b c}
    # By default rank is local to subgraph.
    # The following statement does not change anything.
    {rank=min a}
  }
  r -> a
  b -> d
}
```

{:.my-split-h}
```myviz
digraph {
  subgraph cluster_cl {
    a -> {b c}
    {rank=min a}
  }
  r -> a
  b -> d
}
```

{:.my-split-h}
```dot
digraph {
  newrank=true # rank constraints are global
  subgraph cluster_cl {
    a -> {b c}
    {rank=min a} # now rank_a < rank_r
  }
  r -> a
  b -> d
}
```

{:.my-split-h}
```myviz
digraph {
  newrank=true
  subgraph cluster_cl {
    a -> {b c}
    {rank=min a}
  }
  r -> a
  b -> d
}
```

{:.my-split-h}
```dot
digraph {
  subgraph cluster_cl {
    a -> {b c}
  }
  r -> a
  b -> d
  # By declaring the constraint OUTSIDE the subgraph
  # you somehow pull the node out of the cluster.
  {rank=min a}
}
```

{:.my-split-h}
```myviz
digraph {
  subgraph cluster_cl {
    a -> {b c}
  }
  r -> a
  b -> d
  {rank=min a}
}
```

{:.my-split-h}
```dot
digraph {
  newrank=true
  subgraph cluster_cl {
    a -> {b c}
  }
  r -> a
  b -> d
  # You can quickly get in WTF?! territory ...
  # You would expect that rank_d <= rank_r, but nope ...
  {rank=min d}
}
```

{:.my-split-h}
```myviz
digraph {
  newrank=true
  subgraph cluster_cl {
    a -> {b c}
  }
  r -> a
  b -> d
  {rank=min d}
}
```

### Other neat tricks

{:.my-split-h}
```dot
digraph {
  a -> {b c}
  # Heavy weight => short, straight and more vertical the edge.
  a -> d [weight=3]
}
```

{:.my-split-h}
```myviz
digraph {
  a -> {b c}
  a -> d [weight=3]
}
```


[0]:https://www.graphviz.org/doc/info/
[1]:http://viz-js.com/


