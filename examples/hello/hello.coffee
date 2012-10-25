hello = bach.ns('hello')
event = bach.ns('bach.event')
command = bach.ns('bach.command')

class hello.Person
  event.asSource(@::)

  grow: () -> @fireEvent('grow')

class hello.Observer
  event.asListener(@::)

  constructor: (person) ->
    @listenEvent(person, 'grow', 'onPersonGrow')

  onPersonGrow: () ->
    alert('Happy Birthday!')
    command.sendAfter(@, 'done')
    command.send(@, 'middle')
    command.send(@, 'middle')

  middle: () ->
    alert('Middle')

  done: () ->
    alert('Done')


hello.start = () ->
  hello.person = new hello.Person()
  hello.observer = new hello.Observer(hello.person)
  hello.person.grow()

