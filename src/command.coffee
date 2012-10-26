###* Method invocation with task framework ###

command = bach.ns('bach.command')
task = bach.ns('bach.task')

###* HasExecute protocol
* Methods
*   - execute(cmd: command.Command)
###
command.HasExecute = 'protocol:bach.command.HasExecute'

class command.Command
  constructor: (@method, @args...) ->

  apply: (dst) ->
    if not dst?
      null
    else if bach.isa(dst, command.HasExecute)
      dst.execute(@)
    else if bach.isa(dst[@method], Function)
      dst[@method](@args...)
    else
      null

###* Execute command in same task, create task if currently not in task ###
command.send = (dst, cmd, args...) ->
  if not bach.isa(cmd, command.Command)
    cmd = new command.Command(cmd, args...)
  task.sched(-> cmd.apply(dst))
  cmd

###* Execute command after current task done, create and spawn if currently not in task ###
command.sendAfter = (dst, cmd, args...) ->
  if not bach.isa(cmd, command.Command)
    cmd = new command.Command(cmd, args...)
  task.after(-> cmd.apply(dst))
  cmd

###* Spawn a new task to execute the command ###
command.sendSpawn = (dst, cmd, args...) ->
  if not bach.isa(cmd, command.Command)
    cmd = new command.Command(cmd, args...)
  task.spawn(-> cmd.apply(dst))
  cmd
