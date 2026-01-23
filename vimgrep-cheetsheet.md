vimgrep
=====

* [Vimcasts on vimgrep](http://vimcasts.org/episodes/search-multiple-files-with-vimgrep/)

* Uses native vim regexes (which are slightly different from the regexes used by grep, ack, ag, etc) so the patterns are the same as with vim's within-file
search patterns.

    You can do a normal within-file search first, then re-use the same pattern to search across files with `//` (see examples below).

* Unlike normal within-file search, vimgrep (or rather, the quickfix list) tells you which match you're on (e.g. `2 of 5`).

    If you want to search within the current file but have this feature, tell vimgrep to search the current file with `%`:

    `:vimgrep /foo/g %`

    (vimgrep doesn't seem to highlight all the matches like normal `/` search does, but you can get this by doing the search with `/` first to make the highlights, then doing `:vimgrep //g %` and using the quickfix list to navigate the results.)

* Like many vim commands it populates the quickfix list with the search results.

* By default it only finds the first match in every file. Add `/g` (see examples below) to find all matches.

* Can be shortened to just `:vim`.

* Can be used in conjunction with vim's arg list (see examples below).

* Ignores files that match vim's `wildignore` setting, and searches files in `suffixes` last.

* Uses vim's `ignorecase` setting (but not `smartcase`).

Simple example - to search three specific files for `foo`:

`:vimgrep /foo/g foo.txt bar.txt gar.txt`

## Specifying which files to search

You can pass a list of specific files like `foo.txt bar.txt gar.txt` to vimgrep but you can also use wildcards and backtick expansion.

### Wildcards

Both `*` (wildcard) and `**` (recursive wildcard, or globstar) work:

`:vimgrep /foo/g *.txt`

`:vimgrep /foo/g **/*.txt`

### Backtick expansion

For example list the files that you want to search in a file called `/tmp/files` then do:

`:vimgrep \`cat /tmp/files\`

Another use for this is to search all tracked files in a git project using `git ls-files`:

`:vimgrep /foo/g \`git ls-files\`

`git ls-files` omits git ignored and untracked files. You could just use [fugitive.vim](https://github.com/tpope/vim-fugitive)'s `:Ggrep` command (calls `git grep`) though.

### Using with the argument list

You can populate vim's argument list first with `:args {FILES}`, perhaps validate the contents of the argument list with `:args`, and then tell vimgrep to search all files in the argument list with `##`:

`:vimgrep /foo/g ##`

This also means that you can reuse the same argument list for multiple searches.

### Using the current search pattern

You can tell vim to search using the current within-file search pattern using `//`. Test a search pattern on the current file and then use it across multiple files with vimgrep:

`:vimgrep //g <FILES>`

Alternatively you can paste the current search pattern into the command line (after `:vimgrep /`) with `Ctrl`+`r`/`.

## Navigating the quickfix list

After running vimgrep you navigate the search results by navigating vim's quickfix list. All the commands for navigating the quickfix list begin with `:c`:

* `:copen` and `:cclose`: open and close the quickfix window.

    In the quickfix window `Enter` jumps to the item under the cursor in the window above the quickfix window (if the file is already open in another window it'll go to that window instead).

    You can also just close the quickfix window with `:q` while it's the active window, like any other window.

    If you keep the quickfix window open (whether the active window or not) and use commands like `:cnext` etc below to move between matches, then you can see the match in the file and the position of the match in the list of matches side-by-side.

    To open the quickfix window in a horizontal rather than vertical split do `:vert copen`.

* `:cnext` and `:cprev`: go to the next and previous match. You can precede this with a count, e.g. `:5cnext`.

    [vim-unimpaired](https://github.com/tpope/vim-unimpaired) adds `]`q` and `[`q` shortcuts for these.

* `:cfirst` and`:clast` go to the first and last match.

    Unimpaired adds `]`Q` and `[`Q` shortcuts for these.

* `:cnfile` and `:cpfile` go to the first or last item **in the next or previous match-containing file**.

* `:cc n` goes to the nth match.

## Recalling previous search results (previous quickfix lists)

Vim remembers the last 10 quickfix lists and you can move between them with `:colder` and `:cnewer` (and you can precede these with a count, e.g. `:5colder`). (Also see `:vimgrepa` below.)

## Per-window vimgrep with lvimgrep

`lvimgrep` is the same as vimgrep but populates the current window's location list with the search results instead of the quickfix list. So you have to use location list commands to navigate through results (e.g. `:lnext` and `:lprev` instead of `:cnext` and `:cprev`). This means you can have multiple across-files searches in play at once, in different windows.

## Append more matches the current match list with vimgrepa

`:vimgrepa` works the same as vimgrep but appends its matches to the end of the existing quickfix list, instead of pushing a new quickfix list.

`:lvimgrepa` does the same but for the location list.

## Alternatives to vimgrep

* [Grepper](https://github.com/mhinz/vim-grepper)
* `:grep`
* Making `:grep` call Ack, or any other program with the `grepprg` and `grepformat` settings
* The [ack.vim](https://github.com/mileszs/ack.vim) plugin. This plugin can be configured to use `ag` (silversearcher) too.
* [fugitive.vim](https://github.com/tpope/vim-fugitive)'s `:Ggrep` command (calls `git grep`)
