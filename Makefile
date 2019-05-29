HOST:=gcu.tactical-grace.net
GOLD_DIR:=/tmp/gcu-golden
GOLD_OUT:=/tmp/gcu-out

all: build

clean:
	@rm -rf public
	@find . -iname \*~ | xargs rm -f

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
# Usage: in a clean client run $(make golden-build). This will generate a set of
# files and set GCU_GOLDEN variable. Then make golden-diff
# will diff the currently buildable set of files against the one in $GCU_GOLDEN.
golden-build: D:=$(GOLD_DIR)/$(shell git rev-parse --short HEAD)
golden-build: clean golden-clean .check-for-clean-repo
	@mkdir -p $(D)
	@pipenv run python py/gen.py build --output_dir=$(D) --skip_static >/dev/null 2>&1
	@echo export GCU_GOLDEN=$(D)

# On OSX diff doesn't support --color. Well, we can abuse git for this... :D
golden-diff:
	test $(GCU_GOLDEN) || ( echo "Please set GCU_GOLDEN variable."; exit 1 )
	rm -rf $(GOLD_OUT)
	mkdir -p $(GOLD_OUT)
	pipenv run python py/gen.py build --output_dir=$(GOLD_OUT) --skip_static
	-git diff --no-index ${GCU_GOLDEN} $(GOLD_OUT)

golden-clean:
	rm -rf $(GOLD_DIR) $(GOLD_OUT)

# A helper to verify whether everything is reachable on the published site.
verifysite:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=$(HOST) http://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
