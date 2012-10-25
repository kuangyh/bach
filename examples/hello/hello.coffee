hello = bach.ns('hello')
event = bach.ns('bach.event')

class hello.Person
  event.asSource(@::)

  grow: () -> @fireEvent('grow')

class hello.Observer
  event.asListener(@::)

  constructor: (person) ->
    @listenEvent(person, 'grow', 'onPersonGrow')

  onPersonGrow: () ->
    alert('Happy Birthday!')

hello.start = () ->
  person = new hello.Person()
  observer = new hello.Observer(person)
  person.grow()

