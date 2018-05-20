if exists('g:loaded_doctest')
  finish
endif
let g:loaded_doctest = 1


command! -nargs=*
      \ -complete=customlist,doctest#complete
      \ Doctest
      \ call doctest#call(split(<q-args>))
