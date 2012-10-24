###* Namespace management, basic object extension ###

@bach = {}
@bach.global = @

###* Import or create namespace like "bach.ui.dom" ###
bach.ns = (path) ->
  curr = bach.global
  for section in path.split('.')
    curr = (curr[section] ?= {})
  curr

###* Extend/mixin object with other objects ###
bach.extend = (obj, exts...) ->
  for ext in exts
    for k, v of ext when ext.hasOwnProperty(v)
      obj[k] = v
  obj

###*
* Declares object conforms to some protocol(s)
* Protocol is a string like 'bach.event.Target'
* The declaration make bach.isa(obj, protocol) => true
* Interface and behavior of protocol is defined by developers
* Framework dosen't make any check for whether the object really conforms
* to that.
###
bach.conforms = (obj, protocols...) ->
  for protocol in protocols
    obj['__conform_' + protocol] = true
  obj

###*
* Type detection, type can be either string or class
* When type is string, it checks the type against result of typeof
* and try to check if the object conforms to this protocol
###
bach.isa = (obj, t) ->
  if typeof(t) is 'string'
    (typeof(obj) is t) or (typeof(obj) is 'object' and obj['__conform_' + t] is true)
  else
    obj instanceof t
