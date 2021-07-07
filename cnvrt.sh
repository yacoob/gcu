#!/usr/bin/zsh
remarshal=~/workarea/gcu/.venv/bin/remarshal
input_dir=content
output_dir=kits

rmrsh() {
  ${remarshal} -if toml -i $1 -of yaml -p
}

processDir() {
  cd $1
  echo '---'
  rmrsh _index.md | grep -E '(title|cover)'
  echo 'entries:'
  # 🤢 ==> 🤮
  foreach f (2*.md) { rmrsh $f | sed 's/^/  /' | sed '1s/^ /-/'  }
  cd -
}

foreach d (${input_dir}/*/*(/)) {
  processDir $d > ${output_dir}/${d#content/}.yaml
}
