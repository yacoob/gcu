PVER=2.7.12
VENV=gcu-deploy

all: site

clean:
	rm -rf public/*

setup:
	pyenv install -s ${PVER}
	-pyenv virtualenv-delete -f ${VENV}
	pyenv virtualenv ${PVER} -f ${VENV}
	PYENV_VERSION=${VENV} pyenv exec pip install -rrequirements.txt
	pyenv local ${VENV}

newpost:
	python py/newpost.py

site:
	python py/gen.py

serve:
	cd public && python -m SimpleHTTPServer 8000

updatesite: clean site
	git add -A public
	-[ `git status --porcelain | grep -Ev '^ ' | wc -l` -gt 0 ] && git commit -m 'Update site.' public

publish: updatesite
	git subtree push --prefix public origin gh-pages
