###* Task framework
Behaviors casued by user action/event or timer are organized in tasks.
###

task = bach.ns('bach.task')

###* Maintains a task run queue ### 
class task.Scheduler
  constructor: ->
    @running = false
    @queue = []
    @currentTask = null

  sched: (t, fn, target) ->
    @queue.push([t, fn, target])
    if not @running
      @_runOnce()
    t

  _runOnce: () ->
    @running = true
    while @queue.length > 0
      [t, fn, target] = @queue.shift()
      @currentTask = t
      t.run(fn, target)
    @running = false
    @currentTask = null

task.scheduler = new task.Scheduler()

###* Get the current running task. ###
task.current = () -> task.scheduler.currentTask

###* Task runtime environment ###
class task.Task
  constructor: (opts) ->
    @_runtime =
      stopped: false
      pending: 0
      excinfo: null
      after: []

  sched: (fn, target) ->
    if not @_runtime.stopped
      @_runtime.pending += 1
      task.scheduler.sched(@, fn, target)
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
    if not @_runtime.stopped and @_runtime.pending > 0
      @_runtime.pending -= 1
      @sched(fn, target)
      true
    else
      false

  ###* Stop a task ###
  stop: (excinfo) ->
    if @_runtime.stopped
      false
    @_runtime.stopped = true
    @_runtime.excinfo = excinfo
    true

  ###* Schedule a task to run after this task ended ###
  after: (fn, target) ->
    if not @_runtime.stopped
      @_runtime.after.push([fn, target])
      true
    else
      false

  ###* Run functions in queue until no more function or stopped by exception ###
  run: (fn, target) ->
    if @_runtime.stopped
      return @
    @_runtime.pending -= 1
    try
      fn.call(target)
    catch e
      @stop(e)
    if not @_runtime.stopped and @_runtime.pending == 0
      @stop()

    if @_runtime.stopped
      for [afterFn, afterTarget] in @_runtime.after
        (new task.Task(beforeTask: @)).sched(afterFn, afterTarget)
    @

  isStopped: () -> @_runtime.stopped
  getException: () -> @_runtime.excinfo
  isDone: () -> @isStopped() and not @getException()?

###* Shortcut: sched in current task ###
task.sched = (fn, target) ->
  if (curr = task.current())?
    curr.sched(fn, target)
  else
    task.spawn(fn, target)

###* Shortcut: after current task ###
task.after = (fn, target) ->
  if (curr = task.current())?
    curr.after(fn, target)
  else
    task.spawn(fn, target)

###* Shortcut: new task ###
task.spawn = (fn, target) ->
  (new task.Task()).sched(fn, target)
