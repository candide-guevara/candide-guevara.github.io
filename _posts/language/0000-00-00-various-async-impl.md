---
title: C#, python, javascript async implementations
date: 2017-06-24
categories: [cs_related, python, csharp]
---

Short survey on the different ways asynchronous computation is implemented in python, csharp and javascript (before ECMA 8th edition).

{:.my-table}
|         | Python| Csharp |
|---------|-------|--------|
| Threading | mono threaded<br/>You can use an `Executor` to delegate work to other threads/processes | most often backed by the thread pool <br/>(configurable via `SynchronizationContext` and `TaskScheduler`) |
| Blocking calls / races | No race conditions<br/>only one task is executing at any given time on the event loop thread | Blocking in a task will only block 1 thread in the pool<br/>if the same task is submitted several times there can be race conditions |
| Event loop / Scheduler | Explicit start, schedule and stop the event loop | Just call `Task.Run` |
| Futures vs Tasks | Task: wrapper around a coroutine to schedule it to an event loop<br/>Future: something you can await | No difference, there is only Task |
| Coroutine control flow | Instanciating a coroutine does not start its execution, you have to await | Calling an async function will run it synchronously until the first `await` |
| Cancellation | Just cancel the task and the next `await` will raise a cancel exception | Explicitely pass a `CancellationToken` along the call chain |

## Comparison of a simple application

Here is the implementation of a basic http ping program that asynchronously retrieves the HEAD of various domains. It has both sequential and asynchronous ping as illustrated here :

           / (ping google.es) ---> (ping google.com)\
          /                                          \
    (start)                                           (join)
          \                                          /
           \ (ping google.fr) ---> (ping google.ch) /


### Python (asyncio streams)

{% highlight python %}
  def main():
    with stopwatch() as elapsed:
      loop = asyncio.get_event_loop()
      times = loop.run_until_complete(parallel_http_ping_sites())
      loop.close()
      
    print("Real time: %f\nTime per site: %r\nTotal time: %f" 
          % (elapsed[0], times, sum(v for v in times.values())) )

  async def parallel_http_ping_sites():
    f1 = sequentially_http_ping_sites('google.fr', 'google.ch')
    f2 = sequentially_http_ping_sites('google.es', 'google.com')
    done,pending = await asyncio.wait([f1, f2])

    times = {}
    for fut in done:
      times.update( fut.result() )
    return times

  async def sequentially_http_ping_sites(*args):
    times = {}
    for arg in args:
      with stopwatch() as elapsed:
        await single_site_http_ping(arg)
      times[arg] = elapsed[0]
    return times

  async def single_site_http_ping(host):
    reader,writer = await asyncio.open_connection(host, 80)
    http_head = 'HEAD / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(http_head.encode('utf8'))
    response = await reader.read()
    writer.close()

  @contextlib.contextmanager
  def stopwatch():
    result = [time.perf_counter()]
    yield result
    result[0] = time.perf_counter() - result[0] 
{% endhighlight %}

### Csharp

You've done it again C#, implementation is even simpler than python because you do not have to care about the event loop boilerplate.

{% highlight c# %}
  public class HttpPingTest {
      public static HttpClient s_client = new HttpClient();

      public static void Main() {
          Stopwatch chrono = Stopwatch.StartNew();
          // No need for boiler plate, just block this thread after it has scheduled all the child tasks
          var times = parallel_http_ping_sites().Result;
          Console.WriteLine("Real time : {0}\nTime per site : {1}\nTotal time : {2}",
              chrono.Elapsed,
              String.Join(", ", times.Select(kv => kv.Key + ":" + kv.Value.ToString())),
              times.Aggregate(new TimeSpan(), (acc, kv) => acc + kv.Value) );
      }
      
      public static async Task<IDictionary<String, TimeSpan>> parallel_http_ping_sites () {
          var t1 = sequentially_http_ping_sites("google.fr", "google.ch");
          var t2 = sequentially_http_ping_sites("google.es", "google.com");
          // here the main thread will wait for all pings to finish
          var all = await Task.WhenAll(t1, t2);
          return all.SelectMany(times => times).ToDictionary(kv=>kv.Key, kv=>kv.Value);
      }

      public static async Task<IDictionary<String, TimeSpan>> sequentially_http_ping_sites (params string[] hosts) {
          var times = new Dictionary<String, TimeSpan>();
          Stopwatch chrono = Stopwatch.StartNew();
          foreach(var host in hosts) {
              chrono.Restart();
              await single_site_http_ping(host);
              times[host] = chrono.Elapsed;
          }
          return times;
      }

      public static async Task single_site_http_ping (string host) {
          var request = new HttpRequestMessage(HttpMethod.Head, $"http://{host}");
          var response = await s_client.SendAsync(request);
          var str = await response.Content.ReadAsStringAsync();
      }
      
  } // HttpPingTest
{% endhighlight %}

### Javascript (chaining promises)

The complexity compared to python and C# has really gone through the roof (considering this is a simple task)

{% highlight javascript %}
  function main() {
      var real_time = StopWatch.now();
      parallel_http_ping_sites().then( function(results) {
          times = StopWatch.merge_times(results);
          real_time = StopWatch.now() - real_time;
          print_results(real_time, times);
      })
      .catch( function (error) {
          // The following will not propagate any exception (it will just add another failed promise to the chain
          // throw error;
          // This works because we throw inside a callback on the event loop (but no call stack)
          setImmediate(function() { throw error; });
      });
      // In node.js we do not need to wait for the event loop, the process will end once there is nothing more to do
  }

  function parallel_http_ping_sites () {
      var p1 = sequentially_http_ping_sites('google.fr', 'google.ch');
      var p2 = sequentially_http_ping_sites('google.es', 'google.com');
      return Promise.all([p1, p2]);
  }

  function sequentially_http_ping_sites () {
      var hosts = Array.prototype.slice.call(arguments);
      var times = new StopWatch();
      // Start chain with a resolved promise, it value will be discarted
      var promise_chain = Promise.resolve(null);

      for(var index in hosts) {
          var host = hosts[index];
          promise_chain = promise_chain
              .then( times.onStart(host) )
              .then( single_site_http_ping.bind(null, host) )
              .then( times.onStop(host) )
      }
      // Finish promise chain returning the timing information of the previous calls
      return promise_chain.then( function() { return times; } );
  }

  function single_site_http_ping (host) {
      // Transform the http.request callback api to the promise of a http response
      var response = new Promise( function(accept, reject) {
          var options = {
              'host' : host,
              'method' : 'HEAD'
          };
          var request = Http.request(options, accept);
          request.on('error', reject);
          request.end();
      });
      // Returning a pending promise on the `then` handler will create a proxy for it in consume_response
      // Equivalent to awaiting the result of an already synchronous operation
      var consume_response = response.then( function(response) {
          return new Promise( function(accept, reject) {
              response.on('data', function() { /*discard*/ });
              response.on('error', reject);
              response.on('end', function() { accept(response.headers); });
          });
      });
      return consume_response;
  }

  function print_results(real_time, times) {
      var m = times.measures;
      var keys = Object.keys(m);
      console.log('Real time : ' + real_time
          + "\nTime per site : " + JSON.stringify(m)
          + "\nTotal time : "    + keys.reduce( function(acc, k) { return acc + m[k]; }, 0)
      );
  }

  function StopWatch() { this.measures = {}; }

  StopWatch.now = function() {
      var now = process.hrtime();
      return Math.round(now[0] * 1000 + now[1] / 1000000);
  }

  StopWatch.merge_times = function(sw_list) {
      var result = new StopWatch();
      for(var index in sw_list)
          for (var m in sw_list[index].measures) 
              result.measures[m] = sw_list[index].measures[m];
      return result;
  }

  StopWatch.prototype.onStart = function(tag) {
      var me = this.measures;
      return function() { me[tag] = StopWatch.now(); }
  }

  StopWatch.prototype.onStop = function(tag) {
      var me = this.measures;
      return function() { me[tag] = StopWatch.now() - me[tag]; }
  }
{% endhighlight %}

## Dummy event loop implementation using `yield from`

{% highlight python %}
  def main():
    tasks = [ outer_async(1), another_outer_async(2) ]
    # run the 2 tasks asynchronously and return once all done
    dummy_event_loop(tasks)
    
  def dummy_event_loop(tasks):
    futures = [ next(t) for t in tasks ]
    actives = [ True for t in tasks ]
    indexes = range( len(tasks) )

    # the event loop iterates until all tasks have raised a StopIteration
    while any(actives):
      print("----- event loop iteration ------")

      for active,task,future,index in zip(actives,tasks,futures,indexes):
        if not active: continue
        # to make things simple, futures return immediately
        res = future.wait()
        try: futures[index] = task.send(res)
        except StopIteration: actives[index] = False

  def outer_async(wid):
    print("start outer_async", wid)
    res = yield from inner_async(wid)
    print("end outer_async %r : %s" % (wid,res))

  def another_outer_async(wid):
    print("start another outer_async", wid)
    res = yield from inner_async(wid)
    print("middle another outer_async %r : %r" % (wid,res))
    res += yield from inner_async(wid)
    print("end another outer_async %r : %r" % (wid,res))

  def inner_async(wid):
    print("start inner", wid)
    res1 = yield DummyIOFuture()
    print("middle inner %r: %s" % (wid,res1))
    res2 = yield DummyIOFuture()
    print("end inner %r: %s" % (wid,res2))
    return [res1, res2]

  class DummyIOFuture:
    _count = 0
    def wait(self):
      DummyIOFuture._count += 1
      return "some io %d" % DummyIOFuture._count
{% endhighlight %}

