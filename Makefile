GOLD_DIR := /tmp/gcu-golden
GOLD_OUT := /tmp/gcu-out
BASE_URL := ${DEPLOY_PRIME_URL}
ZOLA     ?= zola
HOST     ?= gcu.tactical-grace.net


.PHONY: all
all: build


.PHONY: clean
clean:
	@rm -rf public
	@find . -iname \*~ | xargs rm -f

.PHONY: .check-for-clean-repo
.check-for-clean-repo:
	@[ `git status --porcelain | wc -l` -eq 0 ] || ( echo "There are unchecked files in the repository, please fix that."; exit 1 )

.PHONY: .cleanup-kit-pages
.cleanup-kit-pages:
	find public -type f -empty -delete
	find public -type d -empty -delete

.PHONY: zola-build
zola-build:
	$(ZOLA) build

.PHONY: zola-build-override-base-url
zola-build-override-base-url:
	$(ZOLA) build --base-url=$(BASE_URL)

.PHONY: serve
serve:
	$(ZOLA) serve

.PHONY: build build-netlify-preview
build: zola-build .cleanup-kit-pages
build-netlify-preview: zola-build-override-base-url .cleanup-kit-pages

.PHONY: publish
publish: .check-for-clean-repo clean
	git remote | xargs -L1 git push --all


# Golden files management.
# Usage: in a clean client run $(make golden-build). This will generate a set of
# files and set GCU_GOLDEN variable. Then make golden-diff
# will diff the currently buildable set of files against the one in $GCU_GOLDEN.
.PHONY: golden-build
golden-build: D:=$(GOLD_DIR)/$(shell git rev-parse --short HEAD)
golden-build: clean .check-for-clean-repo
	@rm -rf $(D)
	@mkdir -p $(D)
	@$(ZOLA) build --output-dir=$(D) >/dev/null 2>&1
	@echo export GCU_GOLDEN=$(D)

# On OSX diff doesn't support --color. Well, we can abuse git for this... :D
.PHONY: golden-diff
golden-diff:
	test $(GCU_GOLDEN) || ( echo "Please set GCU_GOLDEN variable."; exit 1 )
	rm -rf $(GOLD_OUT)
	mkdir -p $(GOLD_OUT)
	$(ZOLA) build --output-dir=$(GOLD_OUT)
	-git diff --no-index ${GCU_GOLDEN} $(GOLD_OUT)

.PHONY: golden-clean
golden-clean:
	rm -rf $(GOLD_DIR) $(GOLD_OUT)


# A helper to verify whether everything is reachable on the published site.
.PHONY: verify-site
verify-site:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=$(HOST) http://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
