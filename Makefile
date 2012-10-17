INIT=lib/init.js
BUNDLE=lib/bach.bundle.js

bundle: compile
	find lib -name '*.js' \! -path $(INIT) \! -path $(BUNDLE) | xargs cat $(INIT) > $(BUNDLE)

compile:
	coffee -c -o lib src

clean:
	rm -rf lib/*