all: site

clean:
	rm -rf public/*

site:
	python py/gen.py

serve:
	python py/gen.py serve

updatesite: clean site
	git add -A public
	-[ `git status --porcelain | grep -Ev '^ ' | wc -l` -gt 0 ] && git commit -m 'Update site.' public

publish: updatesite
	git subtree push --prefix public origin gh-pages
	git push origin
	git push nas
