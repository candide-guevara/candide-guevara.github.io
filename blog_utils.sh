#! /bin/bash
## Simple routines used for blog development

CLEANER='svgcleaner'

## *USAGE: blog_serve_localhost
## Starts the jekyll server from current dir
blog_serve_localhost() {
  jekyll serve --destination /tmp/blog --watch --drafts --unpublished
}

if which "$CLEANER"; then

## *USAGE: blog_clean_svg [SVG_LIST]
## Removes bloating in svg created by inkscape
blog_clean_svg() {
  for ff in "$@"; do
    local tempname=`mktemp --suffix=.svg --dry-run -p . -u`
    echo ">>> $ff / $tempname"
    svgcleaner \
      --coordinates-precision 2 \
      --properties-precision 2 \
      --transforms-precision 2 \
      --paths-coordinates-precision 2 \
      --apply-transform-to-paths yes \
      --join-style-attributes all \
      --multipass \
      "$ff" "$tempname" > /dev/null
    if [[ "$?" == 0 ]] && [[ -f "$tempname" ]]; then 
      sed -r -i 's/ ?style=""//g' "$tempname" \
        && sed -r -i 's/></>\n</g' "$tempname" \
        && mv "$tempname" "$ff"
    fi
  done
}

## *USAGE: blog_patch_invalid_color [SVG_LIST]
## Checks invalid numeric representation of colors
blog_patch_invalid_color() {
  for ff in "$@"; do
    local tempname=`mktemp --suffix=.svg --dry-run -p . -u`
    echo ">>> $ff / $tempname"
    sed -r 's/:#0([^0-9a-fA-F])/:#000\1/g' "$ff" > "$tempname"
    if [[ "$?" == 0 ]] && [[ -f "$tempname" ]]; then 
        mv "$tempname" "$ff"
    fi
  done
}

## *USAGE: blog_break_lines [SVG_LIST]
## Insert line breaks at xml element boundaries
blog_break_lines() {
  for ff in "$@"; do
    local tempname=`mktemp --suffix=.svg --dry-run -p . -u`
    echo ">>> $ff / $tempname"
    sed -r 's/></>\n</g' "$ff" > "$tempname"
    if [[ "$?" == 0 ]] && [[ -f "$tempname" ]]; then 
        mv "$tempname" "$ff"
    fi
  done
}

## *USAGE: blog_edit_all_posts [START_WITH]
## Opens all posts on the blog with vim
## START_WITH will skip all files lexicographicaly less than it
blog_edit_all_posts() {
  local -a posts=( `find . -iname '*.md' | sort` )
  local start_with="$1"
  for post in "${posts[@]}"; do
    echo "$post"
    [[ "$start_with" < "$post" ]] || continue
    vim "$post"
    read -p 'continue with next [Y|n] ? ' keepon
    [[ "$keepon" == "n" ]] && return 1
  done
}

## *USAGE: blog_clean_all_svg
## Removes bloating in all blog svg created by inkscape
blog_clean_all_svg() {
  ( \
  export -f blog_clean_svg ;\
  find . -iname '*.svg' -print0 \
    | xargs --null --max-args=5 --max-procs=4 \
      bash --norc --noprofile -c 'blog_clean_svg "$@"' ;\
  )
}

## *USAGE: blog_change_color_all [COLOR_SRC] [COLOR_DST]
## Scans blog and swaps color in svg (format like #888a85)
blog_change_color_all() {
  find . -iname '*.svg' -print0 \
    | xargs --null --max-args=5 --max-procs=4 \
      sed -r -i "s/fill:$1/fill:$2/g"
}

## *USAGE: blog_remove_date_all
## Scans blog and removes date from posts but adds it in front matter
blog_remove_date_all() {
  local -a posts=( `find . -iname '2*.md'` )
  for post in "${posts[@]}"; do
    local postname=`basename "$post"`
    local postdir=`dirname "$post"`
    local ymd_date="${postname%%-[a-z]*}"
    local newpost="0000-00-00-${postname#*-*-*-}"
    local newpath="$postdir/$newpost"

    echo "$post -> $newpath / $ymd_date"
    [[ "${#ymd_date}" == 10 ]] || return 1
    [[ -e "${newpath}" ]] && return 3

    git mv "$post" "$newpath"
    sed -r -i "s/^(title:.*)/\\1\\ndate: $ymd_date/" "$newpath"
  done
}

## *USAGE: blog_remove_diagram_layout_all
## Scans blog and removes layout (just use default)
blog_remove_diagram_layout_all() {
  local -a posts=( `find . -iname '*.md'` )
  for post in "${posts[@]}"; do
    local diag_list=`sed -r -n 's/^(diagram_list|diagram) *: *\[?([^]]*)\]?/\2/p' "$post" | sed -r 's/^ *//'`

    echo ">>> $post -> '$diag_list'"
    sed -r -i '/^layout *:/d' "$post"

    [[ -z "$diag_list" ]] && continue
    local -a diag_tokens=( `echo $diag_list | sed 's/,/ /g'` )
    [[ "${#diag_tokens[@]}" == 0 ]] && return 1
    sed -r -i '/^diagram_list *:|^diagram *:/d' "$post"

    # the abscense of quotes on list expansion is done on purpose to trim spaces
    for token in ${diag_tokens[@]}; do
      echo "$post -> '$token'"
      echo "![$token]({{ site.images }}/$token){:.my-block-wide-img}" >> "$post"
    done
  done
}

## *USAGE: blog_remove_customs_all
## Scans blog and removes deprecated front matter attributes
blog_remove_customs_all() {
  local -a posts=( `find . -iname '*.md'` )
  for post in "${posts[@]}"; do
    echo "$post"
    sed -i -r -e '/^css_custom *:/d' \
      -e 's/^js_custom *: *(.*)/my_extra_options: [ \1 ]/' "$post"
  done
}

## *USAGE: blog_change_categories_all
## Scans blog and changes post categories
blog_change_categories_all() {
  local -a posts=( `find . -iname '*.md'` )
  for post in "${posts[@]}"; do
    echo "$post"
    sed -i -r -e 's/^categories *:(.*)diagram/categories:\1cs_related/' \
      -e 's/^categories *:(.*)article/categories:\1cs_related/' \
      -e 's/^categories *:(.*)fun/categories:\1misc/' "$post"
  done
}

else
  echo "[ERROR] ($CLEANER) is not installed"
fi

