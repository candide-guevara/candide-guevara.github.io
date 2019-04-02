#! /bin/bash
## Simple routines used for blog development

CLEANER='svgcleaner'

## *USAGE: serve_localhost
## Starts the jekyll server from current dir
serve_localhost() {
  jekyll serve --destination /tmp/blog --watch --drafts --unpublished
}

if which "$CLEANER"; then

## *USAGE: clean_svg [SVG_LIST]
## Removes bloating in svg created by inkscape
clean_svg() {
  for ff in "$@"; do
    local tempname=`mktemp --suffix=.svg --dry-run -p . -u`
    svgcleaner \
      --coordinates-precision 2 \
      --properties-precision 2 \
      --transforms-precision 2 \
      --paths-coordinates-precision 2 \
      --apply-transform-to-paths yes \
      --join-style-attributes all \
      --multipass \
      "$ff" "$tempname"
    sed -r -i 's/ ?style=""//g' "$tempname"
    if [[ "$?" == 0 ]] && [[ -f "$tempname" ]]; then 
      mv "$tempname" "$ff"
    fi
  done
}

## *USAGE: clean_all
## Removes bloating in all blog svg created by inkscape
clean_all_svg() {
  ( \
  export -f clean_svg ;\
  find . -iname '*.svg' -print0 \
    | xargs --null --max-args=5 --max-procs=4 \
      bash --norc --noprofile -c 'clean_svg "$@"' ;\
  )
}

## *USAGE: change_color [COLOR_SRC] [COLOR_DST]
## Scans blog and swaps color in svg (format like #888a85)
change_color() {
  find . -iname '*.svg' -print0 \
    | xargs --null --max-args=5 --max-procs=4 \
      sed -r -i "s/fill:$1/fill:$2/g"
}

else
  echo "[ERROR] ($CLEANER) is not installed"
fi

