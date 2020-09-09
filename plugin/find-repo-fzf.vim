" Mostly taken from airblade/vim-rooter

if exists('g:loaded_vim_fzf_repo') || &cp
  finish
endif
let g:loaded_vim_fzf_repo = 1

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

" https://dmerej.info/blog/post/vim-cwd-and-neovim/
" Discusses the tch command in neovim
" and shows some other ways to cd, and issues with stuff

function s:RepoGrep(query, fullscreen)
  let g:repo_dir='/opt/android-src/aos'
  let cmd = 'repo grep --cached --ignore-case  -- '.shellescape(a:query)
  let options = {'dir': g:repo_dir}
  let has_column = 0
  call fzf#vim#grep(cmd, has_column, fzf#vim#with_preview(options), a:fullscreen)
endfunction

command! -nargs=* -bang GRepoGrep call RepoGrep(<q-args>, <bang>0)

function s:RepoFiles(fullscreen)
  let g:repo_dir='/opt/android-src/aos'

  " Gotta find a better solution
  let $FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude out'
  let options = {}
  call fzf#vim#files(g:repo_dir, fzf#vim#with_preview(options), a:fullscreen)
endfunction

command! -nargs=* -bang GRepoFiles call s:RepoFiles(<bang>0)

" vim: set ts=2 sw=2 tw=78 expandtab :
