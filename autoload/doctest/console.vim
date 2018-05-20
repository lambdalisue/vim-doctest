let s:Console = vital#doctest#import('Vim.Console')
let s:Console.prefix = '[doctest] '


function! doctest#console#debug(...) abort
  return call(s:Console.debug, a:000, s:Console)
endfunction

function! doctest#console#info(...) abort
  return call(s:Console.info, a:000, s:Console)
endfunction

function! doctest#console#warn(...) abort
  return call(s:Console.warn, a:000, s:Console)
endfunction

function! doctest#console#error(...) abort
  return call(s:Console.error, a:000, s:Console)
endfunction
