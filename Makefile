HOST:=p.tactical-grace.net

all: site

clean:
	rm -rf public/*
	find . -iname \*~ | xargs rm -f

site: export GCU_BASE_URL:=https://$(HOST)
site:
	python py/gen.py

serve:
	python py/gen.py serve

updatesite: LFTP_USER:=tacticcj
updatesite: LFTP_URI:=ftp://www493.your-server.de
updatesite: REMOTE_DIR:=/public_html/$(HOST)
updatesite: export LFTP_PASSWORD:=$(shell /usr/bin/security find-generic-password -s gcuftp -w)
updatesite: clean site
	lftp -c 'set ftp:ssl-force yes; open --env-password -u $(LFTP_USER) $(LFTP_URI) && mirror -c -e -P5 -L -x .DS_Store -x .gitignore -R public $(REMOTE_DIR)'

publish: updatesite
	git push origin
	git push nas

verifysite:
	wget --spider --execute robots=off --no-directories --recursive --span-hosts \
		--page-requisites --domains=tactical-grace.net https://$(HOST) 2>&1 \
		| tee /tmp/log.$(shell date +'%Y%m%d%H%M') \
		| grep 'response... ' | sort | uniq -c
