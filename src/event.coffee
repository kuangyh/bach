###* Event framework
* Design goals
###

event = bach.ns('bach.event')
command = bach.ns('bach.command')

###* Event payload ###
class event.Event
  constructor: (@target, @type, opts) ->
    bach.extend(@, opts)

###* Protocol event target
* Methods
*   - trigger(type, opts) => triggers an event on this object
*   - on(type, dst, method) => Listens an event
*   - off(type, dst) => Unlisten an event
###
event.Target = 'protocol:bach.event.Target'

class event.Manager
  constructor: ->
    @pool = {}

  on: (type, dst, method) ->
    (@pool[type] ?= []).push([dst, method])
    type

  off: (type, dst) ->
    removeFromQueue = (t) ->
      queue = @pool[t]
      if queue?
        queue = queue.filter((x) -> x[0] != dst)
        if queue.length > 0
          @pool[t] = queue
        else
          delete @pool[t]
      t

    if type == '*'
      for t, q of @pool
        removeFromQueue(t)
    else if type[-2..] == '.*'
      prefix = type[..-2]
      for t, q of @pool when t[..prefix.length - 1] == prefix
        removeFromQueue(t)
    else
      removeFromQueue(type)
    type

  trigger: (evt) ->
    # Find all types to trigger
    types = [evt.type]
    if (sections = evt.type.split('.')).length > 1
      for endPos in [sections.length - 2 .. 0]
        types.push(sections[..endPos].join('.') + '.*')
    types.push('*')

    # Triggers using command
    for triggerType in types
      for [dst, method] in (@pool[triggerType] or [])
        command.send(dst, method, evt)
    evt

###* Default Target implementation, use event.Manager ###
event.TargetImpl =
  on: (type, dst, method) ->
    (@__eventManager ?= new event.Manager()).on(type, dst, method)

  off: (type, dst, method) ->
    (@__eventManager ?= new event.Manager()).off(type, dst, method)

  trigger: (type, opts) ->
    (@__eventManager ?= new event.Manager()).trigger(
      new event.Event(@, type, opts))
    # When channel setted, broadcast though event bus
    if @__channel?
      event.bus.trigger(new event.Event(@, @__channel + '.' + type, opts))
bach.conforms(event.TargetImpl, event.Target)

###* Enable target protocol with default implementation ###
event.asTarget = (obj) ->
  bach.extend(obj, event.TargetImpl)

event.bus = new event.Manager()
