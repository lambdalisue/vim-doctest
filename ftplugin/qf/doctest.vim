function! s:show_detail() abort
  let wininfo = getwininfo(win_getid())[0]
  let info = wininfo.loclist
        \ ? getloclist(0, {'context': 1, 'nr': 0})
        \ : getqflist({'context': 1, 'nr': 0})
  let line = line('.')
  let item = get(info.context, line - 1, v:null)
  try
    if item is# v:null
      throw printf(
            \ 'doctest: No corresponding item of line %d exists',
            \ line,
            \)
    endif
    call doctest#viewer#open(
          \ printf('doctest://detail:%d:%d', info.nr, line),
          \ item.content,
          \)
  catch /^doctest:/
    call doctest#console#error(matchstr(
          \ v:exception,
          \ '^doctest: \zs.*',
          \))
  endtry
endfunction

nnoremap <buffer><silent> <Plug>(doctest-show-detail)
      \ :<C-u>call <SID>show_detail()<CR>

if !hasmapto('<Plug>(doctest-show-detail)', 'n') && mapcheck('p', 'n') ==# ''
  nmap <buffer> p <Plug>(doctest-show-detail)
endif
