# Reads a feed of newest photos from Google Photos, outputs yaml data for the
# gallery. Can run wherever, expects the feed on stdin.
#
# gcu-gallery 12 < feedfile
#
gcu-gallery() {
echo '  photos:'
  grep -Eo "https?://lh.\.googleusercontent.com/[^']+/s144/[^']+" - | head -${1} | sed -E '
s#/s144/#/s1920/#
s/https?://
s/^/  - href: /
' | tail -r
}

# Extracts Google Photos urls from files, creates per date lists of URLs. Must
# run in photos/, expects kit files as arguments.
#
# gcu-make-list ../kits/hg/exia.yaml
#
gcu-make-list() {
  foreach file ("$@") {
    local new_content=$(git diff --cached -U0 ${file})
    local day=$(echo "${new_content}" | grep 'date: ' | grep -Eo '\d\d\d\d-\d\d-\d\d')
    mkdir -p ${day}
    echo "${new_content}" | grep -Eo '//lh[0-9]\.googleusercontent.+/s1920/[^"]+' | sort -u | sed 's/^/http:/' >> ${day}/urllist
    echo ${day}
  }
}

# Given a list of photos, fetches all needed variants of it. Must run in
# photo/, expects dir names (YYYY-MM-DD) as arguments.
#
# gcu-fetch-day 2016-12-26
#
gcu-fetch-day() {
  foreach day ("$@") {
    local photodir=$(pwd)
    local daydir=${photodir}/${day}
    foreach dir (s1920 s400-p) {
      cd ${daydir}
      mkdir -p ${dir}
      cd ${dir}
      sed "s#/s1920/#/${dir}/#" ../urllist | xargs -- curl -s --remote-name-all
    }
    cd ${photodir}
  }
}

# Syncs photos to serving site. Must run in photo/, must have photos for *all*
# days already fetched (as it runs 'rsync --delete').
#
# gcu-sync-photos -n
#
gcu-sync-photos() {
  rsync --exclude .htaccess --exclude .gitignore --delete -airz $* . inferno.hell.pl:/srv/web/syn.tactical-grace.net/c/
}

# Rewrites image links in kit files from Google Photos to serving site.
# Can run wherever, expects kit files as arguments.
#
# gcu-rewrite-links ../kits/hg/exia.yaml
#
gcu-rewrite-links() {
  local base='//syn.tactical-grace.net/c/'
  foreach file ("$*") {
    local day=$(git diff --cached -U0 ${file} | grep 'date: ' | grep -Eo '\d\d\d\d-\d\d-\d\d')
    local new_parent=${base}${day}
    perl -i -lpe 's#//lh[0-9]\.googleusercontent.+(?=/s[0-9]+[^/]+/)#'${new_parent}'#' ${file}
  }
}

# Convenience function for new entries: extracts list of photos, fetches them
# and edits the links. Doesn't sync the photos to the serving site.
#
# gcu-process-photos ../kits/hg/exia.yaml
gcu-process-photos() {
  foreach file ("$@") {
    local day=$(gcu-make-list ${file})
    ls -l ${day}
    gcu-fetch-day ${day}
    find ${day}
    gcu-rewrite-links ${file}
  }
}
