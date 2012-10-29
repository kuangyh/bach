# Bach Core

Counterpart to backbone.js but takes another approach.

## Namespace management

[base.coffee](../src/base.coffee)

<pre>dom = bach.ns('bach.ui.dom')</pre>

Reference to a namespace, create one if not exists.

## Protocol

[base.coffee](../src/base.coffee)

Bach introduce **Protocol**, it's like **interface** in Java but you don't explicitly define actually interface like methods, actually constrains and behavior definition to the protocol are often documented inline.


	###* Protocol Model
	* Model must be a event.Target and triggers 'changed' event when it's content
	* changed. the changed event SHOULD have change property which is model.Change.
	* So the event receiver know extactly what's changed.
	###
	model.Model = bach.protocol('bach.model.Model')

	# Declare a protocol that extends another
	model.Collection = bach.protocol('bach.model.Collection', model.Model)

	# Declare a class/object conforms to some protocol
	class feed.Feed
	  # declare conform of class prototype make all its instance
	  # conform that protocol too.
	  bach.conforms(@::, model.Collection)
	  # implementation
	  ……

You can test conform of an object against Protocol using bach's type checking function bach.isa


	feed = new feed.Feed()
	bach.isa(feed, model.Model)  # true
	bach.isa(feed, model.Collection)  # true

As in the example above. ``Protocol'' are a lot more than just methods interface, it can be about **behavior** of an object, which is very hard to formally describe and check.

You can use Protocol mechanism to avoid duck-typing flaws. Do test object against protocol before important operations.

## Object shortcuts

[base.coffee](../src/base.coffee)

	bach.extend(object, exits…)


Same as other Javascript libraries provided.


	bach.isa(object, type)

	bach.isa('abc', 'string') # true
	bach.isa(feed, Protocol) # check protocol
	bach.isa('abc', String)  # true (note that instanceof returns false in this case)
	bach.isa(document.body, Node) # true, same as instanceof

Bach's all-in-one type checking function.

## Task

[task.coffee](../src/task.coffee)
	
Task provides a way to organize a set of asynchronously invoked functions that all together accomplish a feature. For example, clicking "refresh" button on UI starts a refresh task, the task may includes the original event handler function that issues AJAX request to server, callback function to parse data received, UI update functions triggered by data model changes etc.

Task framework solve fundamental problems in tasks similar to above, those problems are caused by heavily use of event and by async nature of Javascript.

   - **Asynchronies invoke**: There may be many handlers for an event triggered. Rather than call them directly on current stack, we need to asynchronously invoke them, **sched** them to run after the event trigger function returned.
   - **Task completion callback**: In the refresh task example, we need to hide the spin loading indicator after all refreshes done. So we need a **after** feature to register the callback.
   - **Wait and resume**: **after** feature leads to question about defining completion of a task, after we issued sever request but before the server response, the task is definitely not done, even when no more scheduled function to run. So in this case we tell task to **wait**, it just change a counter, no blocking here. When server response and oncomplete callback invoked, we **resume** the task. The task ends when no more scheduled function to run and nothing to wait.
   - **Force stop / Exception handling**: We may have "stop" button to stop refreshing. When we hit stop before the response returned. We can just **stop** the task, all scheduled functions and callbacks to be resumed will not be run anymore. The same rules applies to exception: when one of the task function throws an exception, the whole task can be stopped/canceled.
   
So there are 5 operation to task

   - `sched(fn, fnThis)`: Schedule a function to run on this task.
   - `after(fn, fnThis)`: Schedule a function to run after the task completed, in a separated new task.
   - `stop(excinfo)`: Stop the task with exception.
   - `wait()`: Tell the task to wait for a `resume` before mark itself as completed.
   - `resume()`: Resume a task from wait.

## Command

[command.coffee](../src/command.coffee)

Command provides a way to specify method invocation but leave the receiver of the invocation as blank, which is different from the classical [Command pattern](http://en.wikipedia.org/wiki/Command_pattern). Because we don't specify receiver at creation of command, we can dynamically route the command to different receiver (or even multiple receivers at one time).

In addition, object can conforms to `bach.command.HasExecute` protocol and provide a `execute(cmd)` method to execute command received rather than been automatically delegated to actual method.

There's no protocol check upon executing and we should have. It's a TODO item.

## Event



## Model

## Net