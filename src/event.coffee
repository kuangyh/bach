###* Event framework
* Design goals
###

event = bach.ns('bach.event')
command = bach.ns('bach.command')

###* Protocol Source
* Methods
*   - getEventSourceId(): String, return id string to uniquely identify this object
*   - fireEvent(type, opts): Fire an event
###
event.Source = 'protocol:bach.event.Source'

###* Protocol Listener
* Methods
*   - listenEvent(source, type, triggerMethod)
*   - unlistenEvent(source, type=null)
*   - unlistenEvents()
###
event.Listener = 'protocol:bach.event.Listener'

class event.Event
  constructor: (@source, @type, opts) ->
    if opts?
      bach.extend(@, opts)

###* Get source id of a source (or a sourceId) ###
event.getSourceId = (source) ->
  if bach.isa(source, String)
    source
  else if bach.isa(source, event.Source)
    source.getEventSourceId()
  else
    null

###* Get channel string to subscribe in event.Manager from source and type ###
event.getChannel = (source, type) ->
  if not (sourceId = @getSourceId(source))?
    return null
  sourceId + '#' + type

###* Get sourceId of a channel ###
event.getChannelSourceId = (channel) ->
  sharp = channel.indexOf('#')
  if sharp >= 0 then channel.substring(0, sharp) else null

###* Get type of a channel ###
event.getChannelType = (channel) ->
  sharp = channel.indexOf('#')
  if sharp >= 0 then channel.substring(sharp + 1) else null


###* Manages all event subscribtion ###
class event.Manager
  constructor: ->
    @subs = {}

  listen: (channel, target, targetMethod) ->
    (@subs[channel] ?= []).push([target, targetMethod])
    channel

  unlisten: (channel, target) ->
    queue = @subs[channel]
    if queue?
      queue = queue.filter((x) -> x[0] != target)
      if queue.length > 0
        @subs[channel] = queue
      else
        delete @subs[channel]
    null

  fire: (channel, evt) ->
    for [target, targetMethod] in (@subs[channel] or [])
      command.send(target, targetMethod, evt)
    evt

event.manager = new event.Manager()

# Default implementation for event.Source
event.__currAutoSourceId = 0
event.SourceImpl =
  getEventSourceId: ->
    @__eventSourceId ?= 'auto_' + (event.__currAutoSourceId += 1)

  fireEvent: (type, opts) ->
    event.manager.fire(event.getChannel(@, type), new event.Event(@, type, opts))
bach.conforms(event.SourceImpl, event.Source)

###* Become event source with default implementation ###
event.asSource = (obj) ->
  bach.extend(obj, event.SourceImpl)

# Default implementation for event.Listener
# listener.__listens to store all channels the object listens to
event.ListenerImpl =
  listenEvent: (source, type, triggerMethod) ->
    if not (channel = event.getChannel(source, type))?
      return null
    event.manager.listen(channel, @, triggerMethod)
    (@__listens ?= {})[channel] = true
    channel

  unlistenEvent: (source, type) ->
    if not (listens = @__listens)?
      return null
    if type?
      channel = event.getChannel(source, type)
      event.manager.unlisten(channel, @)
      delete listens[channel]
    else
      # Find all listened channel with this source
      sourceId = event.getSourceId(source)
      for chn, tmp of listens when event.getChannelSourceid(chn) == sourceId
        event.manager.unlisten(chn, @)
        delete listens[chn]
    null

  unlistenEvents: () ->
    if not (listens = @__listens)?
      return null
    for chn, tmp of listens
      event.manager.unlisten(chn)
    delete @__listens
    null
bach.conforms(event.ListenerImpl, event.Listener)

event.asListener = (obj) ->
  bach.extend(obj, event.ListenerImpl)
