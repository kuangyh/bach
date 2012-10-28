###* Model protocols and collection model implementation ###

model = bach.ns('bach.model')
command = bach.ns('bach.command')

###* Record operations to a model using a series of commands ###
class model.Change
  constructor: ->
    @commands = []

  get: () -> @commands

  add: (method, args...) ->
    cmd = new command.Command(method, args...)
    @commands.push(cmd)
    @

  apply: (dst) ->
    for cmd in @commands
      cmd.apply(dst)
    dst

  publish: (model) ->
    model.trigger('changed', change: @)

###* Protocol Model
* Model must be a event.Target and triggers 'changed' event when it's content
* changed. the changed event SHOULD have change property which is model.Change.
* So the event receiver know extactly what's changed.
###
model.Model = bach.protocol('bach.model.Model')

###* A simple single value model ###
class model.Value
  bach.conforms(@::, model.Model)

  constructor: (init) ->
    @value = init

  get: -> @value

  set: (newValue) ->
    (new model.Change()).add('set', newValue, @value).publish(@)
    @value = newValue

  set: (newValue) ->
    @swap(newValue)
    newValue
