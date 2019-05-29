# Helper variable.
GCU_ROOT_DIR=$(git rev-parse --show-toplevel)
PHOTO_DIR=${GCU_ROOT_DIR}/static/photos

# Generate YAML bit for last N photos.
gcu-gallery() {
  local prefix='gcu-'
  local last=${$(basename $(ls ${PHOTO_DIR}/full | tail -1))%.*}
  last=${last#${prefix}}
  echo '  photos:'
  foreach n ($(seq -f %05g $(($last - ${1} + 1)) ${last})) {
    echo "  - href: /photos/full/${prefix}${n}.jpg"
  }
}

# Update thumbnails for selected photos.
gcu-update-thumbs() {
  local -a list
  local photos=(${PHOTO_DIR}/full/*jpg)
  if [[ "${1}" =~ "[0-9]+" ]] {
    list=($photos[-${1},-1])
  } elif [[ "${1}" == "-f" ]] {
    list=(${photos})
  } else {
    foreach file ($photos[@]) {
      local sn=$(basename ${file})
      if [[ ${file} -nt ${PHOTO_DIR}/thumb/${sn} ]] {
        list+=${file}
      }
    }
  }
  foreach file ($list[@]) {
    local thumbfile=${PHOTO_DIR}/thumb/$(basename ${file})
    pipenv run smartcroppy --width 400 --height 400 ${file} ${thumbfile} && ls -l ${thumbfile}
  }
  chmod -R a+rX ${PHOTO_DIR}
}

# Convenience function.
gcu-process-photos() {
  if [[ "${1}" =~ "[0-9]+" ]] {
    gcu-gallery ${1}
    gcu-update-thumbs ${1}
  }
}
