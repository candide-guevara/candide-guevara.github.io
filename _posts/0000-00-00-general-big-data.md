---
title: Big data, map reduce, hadoop
date: 2015-05-25
categories: [cs_related, hadoop, big_data]
---

## Big data notions
* Heavy Data - data so big that it is very slow to transfer through network -> has to be processed in place
* A/B testing - measure the performance of 2 products differing only by a single parameter over huge
* Amounts of tests (very used in web site presentation)
* Test and learn - perform modifications on a test group and compare performance over the control group
  If modification significantly increases performance, it will be applied to all products (=rollout)
  Ex: used in hotel renovation to decide if investments are worth

### Some machine learning
* Logistic regression - use training data to evaluate the separating plane between 2 type of data
* Centroid-based Clustering - chose random cluster centers, calculate barycenter of points closer to a centroid use those barycenter as the new centroids and iterate

### Strenghts of map reduce
* MapReduce code easily unit testable
* Separation between infrastructure and algorithm
* Capable of optimization by knowing network topology (number of hops)
* Takes advantage of data distribution across nodes by executing tasks in the data nodes themselves

### Bottlenecks of map reduce
* Batch oriented not good for polling because of nodes coordination overhead
* reducers can only start after all mappers have finished
* Data copy for the sorting stage previous to reducing
* Depending on the algorithm only one reducer node can be used (else each reducer can process a subset based on consistent hashing)
* Namenode/job tracker single point of failure

## Some Big Data Implementations

### Impala : analytical engine (analyze big data interactively)
* Dremel (distributed system to handle queries on large data sets) implementation
* SQL sub set interface
* SQL queries are based on the schema given on top of the big files
* SQL query decomposed in execution plan tree, each task node executed in parallel if possible
* Optimized Task Code generation (takes into account type f machine) with LLVM
* Ring topology = no single point of failure
* Each node is capable of optimizing-scheduling-dispatching and collecting results

### Spark : in memory resilient distributed datasets
Good for iterative algorithms since it has an in cache mechanism to store previous results distributed algorithms for machine learning

### Hadoop : Map reduce implementation in Java
* Composed of HDFS (distributed filesystem) and job scheduling
* Comes with a shell to make hdfs look like a regular hard drive
The diagram below is obsolete now because of Yarn.

![Hadoop_Cluster.svg]({{ site.images }}/Hadoop_Cluster.svg){:.my-wide-img}
