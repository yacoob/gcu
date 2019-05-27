HOST:=gcu.tactical-grace.net

all: build

clean:
	rm -rf public
	find . -iname \*~ | xargs rm -f

build: export GCU_BASE_URL:=https://$(HOST)
build:
	pipenv run python py/gen.py build

serve:
	pipenv run python py/gen.py serve

golden-build: clean
	pipenv run python py/gen.py build --output_dir=golden --skip_static && git diff --no-pager golden

golden-update: golden-build
	git add -A golden && git commit -m 'Update golden files.'

publish: clean
	git remote | xargs -L1 git push --all

verifysite:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=$(HOST) http://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
