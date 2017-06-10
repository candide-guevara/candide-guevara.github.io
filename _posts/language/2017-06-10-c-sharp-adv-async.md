---
layout: post
title: Advanced C# aync features
categories : [article, windows]
css_custom: inline_images
---

Jon Skeet [describes][0] the transformations made by the compiler to split `async` methods in continuations.
To schedule the asynchronous tasks and continuations there a couple of key classes. Here is an approximate description of the what happens when a method `awaits` a task.

![charp_async_seq_diag]({{ site.images }}/Csharp_Async_SeqDiagram.svg)

## Cooperative tasks using `Task.Yield`

This example shows how to yield from tasks in order to let others be scheduled on that thread and not hog all resources on a **non blocking but long computation**.
To simulate a cpu constrained machine, I use ConcurrentExclusiveInterleave scheduler which piles all tasks in a single thread. This same class can be handy for implementing
[read/writer tasks][1].

{% highlight c# %}
  public class YieldTest {
      public static Stopwatch s_sw = Stopwatch.StartNew();

      public static void Main() {
          var tasks = new List<Task>();
          // We use a task scheduler that runs all tasks sequentially to simulate a bottleneck
          var sched = new ConcurrentExclusiveSchedulerPair();
          // By starting the task using the factory we are setting the exclusive TaskScheduler 
          // to be used by await on all sub tasks
          var facto = new TaskFactory(sched.ExclusiveScheduler);

          for(int i=0; i<4; i++) {
              // We need to copy i otherwise the lambda would capture a reference to the SAME loop variable
              int capture_i = i;
              // We need to use Unwrap() otherwise we would return a Task<Task> and the program would exit
              // once all lambdas would have finished without waiting for long_run_operation
              tasks.Add( facto.StartNew(() => long_run_operation(capture_i)).Unwrap() );
          }

          Task.WhenAll(tasks).Wait();
      }
      
      public static async Task long_run_operation (int index) {
          write_message(index);
          await Task.Yield();

          for(uint i=1; i < (1<<24); i++) {
              if (i % (1<<22) == 0) {
                  write_message(index, 100*i / (1<<24));
                  // By yielding here we requeue the rest of this task to the end of the queue
                  // allowing other tasks to make progress
                  await Task.Yield();
              }
          }
      }
      
      public static void write_message(int? index=null, uint progress=0,
                                        [CallerLineNumber] int line=0, [CallerMemberName] string func="") {
        Console.WriteLine("{4}:{5,-3} at={1,-5}, tid={2,-3}, idx={0,-3}, prog={3,-3}",
             index, s_sw.ElapsedMilliseconds, Thread.CurrentThread.ManagedThreadId, progress, func, line);
      }
  } // YieldTest
{% endhighlight %}

## Synchronization context and async locals

This example installs a noisy sync ctx to trace when it is called to schedule continuations. There are also special rules on how the [sync ctx is propagated][2] from task to task.
I use AsyncLocal objects to keep track of the logical execution stack even across the different threads where the task DAG nodes are run.

{% highlight c# %}
  public class SyncCtxTest {
      // The value of this variable is captured before awaiting and restored in the continuation
      public static AsyncLocal<string> s_lid = new AsyncLocal<string>();

      public static void sdfMain() {
          s_lid.Value = "main";
          foreach (var lid in new String[] {"1", "2"}) 
              LongRunOperation(lid).Wait();
      }

      public static async Task LongRunOperation(string lid) {
          s_lid.Value = "ou_" + lid;                                               // [0] run
          write_message();                                                         // [0] run
          SynchronizationContext.SetSynchronizationContext( new NoisySyncCtx() );  // [0] run
          // ConfigureAwait=false forbids calling the sync ctx to schedule
          // the continuation => it does not inherit the sync ctx instance
          await Task.Delay(200).ConfigureAwait(false);                             // [0] push 1 + ctx_switch
          write_message();                                                         // [1] pop
          // This await will not yield, the continuation 1 will run the beginning
          // of LongRunInnerOp method until it finds a real yield point
          await LongRunInnerOp(lid).ConfigureAwait(false);                         // [1] push 2
          write_message();                                                         // [2] pop
      }
      
      public static async Task LongRunInnerOp(string lid) {
          s_lid.Value = "in_" + lid;                                               // [1] run
          write_message();                                                         // [1] run
          // Set again the sync ctx, it will be used to schedule the continuation
          SynchronizationContext.SetSynchronizationContext( new NoisySyncCtx() );  // [1] run
          await Task.Delay(200).ConfigureAwait(true);                              // [1] push 3, 2 + ctx_switch
          // Task.Delay ended, call NoisySyncCtx to schedule the continuation
          write_message();                                                         // [3] pop  2
      }
      
      public static void write_message([CallerLineNumber] int line=0, [CallerMemberName] string func="") {
          Console.WriteLine("{0,-16}:{1,-3} tid={2,-3}, lid={3,-3}", func, line, Thread.CurrentThread.ManagedThreadId, s_lid.Value);
      }
  } // SyncCtxTest

  public class NoisySyncCtx : SynchronizationContext {
      public override void Post(SendOrPostCallback d, object state) {
          SyncCtxTest.write_message();
          base.Post(d,state);
      }
      public override void Send(SendOrPostCallback d, object state) {
          SyncCtxTest.write_message();
          base.Send(d,state);
      }
  } // NoisySyncCtx
{% endhighlight %}

[0]: http://csharpindepth.com/
[1]: https://blogs.msdn.microsoft.com/pfxteam/2010/04/08/parallelextensionsextras-tour-6-concurrentexclusiveinterleave/
[2]: https://blogs.msdn.microsoft.com/pfxteam/2012/06/15/executioncontext-vs-synchronizationcontext/

