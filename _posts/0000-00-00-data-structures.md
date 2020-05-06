---
title: Data structure, some interesting examples
date: 2015-05-25
categories: [cs_related]
---

## Red black tree
Self balancing binary tree (nodes are sorted) that guarantees the ration between longer and shorter branches is < 2
Nodes are colored in 2 colors so that the following rules are always respected

* The root is black
* A red node cannot have a red parent
* The number of black nodes in any branch is the same
* All leaf nodes have a pair of fake null black nodes

Nodes to add are red but can change color depending on tree configuration, **many cases to handle** in order to keep the properties after insertion/removal.
To keep color properties, insertion and removalof nodes may trigger rotations on branches of the tree (3 maximum per operation)
=> properties kept = balanced tree

## Heaps
Any tree data structure in which there is an order between the parent node and all its descendants (greater/less than...).
There is no constraint on the order of siblings (contrary to a binary tree for example).

* Binary heap - a binary tree where nodes respect the heap property
 
![Data_St_Black_Red_Tree.svg]({{ site.images }}/Data_St_Black_Red_Tree.svg){:.my-block-wide-img}
![Data_St_Heap_Structure.svg]({{ site.images }}/Data_St_Heap_Structure.svg){:.my-block-wide-img}
