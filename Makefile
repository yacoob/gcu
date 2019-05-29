HOST:=gcu.tactical-grace.net

all: build

clean:
	rm -rf public
	find . -iname \*~ | xargs rm -f

.check-for-clean-repo:
	@[ `git status --porcelain | wc -l` -eq 0 ] || ( echo "There are unchecked files in the repository, please fix that."; exit 1 )


build: export GCU_BASE_URL:=https://$(HOST)
build:
	pipenv run python py/gen.py build

serve:
	pipenv run python py/gen.py serve

publish: .check-for-clean-repo clean
	git remote | xargs -L1 git push --all

# Golden files management.
golden-build: clean
	pipenv run python py/gen.py build --output_dir=golden --skip_static && git add golden && git diff --cached golden

golden-reset:
	git reset HEAD golden && rm -rf golden && git checkout -- golden

golden-diff: golden-build golden-reset

golden-update: .check-for-clean-repo golden-build
	git add -A golden && git commit -m 'Update golden files.'

# A helper to verify whether everything is reachable on the published site.
verifysite:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=$(HOST) http://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
