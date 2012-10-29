BUNDLE=lib/bach.bundle.js

CORE_LIB = \
	lib/base.js \
	lib/task.js \
	lib/command.js \
	lib/event.js \
	lib/model.js \
	lib/net.js

example: bundle
	coffee -c examples

bundle: compile
	cat $(CORE_LIB) > $(BUNDLE)

compile:
	coffee -c -o lib src

clean:
	rm -rf lib/*
	find examples -name '*.js' | xargs rm
