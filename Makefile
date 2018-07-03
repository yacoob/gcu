HOST:=shin.tactical-grace.net

all: site

clean:
	rm -rf public/*
	find . -iname \*~ | xargs rm -f

site: export GCU_BASE_URL:=https://$(HOST)
site:
	python py/gen.py

serve:
	python py/gen.py serve

updatesite: LFTP_USER:=vLm0A59A@tactical-grace.net
updatesite: LFTP_URI:=ftp://genesis.bgocloud.com
updatesite: export LFTP_PASSWORD:=$(shell /usr/bin/security find-generic-password -s gcuftp -w)
updatesite: clean site
	lftp -c 'set ftp:ssl-force yes; open --env-password -u $(LFTP_USER) $(LFTP_URI) && mirror -c -e -P5 -L -x .DS_Store -x .gitignore -R public /$(HOST)'

publish: updatesite
	git push origin
	git push nas
