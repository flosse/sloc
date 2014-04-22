alignRight = (string='', width=0) ->

  unless typeof string is 'string' and typeof width is 'number' and width >= 0
    return ''

  if string.length >= width
    string.slice -width
  else
    Array(width - string.length + 1).join(' ') + string

module.exports = alignRight: alignRight
