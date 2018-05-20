scriptencoding utf-8
let s:Config = vital#doctest#import('Config')

function! doctest#call(...) abort
  if get(w:, 'doctest_promise', v:null) isnot# v:null
    return
  endif
  let winid = win_getid()
  let spinner = doctest#spinner#new({
        \ 'frames': g:doctest#animation_frames,
        \ 'prefix': 'Doctest is running ',
        \})
  let promise = call('doctest#runner#start', [expand('%')] + a:000)
        \.then(funcref('s:on_then', [winid]))
        \.catch(funcref('s:on_catch'))
        \.finally(funcref('s:on_finally', [winid, spinner]))
  let w:doctest_promise = promise
  call spinner.start()
endfunction

function! doctest#complete(arglead, cmdline, cursorpos) abort
  let options = [
        \ '-oDONT_ACCEPT_TRUE_FOR_1',
        \ '-oDONT_ACCEPT_BLANKLINE',
        \ '-oNORMALIZE_WHITESPACE',
        \ '-oELLIPSIS',
        \ '-oIGNORE_EXCEPTION_DETAIL',
        \ '-oSKIP',
        \ '-oREPORT_ONLY_FIRST_FAILURE',
        \ '-oFAIL_FAST',
        \]
  return filter(options, { _, v -> v =~# '^' . a:arglead })
endfunction


function! s:on_then(winid, items) abort
  let winid_saved = win_getid()
  try
    " Temporary focus the target window if that is in the current tabpage
    if win_id2win(a:winid) > 0
      call win_gotoid(a:winid)
    endif
    doautocmd QuickFixCmdPre lDoctest
    let items = map(
          \ copy(a:items),
          \ {k, v -> {
          \   'filename': v.file,
          \   'lnum': v.line,
          \   'text': v.summary,
          \ }}
          \)
    call setloclist(a:winid, items)
    call setloclist(a:winid, [], 'r', {
          \ 'title': 'doctest',
          \ 'context': a:items,
          \})
    doautocmd QuickFixCmdPost lDoctest
  finally
    " Restore window focus when the thread become relaxed
    if win_getid() != winid_saved
      call timer_start(0, { -> win_gotoid(winid_saved) })
    endif
  endtry
endfunction

function! s:on_catch(value) abort
  call doctest#console#error(a:value)
endfunction

function! s:on_finally(winid, spinner) abort
  call setwinvar(a:winid, 'doctest_promise', v:null)
  call a:spinner.stop()
endfunction


augroup doctest_internal
  autocmd! *
  autocmd QuickFixCmdPre lDoctest :
  autocmd QuickFixCmdPost lDoctest :
augroup END

if $LANG ==# 'C'
  let s:frames = split('..... o.... .o... ..o.. ...o. ....o')
else
  let s:frames = split('○○○○○ ●○○○○ ○●○○○ ○○●○○ ○○○●○ ○○○○●')
endif

call s:Config.config(expand('<sfile>'), {
      \ 'animation_frames': s:frames,
      \})
