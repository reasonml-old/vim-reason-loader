" ============================ Vim Reason Loader ===============================


" Most of this implementation was copied from Vim-Plug, which is under MIT
" Just like vim-reason-loader is released under MIT.
" https://github.com/junegunn/vim-plug/blob/master/plug.vim
"
" The main modifications made were the changes to s:glob to not take into
" account wild_ignore, which is really important when loading plugin code from
" a build sandbox. For other differences, search for #Differences in this
" file.



if exists('g:did_vim_reason_loader')
  finish
endif
let g:did_vim_reason_loader = 1



" #Differences from Vim-plug (Changing the name of this variable to not
" collide with actual Vim-Plug).
let g:plugs_vimreasonloader = {}

let s:is_win = has('win32') || has('win64')

if s:is_win
  function! s:rtp(spec)
    return s:path(a:spec.dir . get(a:spec, 'rtp', ''))
  endfunction

  function! s:path(path)
    return s:trim(substitute(a:path, '/', '\', 'g'))
  endfunction

  function! s:dirpath(path)
    return s:path(a:path) . '\'
  endfunction

  function! s:is_local_plug(repo)
    return a:repo =~? '^[a-z]:\|^[%~]'
  endfunction
else
  function! s:rtp(spec)
    return s:dirpath(a:spec.dir . get(a:spec, 'rtp', ''))
  endfunction

  function! s:path(path)
    return s:trim(a:path)
  endfunction

  function! s:dirpath(path)
    return substitute(a:path, '[/\\]*$', '/', '')
  endfunction

  function! s:is_local_plug(repo)
    return a:repo[0] =~ '[/$~]'
  endfunction
endif



function! s:lines(msg)
  return split(a:msg, "[\r\n]")
endfunction



" vim-reason-loader code
" =============
" The following two "if executable" checks are the primary original code for
" this plugin. The majority of the remaining code is simply copied from
" Vim-Plug in order to reuse Vim-Plug's lazy loading code.
if executable('ocamlmerlin')
  " To set the log file and restart:
  let s:ocamlmerlin=substitute(system('which ocamlmerlin'),'ocamlmerlin\n$','','') . "../share/merlin/vim/"
  execute "set rtp+=".s:ocamlmerlin
  let g:syntastic_ocaml_checkers=['merlin']
  let g:plugs_vimreasonloader['merlin'] = {'dir': (s:dirpath(s:ocamlmerlin))}
endif

if executable('refmt')
  let s:reason=substitute(system('which refmt'),'refmt\n$','','') . "../share/reason/editorSupport/VimReason"
  execute "set rtp+=".s:reason
  let g:syntastic_reason_checkers=['merlin']
  let g:plugs_vimreasonloader['VimReason'] = {'dir': (s:dirpath(s:reason))}
endif



function! s:glob(from, pattern)
  " #Differences from Vim-plug
  " First 1 argument: "no suffixes". Ignore wildignore setting. This is important
  " if the directory has node_modules in it and your wildignore includes node_modules.
  " The second arg (0): Says don't return in form of a list
  " The third arg (1): Says follow symlinks
  return s:lines(globpath(a:from, a:pattern, 1, 0, 1))
endfunction


function! s:esc(path)
  return escape(a:path, ' ')
endfunction

function! s:escrtp(path)
  return escape(a:path, ' ,')
endfunction

function! s:err(msg)
  echohl ErrorMsg
  echom '[vim-plug] '.a:msg
  echohl None
endfunction

function! s:doautocmd(...)
  if exists('#'.join(a:000, '#'))
    execute 'doautocmd' ((v:version > 703 || has('patch442')) ? '<nomodeline>' : '') join(a:000)
  endif
endfunction


function! s:dobufread(names)
  for name in a:names
    let path = s:rtp(g:plugs_vimreasonloader[name]).'/**'
    for dir in ['ftdetect', 'ftplugin']
      if len(finddir(dir, path))
        return s:doautocmd('BufRead')
      endif
    endfor
  endfor
endfunction

function! s:source(from, ...)
  let found = 0
  for pattern in a:000
    for vim in s:glob(a:from, pattern)
      execute 'source' s:esc(vim)
      let found = 1
    endfor
  endfor
  return found
endfunction

function! s:lod(names, types, ...)
  " #Differences from Vim-plug (This isn't needed')
  " for name in a:names
  "   call s:remove_triggers(name)
  "   let s:loaded[name] = 1
  " endfor
  " call s:reorg_rtp()

  for name in a:names
    let rtp = s:rtp(g:plugs_vimreasonloader[name])
    for dir in a:types
      call s:source(rtp, dir.'/**/*.vim')
    endfor
    if a:0
      if !s:source(rtp, a:1) && !empty(s:glob(rtp, a:2))
        execute 'runtime' a:1
      endif
      call s:source(rtp, a:2)
    endif
    call s:doautocmd('User', name)
  endfor
endfunction


function! s:load(...)
  if a:0 == 0
    return
  endif
  if !exists('g:plugs_vimreasonloader')
    return s:err('Something went wrong with vim-reason-loader: list of plugins not initialized')
  endif
  let unknowns = filter(copy(a:000), '!has_key(g:plugs_vimreasonloader, v:val)')
  if !empty(unknowns)
    let s = len(unknowns) > 1 ? 's' : ''
    return s:err(printf('Unknown plugin%s: %s', s, join(unknowns, ', ')))
  end
  for name in a:000
    call s:lod([name], ['ftdetect', 'after/ftdetect', 'plugin', 'after/plugin'])
  endfor
  call s:dobufread(a:000)
  return 1
endfunction

call call(function("s:load"), keys(g:plugs_vimreasonloader))
