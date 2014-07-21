alignRight = (string='', width=0) ->

  unless typeof string is 'string' and typeof width is 'number' and width >= 0
    return ''

  if string.length >= width
    string.slice -width
  else
    Array(width - string.length + 1).join(' ') + string

summarize = (fileStats) ->
  sum =
    loc   : 0
    sloc  : 0
    cloc  : 0
    scloc : 0
    mcloc : 0
    nloc  : 0

  fileStats.reduce (a,b) ->
    o = {}
    o[k] = a[k] + (b[k] or 0) for k,v of a
    o

module.exports = { alignRight, summarize }
