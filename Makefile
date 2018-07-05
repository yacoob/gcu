HOST:=gcu.tactical-grace.net

all: site

clean:
	rm -rf public/*
	find . -iname \*~ | xargs rm -f

site: export GCU_BASE_URL:=https://$(HOST)
site:
	python py/gen.py

serve:
	python py/gen.py serve

updatesite: clean site
	git add -A public
	-[ `git status --porcelain | grep -Ev '^ ' | wc -l` -gt 0  ] && git commit -m 'Update site.' public

publish: LFTP_USER:=tacticcj
publish: LFTP_URI:=ftp://www493.your-server.de
publish: REMOTE_DIR:=/public_html/$(HOST)
publish: export LFTP_PASSWORD:=$(shell /usr/bin/security find-generic-password -s gcuftp -w)
publish: updatesite
	lftp -c 'set ftp:ssl-force yes; open --env-password -u $(LFTP_USER) $(LFTP_URI) && mirror -c -e -P5 -L -x .DS_Store -x .gitignore -R public $(REMOTE_DIR)'
	git push origin
	git push nas

verifysite:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=tactical-grace.net https://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
