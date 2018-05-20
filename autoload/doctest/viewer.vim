function! doctest#viewer#open(bufname, content, ...) abort
  let options = extend({
        \ 'opener': 'topleft pedit',
        \ 'resize': 'shrink',
        \ 'close': 1,
        \}, a:0 ? a:1 : {},
        \)

  let height_saved = winheight(0)
  let winid = bufwinid(a:bufname)
  if options.close && winid && getwinvar(winid, '&previewwindow')
    pclose
    return 1
  endif

  silent! execute options.opener a:bufname
  silent! wincmd P

  let b:content = a:content
  call s:on_read()

  if options.resize ==# 'shrink' && &previewheight > line('$')
    execute 'resize' (line('$') + 1)
  endif

  silent! wincmd p

  if options.resize ==# 'shrink'
    execute 'resize' height_saved
  endif
endfunction

function! s:on_read() abort
  if !exists('b:initialized')
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nomodeline
    setlocal nobuflisted
    setlocal nolist nospell
    setlocal nowrap nofoldenable
    setlocal foldcolumn=0 colorcolumn=0

    augroup doctest_preview_internal
      autocmd! * <buffer>
      autocmd BufReadCmd <buffer> call s:on_read()
    augroup END
  endif
  let b:initialized = 1

  let modifiable_saved = &modifiable
  setlocal modifiable
  call setline(1, b:content)
  silent! execute printf('%d,$delete _', len(b:content) + 1)
  setlocal nomodified
  let &modifiable = modifiable_saved
endfunction
