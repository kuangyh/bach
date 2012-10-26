bach
====

CoffeeScript framework for Web Development.

## Bach core

Counterpart to backbone.js but takes another approach.

### Namespace management

<pre>dom = bach.ns('bach.ui.dom')</pre>

Reference to a namespace, create one if not exists.

### Object model enhancements

Bach introduce **Protocol**. Protocol is essentially a string identifier. By **conforms** a protocol, the object declares it conforms to some feature/behavior (has some certain methods etc.). It can be later check by **bach.isa(obj, ProtocolOrType)**.

Protocol provides something like Java's interface. Checking whether the object conforms to some protocol to decide how to interact with it is a lot more safer and debugable than pure duck-typing. Unlike Java's interface, it don't provide any constrain and hence do no checking at language level. The specificiation and contrains of the protocol are up to developers own definition. (Better with inline document)

Note that bach.conforms() is compatible with Javascript's prototype model. Declare a prototype of a class to conforms to a protocol will make all its object conforms it.

Example:

<pre>
###* Protocol event target
* Methods
*   - trigger(type, opts) => triggers an event on this object
*   - bind(type, dst, method) => Listens an event
*   - unbind(type, dst) => Unlisten an event
###
event.Target = 'protocol:bach.event.Target'

class event.TargetImpl
  bach.conforms(@::, event.Target)

bach.isa(new event.TargetImpl(), event.Target) # => true
</pre>

Bach has **bach.isa()** for type detecting as descirbed before.

<pre>
bach.isa('Hello', String) # => true
bach.isa(document.getElementById('container'), Node) # => true
bach.isa('Hello', 'string') # => true
bach.isa(obj, ProtocolString)
</pre>
