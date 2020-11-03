GOLD_ROOT  := tmp
GOLD_DIR   := ${GOLD_ROOT}/gcu-golden
GOLD_OUT   := ${GOLD_ROOT}/gcu-out
BASE_URL   := ${DEPLOY_PRIME_URL}
ZOLA       ?= zola
HOST       ?= gcu.tactical-grace.net
# Make zola bind to all interfaces instead of locahost if we're running in
# Docker. This is necessary for the port forward to work without further
# fiddling.
SERVE_FLAG := $(or $(and $(wildcard /.dockerenv),--interface=0.0.0.0),)


.PHONY: all
all: build


.PHONY: clean
clean: golden-clean
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
	$(ZOLA) serve $(SERVE_FLAG)

.PHONY: serve-debug
serve-debug: TF:=$(shell mktemp)
serve-debug:
	cp -f config.toml $(TF)
	echo 'debug = true' >> $(TF)
	$(ZOLA) -c $(TF) serve $(SERVE_FLAG) && rm -f $(TF)

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
golden-build: .check-for-clean-repo clean
	@rm -rf $(D)
	@mkdir -p $(D)
	@$(ZOLA) build --output-dir=$(D) >/dev/null 2>&1
	@echo export GCU_GOLDEN=$(D)

.PHONY: golden-diff
golden-diff:
	test $(GCU_GOLDEN) || ( echo "Please set GCU_GOLDEN variable."; exit 1 )
	rm -rf $(GOLD_OUT)
	mkdir -p $(GOLD_OUT)
	$(ZOLA) build --output-dir=$(GOLD_OUT)
	-diff --color=always -Naru ${GCU_GOLDEN} $(GOLD_OUT) | less

.PHONY: golden-clean
golden-clean:
	rm -rf $(GOLD_ROOT)


# A helper to verify whether everything is reachable on the published site.
.PHONY: verify-site
verify-site:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=$(HOST) http://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
