" Mostly taken from airblade/vim-rooter

if !exists('g:repo_dir')
  let g:repo_dir = ''
endif

"
" Returns full path of dir's parent directory.
function! s:parent(dir)
  return fnamemodify(a:dir, ':h')
endfunction

" Returns true if dir contains identifier, false otherwise.
"
" dir        - full path to a directory
" identifier - a file name or a directory name; may be a glob
function! s:has(dir, identifier)
  return !empty(globpath(a:dir, a:identifier, 1))
endfunction

" Returns full path of directory of current file name (which may be a directory).
function! s:current()
  let fn = expand('%:p', 1)
  if g:rooter_resolve_links | let fn = resolve(fn) | endif
  let dir = fnamemodify(fn, ':h')
  if empty(dir) | let dir = getcwd() | endif  " opening vim without a file
  return dir
endfunction

" Returns the root directory or an empty string if no root directory found.
function! s:root()
  let dir = s:current()

  let g:repo_dir = ''
  while 1
    if !empty(globpath(dir, '.repo', 1))
      let g:repo_dir = dir
      break
    endif

    let [current, dir] = [dir, s:parent(dir)]
    if current == dir | break | endif
  endwhile

  return ''
endfunction

command! FindRepo call <SID>root()


command! -nargs=* -bang GRepoGrep
  \ call fzf#vim#grep(
  \   'repo grep --cached --ignore-case  -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

" command! -nargs=* -bang GRepoGrepIW
"    \ call fzf#vim#grep(
"    \   'repo grep --cached --ignore-case -e '.shellescape(expand('<cword>')), 1,
"    \   fzf#vim#with_preview(), <bang>0)

" vim: set ts=2 sw=2 tw=78 expandtab :
