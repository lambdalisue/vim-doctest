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
  let head = match(a:content, '^\w', index, 2)
  let tail = match(a:content, '^\*\{70\}', head)
  let content = a:content[head : tail - 1]

  if match(content, '^Expected:$') > -1
    let b = match(content, '^\w', 0, 2)
    let c = match(content, '^\w', 0, 3)
    let exp = content[b : c-1]
    let got = content[c :]
    let type = 'fail'
    let summary = printf(
          \ 'Fail: %s',
          \ s:summarize(exp, got),
          \)
  else
    let type = 'error'
    let summary = printf(
          \ 'Error: %s',
          \ matchstr(content[-1], '^\s\+\zs.*'),
          \)
  endif
  let item = {
        \ 'file': file,
        \ 'line': line,
        \ 'type': type,
        \ 'summary': summary,
        \ 'content': content,
        \}
  return [index+1, item]
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
