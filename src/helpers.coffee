alignRight = (string='', width=0) ->

  unless typeof string is 'string' and typeof width is 'number' and width >= 0
    return ''

  if string.length >= width
    string.slice -width
  else
    Array(width - string.length + 1).join(' ') + string

summarize = (fileStats) ->

  return {} unless Array.isArray(fileStats) and fileStats.length > 0

  fileStats.reduce (a, b) ->
    o = {}
    for x in [a,b] when x?
      for k,v of x when typeof v is "number"
        o[k] ?= 0
        o[k] += v
    o

module.exports = { alignRight, summarize }
