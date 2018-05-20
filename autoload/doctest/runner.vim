let s:Job = vital#doctest#import('System.Job')
let s:Config = vital#doctest#import('Config')
let s:Promise = vital#doctest#import('Async.Promise')

function! doctest#runner#start(filename, ...) abort
  let options = a:0 ? a:1 : []
  let args = [
        \ g:doctest#runner#python,
        \ '-m',
        \ 'doctest',
        \]
  let args += options
  let args += [fnamemodify(a:filename, ':p')]
  return s:Promise.new(funcref('s:resolver', [args]))
endfunction

function! s:on_receive(buffer, data) abort
  let a:buffer[-1] .= a:data[0]
  call extend(a:buffer, a:data[1:])
endfunction

function! s:on_exit(stdout, stderr, resolve, reject, exitval) abort
  if a:exitval is# 0
    call a:resolve([])
  endif
  try
    let items = doctest#parser#parse(a:stdout)
    if empty(items)
      call a:reject(join(a:stderr, "\n"))
    else
      call a:resolve(items)
    endif
  catch
    call a:reject(v:exception)
  endtry
endfunction

function! s:resolver(args, resolve, reject) abort
  let stdout = ['']
  let stderr = ['']
  call s:Job.start(a:args, {
        \ 'on_stdout': funcref('s:on_receive', [stdout]),
        \ 'on_stderr': funcref('s:on_receive', [stderr]),
        \ 'on_exit': funcref(
        \   's:on_exit',
        \   [stdout, stderr, a:resolve, a:reject],
        \ ),
        \})
endfunction


call s:Config.config(expand('<sfile>'), {
      \ 'python': 'python',
      \})
