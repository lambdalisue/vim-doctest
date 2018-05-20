scriptencoding utf-8

let s:t_string = type('')

if $LANG ==# 'C'
  let s:frames = split('v<^>', '\zs')
else
  let s:frames = split('⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏', '\zs')
endif

function! doctest#spinner#new(...) abort
  let spinner = extend({
        \ 'prefix': '',
        \ 'suffix': ' ',
        \ 'index': 0,
        \ 'frames': s:frames,
        \ 'winid': win_getid(),
        \ 'statusline': &l:statusline,
        \}, a:0 ? a:1 : {},
        \)
  let spinner.timer = v:null
  let spinner.next = funcref('s:spinner_next')
  let spinner.update = funcref('s:spinner_update')
  let spinner.restore = funcref('s:spinner_restore')
  let spinner.start = funcref('s:spinner_start')
  let spinner.stop = funcref('s:spinner_stop')
  return spinner
endfunction


function! s:spinner_next() abort dict
  let self.index += 1
  let self.index = self.index % len(self.frames)
  return self.frames[self.index]
endfunction

function! s:spinner_update() abort dict
  " Skip if winid does not exist in the current tabpage
  if win_id2win(self.winid) is# 0
    return
  endif
  call setwinvar(
        \ self.winid,
        \ '&statusline',
        \ self.prefix . self.next() . self.suffix,
        \)
  redrawstatus!
endfunction

function! s:spinner_restore() abort dict
  call setwinvar(
        \ self.winid,
        \ '&statusline',
        \ self.statusline,
        \)
  redrawstatus!
endfunction

function! s:spinner_start(...) abort dict
  let interval = a:0 ? a:1 : 100
  if self.timer isnot# v:null
    call self.stop()
  endif
  let self.timer = timer_start(
        \ interval,
        \ { -> self.update() },
        \ { 'repeat': -1 },
        \)
endfunction

function! s:spinner_stop() abort dict
  if self.timer isnot# v:null
    call self.restore()
    call timer_stop(self.timer)
    let self.tiemr = v:null
  endif
endfunction
