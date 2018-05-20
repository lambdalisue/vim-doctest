let s:THRESHOLD = 40

function! doctest#parser#parse(content) abort
  let next = 0
  let items = []
  while 1
    let [next, item] = s:parse_next(a:content, next)
    if next is# -1
      return items
    endif
    call add(items, item)
  endwhile
endfunction


function! s:parse_next(content, start) abort
  let index = match(a:content, '^File\>', a:start)
  if index is# -1
    return [-1, {}]
  endif
  let m = matchlist(
        \ a:content[index],
        \ '^File "\(.*\)", line \(\d\+\)',
        \)
  let file = m[1]
  let line = m[2] + 0
  let [index, exp] = s:parse_exp(a:content, index)
  let [index, got] = s:parse_got(a:content, index)
  let item = {
        \ 'file': file,
        \ 'line': line,
        \ 'summary': s:summarize(exp, got),
        \ 'content': exp + [''] + got,
        \}
  return [index+1, item]
endfunction

function! s:parse_exp(content, start) abort
  let s = match(a:content, '^Expected:', a:start)
  let e = match(a:content, '^Got:', s)
  return [e-1, a:content[s : e-1]]
endfunction

function! s:parse_got(content, start) abort
  let s = match(a:content, '^Got:', a:start)
  let e = match(a:content, '^\*\{70\}', s)
  return [e-1, a:content[s : e-1]]
endfunction

function! s:summarize(exp, got) abort
  let es = len(a:exp) > 2
  let gs = len(a:got) > 2
  let lhs = (es ? '...' : '') . matchstr(a:exp[-1], '^\s\{4\}\zs.*')
  let lhs = len(lhs) > s:THRESHOLD ? lhs[:s:THRESHOLD] . '...' : lhs
  let rhs = (gs ? '...' : '') . matchstr(a:got[-1], '^\s\{4\}\zs.*')
  let rhs = len(rhs) > s:THRESHOLD ? rhs[:s:THRESHOLD] . '...' : rhs
  return printf(
        \ '%s != %s',
        \ lhs, rhs,
        \)
endfunction
