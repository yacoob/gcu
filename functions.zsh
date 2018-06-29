# Helper variable.
GCU_ROOT_DIR=$(git rev-parse --show-toplevel)

# Generate YAML bit for last N photos.
gcu-gallery() {
  local prefix='gcu-'
  local last=${$(basename $(ls ${GCU_ROOT_DIR}/photo/full | tail -1))%.*}
  last=${last#${prefix}}
  echo '  photos:'
  foreach n ($(seq -f %05g $(($last - ${1} + 1)) ${last})) {
    echo "  - href: //syn.tactical-grace.net/f/full/${prefix}${n}.jpg"
  }
}

# Update thumbnails for selected photos.
gcu-update-thumbs() {
  local -a list
  local photodir=${GCU_ROOT_DIR}/photo
  local photos=(${photodir}/full/*jpg)
  if [[ "${1}" =~ "[0-9]+" ]] {
    list=($photos[-${1},-1])
  } elif [[ "${1}" == "-f" ]] {
    list=(${photos})
  } else {
    foreach file ($photos[@]) {
      local sn=$(basename ${file})
      if [[ ${file} -nt ${photodir}/thumb/${sn} ]] {
        list+=${file}
      }
    }
  }
  foreach file ($list[@]) {
    local thumbfile=${photodir}/thumb/$(basename ${file})
    smartcroppy --width 400 --height 400 ${file} ${thumbfile} && ls -l ${thumbfile}
  }
  chmod -R a+rX ${photodir}
}

# Sync photo dir to the serving site.
gcu-sync-photos() {
  rsync --exclude .htaccess --exclude .gitignore \
        --delete -airz $* \
        $GCU_ROOT_DIR/photo/ \
        inferno.hell.pl:/srv/web/syn.tactical-grace.net/f/
}

# Convenience function. No sync, though.
gcu-process-photos() {
  if [[ "${1}" =~ "[0-9]+" ]] {
    gcu-gallery ${1}
    gcu-update-thumbs ${1}
    gcu-sync-photos -n
  }
}
