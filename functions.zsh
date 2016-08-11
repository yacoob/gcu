# Reads a feed of newest photos from Google Photos, outputs markdown code for
# gallery. Can run wherever, expects the feed on stdin.
#
# gcu-gallery 12 < feedfile
#
gcu-gallery() {
  grep -Eo "https?://lh.\.googleusercontent.com/[^']+/s144/[^']+" - | head -${1} | sed -E '
s#/s144/#/s1920/#
s/https?://
s/$/" >}}/
s/^/{{<photo title="" href="/
' | tail -r
}

# Extracts Google Photos urls from files, creates per post lists of URLs. Must
# run in photo/, expects post files as arguments.
#
# gcu-make-list ../posts/2015-11-21.zee.zulu.goes.blub.md
#
gcu-make-list() {
  foreach file ("$@") {
    local day=$(basename ${file} | cut -b 1-10)
    mkdir -p ${day}
    grep -Eo '//lh[0-9]\.googleusercontent.+/s1920/[^"]+' ${file} | sort -u | sed 's/^/http:/' >> ${day}/urllist
    ls -lh ${day}/urllist
  }
}

# Given a list of photos, fetches all needed variants of it. Must run in
# photo/, expects dir names (YYYY-MM-DD) as arguments.
#
# gcu-fetch-day 2015-11-21
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
    find ${daydir}
    cd ${photodir}
  }
}

# Syncs photos to serving site. Must run in photo/, must have photos for *all*
# days already fetched (as it runs 'rsync --delete').
#
# gcu-sync-photos -n
#
gcu-sync-photos() {
  rsync --exclude .htaccess --exclude .gitignore --delete -airz $* . inferno.hell.pl:/srv/blogs/syn.tactical-grace.net/c/
}

# Rewrites image links in post files from Google Photos to serving site.
# Can run wherever, expects post files as arguments, named like this: YYYY-MM-DD.title.md.
#
# gcu-rewrite-links posts/2015-11-21.zee.zulu.goes.blub.md
#
gcu-rewrite-links() {
  local base='//syn.tactical-grace.net/c/'
  foreach file ("$*") {
    local day=$(basename ${file} | cut -b 1-10)
    local new_parent=${base}${day}
    perl -i.orig -lpe 's#//lh[0-9]\.googleusercontent.+(?=/s[0-9]+[^/]+/)#'${new_parent}'#' ${file}
  }
}
