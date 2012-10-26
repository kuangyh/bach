hello = bach.ns('hello')
event = bach.ns('bach.event')
command = bach.ns('bach.command')

class hello.Person
  event.asTarget(@::)

  __channel: 'hello.Person'

  constructor: (@name) ->

  grow: ->
    @trigger('grow')

class hello.Observer
  constructor: () ->
    event.bus.on('hello.Person.grow', @, 'greeting')

  greeting: (evt) ->
    alert('Happy birthday! ' + evt.target.name)

hello.start = () ->
  hello.person = new hello.Person('Yuheng')
  hello.observer = new hello.Observer(hello.person)
  hello.person.grow()
