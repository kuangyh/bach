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
    for k, v of ext when ext.hasOwnProperty(k)
      obj[k] = v
  obj

class bach.Protocol
  constructor: (@name, _extends...) ->
    # All direct and indirect extended protocol's name
    @_extends = []
    extendDict = {}
    for ext in _extends when not (ext.name in extendDict)
      extendDict[ext.name] = true
      for indirectExtName in ext._extends
        extendDict[indirectExtName] = true
    for k, v of extendDict
      @_extends.push(k)

bach.protocol = (args...) -> new bach.Protocol(args...)

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
    obj['__conform_' + protocol.name] = true
    for ext in protocol._extends
      obj['__conform_' + ext] = true
  obj

###*
* Type detection, type can be either string or class
* When type is string, it checks the type against result of typeof
* and try to check if the object conforms to this protocol
###
bach.isa = (obj, t) ->
  if typeof(t) is 'string'
    (typeof(obj) is t)
  else if obj? and t.constructor == bach.Protocol
    obj['__conform_' + t.name] == true
  else
    (obj? and obj.constructor == t) or (obj instanceof t)

###* Check type and assertion ###
bach.check = (obj, type, assertFn) ->
  if type? and not bach.isa(obj, type)
    throw new TypeError("#{obj} is not a #{type}")
  if assertFn? and not assertFn(obj)
    throw new TypeError('Assert error')
  obj
