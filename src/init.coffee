###* Bootstrap code for bach framework ###

@bach = {}
bach.global = @

###* Import namespace, create one if not exisits ###
bach.ns = (path) ->
  curr = bach.global
  for section in path.split('.')
    curr = (curr[section] ?= {})
  curr

# TODO: configurations?
