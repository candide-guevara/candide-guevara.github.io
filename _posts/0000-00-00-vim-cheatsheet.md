---
title: Vim, features I appreciate
date: 2015-11-29
categories: [cs_related, vim]
---

## Jumping around
* `CTRL-]` : jump to tag under cursor, also works when browsing help
* `CTRL-O`/`CTRL-I` : jump to previous/next position
* `gf` : open file path under cursor (cf `:he includeexpr`)
* `CTRL-W gf` : open file path under cursor in a new tab, **useful when opening directories**

## Quickfix list
* `:cw`  : opens the quickfix window
* `:cn`/`:cp` : jumps to next/previous error
* `SHIFT-ENTER` : in the quickfix window, jump to the current line match

## [Tags][2]
* `g]` : displays all tags matching word under cursor
* `:ts[elect] /<tag-pattern>` : display all tags matching <tag-pattern>
* `g CTRL-}` : displays all tags matching word under cursor
* `CTRL-W }` : displays symbol defintion in preview window

## Commands
* `!<shell_cmd>` : runs shell command (cf `shellcmdflag` to use an interactive shell)
* `:vim[grep] /<pattern>/ <files>` : internal grep tool (puts results in quickfix)
* `:make <target>` : builds the project and outputs errors to quickfix (plugin to make it [async][4])
* `:%s/<pattern//n>` : count number of occurences of <pattern>
* `:%g/<pattern>/<command>` : execute command on matching lines

## Windows
* `CTRL-W o` : close all windows but the current one
* `CTRL-W q` : close current window
* `CTRL-W SHIFT-T` : move current window to new tab
* `CTRL-W s`/`CTRL-W v` : split window horizontally/vertically

## Recipes
* `:tabnew | r ! <shell_cmd>` : Runs <shell_cmd> and puts its output in a new tab
* `:tabnew | set buftype=nowrite | set syntax=diff | r !git diff` : Shows repo changes in new tab (with highlighting)
* `sil[ent] gr[ep] <options> <pattern> <files>` : use normal gnu grep (cf `grepprg`). Useful for recursive options


# Misc

* `g CTRL-G` : display buffer stats (lines, words ...)
* Set [specific options per folder][3] using local .vimrc
* `"ayiw` : yank (i for inside) word under cursor into register a

### Command mode shortcuts
* `CTRL-R CTRL-W` : paste word under cursor into command line

### Registers
* Do not use numbers or " (default register), they will be overwritten automatically on some cases.
* You can [move registers][1] with `:let @a=@"` (saves the default register to a)

### Ranges
* `%` : all 
* `.` : current line
* `.,$` : from current until end
* `1,.+1` : from the start to the next line after the current one

### Pattern syntax
Depends on `magic` value. Most used features are listed below.

{:.my-table}
|   'magic'   |   'nomagic'  |                                                                    |
|-------------|--------------|--------------------------------------------------------------------|
|   `$,^`     |    `$,^`     | matches end/start of line                                          |
|    `.`      |    `\.`      | matches any character                                              |
|    `*`      |    `\*`      | any number of the previous atom                                    |
|   `\(\)`    |   `\(\)`     | grouping into an atom                                              |
|   `\|`      |    `\|`      | separating alternatives (normal | is used to concatenate commands) |
|   `\{`      |    `{`       | number of pattern occurences                                       |
|`\s,\w,\W,\d`| `\s,\w,\W,\d`| Common character classes                                           |
    
[1]: http://vim.wikia.com/wiki/Comfortable_handling_of_registers    
[2]: http://vim.wikia.com/wiki/Browsing_programs_with_tags
[3]: http://www.ilker.de/specific-vim-settings-per-project.html
[4]: https://github.com/tpope/vim-dispatch

