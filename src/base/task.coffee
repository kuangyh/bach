###* Task framework
Behaviors casued by user action/event or timer are organized in tasks.
###

task = bach.ns('bach.task')

task._stack = []

task.current = () -> task._stack[task._stack.length - 1]

###* Task runtime environment ###
class task.Task
  constructor: (initFn, initThis) ->
    @_runtime =
      running: false    # if it's currently inside @run()
      stopped: false    # if it's stopped, either normally or by exception
      pending: 0        # How many wait() are call but not resume()
      excinfo: null     # The exception that cause the task to stop
      queue: []         # Pending run queue
      after: []         # tasks to create and run after the task normally ended.
    @sched(initFn, initThis)

  ###* Schedule a new function to run in this task ###
  sched: (fn, target) ->
    if bach.isa(fn, Function) and not @_runtime.stopped
      @_runtime.queue.push([fn, target])
      true
    else
      false

  ###* Notify the task to wait for a resume() before end ###
  wait: () ->
    if not @_runtime.stopped
      @_runtime.pending += 1
      true
    else
      false

  ###* Notify the task to resume a wait() and perform the desire function ###
  resume: (fn, target) ->
    if @sched(fn, target) and @_runtime.pending > 0
      @_runtime.pending -= 1
      if @_runtime.pending == 0
        @run()
      true
    else
      false

  ###* Schedule a task to run after this task successfully ended ###
  after: (fn, target) ->
    if not @_runtime.stopped
      @_runtime.after.push([fn, target])
      true
    else
      false

  ###* Run functions in queue until no more function or stopped by exception ###
  run: () ->
    if @_runtime.stopped or @_runtime.running
      return @
    @_runtime.running = true
    task._stack.push(@)

    while @_runtime.queue.length > 0
      [fn, target] = @_runtime.queue.shift()
      try
        fn.call(target)
      catch e
        @_runtime.excinfo = e
        @_runtime.stopped = true
        break
    if @_runtime.queue.length == 0 and @_runtime.pending == 0
      @_runtime.stopped = true
    @_runtime.running = false

    if @_runtime.stopped and (not @_runtime.excinfo?)
      # stopped with no exception, can spawn after tasks
      for spec in @_runtime.after
        @_spawnTask(spec...)
    @

  _spawnTask: (fn, target) ->
    setTimeout((-> (new task.Task(fn, target)).run()), 0)

  isRunning: () -> @_runtime.running
  isStopped: () -> @_runtime.stopped
  getException: () -> @_runtime.excinfo
