"=============================================================================
" Copyright (c) 2013
"
" This file is based on fuf/file.vim
"
"=============================================================================
" LOAD GUARD {{{1

if !l9#guardScriptLoading(expand('<sfile>:p'), 0, 0, [])
  finish
endif

" }}}1
"=============================================================================
" GLOBAL VARIABLES {{{1

call l9#defineVariableDefault('g:fuf_ignore_files', [
      \ '.gitignore',
      \ '.hgignore',
      \ $HOME . '/.gitignore_global' ])

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

" FuzzyFinder
function g:GlobToRegex(glob)
  let glob = a:glob
  " Escape
  let glob = substitute(glob, '^/', '^', '')
  let glob = substitute(glob, '[.~\{\}\[\]]', '\\&', 'g')
  " Convert
  let glob = substitute(glob, '?', '.', 'g')
  let glob = substitute(glob, '\*\*', '.\n', 'g')
  let glob = substitute(glob, '\*', '[^/]*', 'g')
  let glob = substitute(glob, '\n', '*', 'g')
  return glob
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

function fuf#ignore#Update()
  let ignores = []
  let ignorefiles = g:fuf_ignore_files

  if !exists('s:original_file_exclude')
    if exists('g:fuf_file_exclude')
      let s:original_file_exclude = g:fuf_file_exclude
    else
      let s:original_file_exclude = ''
    endif
  endif
  if !empty(s:original_file_exclude)
    call add(ignores, s:original_file_exclude)
  endif

  for ignorefile in ignorefiles
    if filereadable(ignorefile)
      let exType = 'glob'
      for line in readfile(ignorefile)
        if match(line, '^syntax:') == 0
          if match(line, '^syntax:\s*regexp\s*$') == 0
            let exType = 'regex'
          elseif match(line, '^syntax:\s*glob\s*$') == 0
            let exType = 'glob'
          endif
        elseif match(line, '^\s*$') == -1 && match(line, '^#') == -1
          call add(ignores, (exType ==# 'glob' ? g:GlobToRegex(line) : line))
        endif
      endfor
    endif
  endfor

  let g:fuf_file_exclude = join(ignores, '|')
  "let g:fuf_dir_exclude = ignore
  "let g:fuf_coveragefile_exclude = ignore
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
