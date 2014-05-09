###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

keys = [
  'loc'     # physical lines of code
  'sloc'    # source loc
  'cloc'    # total comment loc
  'scloc'   # single line comments
  'mcloc'   # multiline comment loc
  'nloc'    # null loc
  ]

nonEmptyLine = /[^\s]/
endOfLine    = /$/m
newLines     = /\n/g

countMixed = (lines, match, idx, startIdx, res) ->

  if nonEmptyLine.exec(lines[0]) and idx isnt 0
    res.push {type: 'mixed', start: idx, stop: idx}

  if nonEmptyLine.exec lines[startIdx-idx]
    res.push {type: 'mixed', start: startIdx, stop: startIdx}

getStop = (comment, type, regex) ->
  comment.match switch type
    when 'single' then endOfLine
    when 'block'  then regex.stop

getType = (single, start) ->
  if      single  and not start   then 'single'
  else if start   and not single  then 'block'
  else
    if start.index <= single.index then 'block' else 'single'

countComments = (code, regex) ->

  myself = (code, idx, res) ->
    return res if code is ''

    start  = regex.start?.exec code
    single = regex.single?.exec code

    return res unless start or single

    type = getType single, start

    match = switch type
      when 'single' then single
      when 'block'  then start

    cContentIdx = match.index + match[0].length
    comment     = code.substring cContentIdx
    lines       = code.substring(0, match.index).split '\n'
    startIdx    = lines.length - 1 + idx
    stop        = getStop comment, type, regex

    unless stop
      res.push type:'error', start: idx, stop: idx
      return res

    comment = comment.substring 0, stop.index
    len     = comment.match(newLines)?.length or 0
    splitAt = cContentIdx + comment.length + stop[0].length
    code    = code.substring splitAt

    countMixed lines, match, idx, startIdx, res
    res.push {type, start: startIdx, stop: startIdx + len}

    -> myself code, startIdx + len, res

  trampoline myself code, 0, []

getCommentExpressions = (lang) ->

  # single line comments
  single =
    switch lang

      when "coffeescript", "coffee", "python", "py"
        /\#/
      when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "scss", "less", "styl", "stylus"
        /\/{2}/
      when "lua"
        /--/
      when "erl"
        /\%/
      else null

  ## block comments
  switch lang

    when "coffeescript", "coffee"
      start = stop = /\#{3}/

    when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "css", "scss", "less", "styl", "stylus"
      start = /\/\*+/
      stop  = /\*\/{1}/

    when "python", "py"
      start = stop = /\"{3}|\'{3}/

    when "html"
      start = /<\!--/
      stop  = /-->/

    when "lua"
      start = /--\[{2}/
      stop  = /--\]{2}/

    when "erl"
      start = stop = null

    else throw new TypeError "File extension '#{lang}' is not supported"

  { start, stop, single }

trampoline = (next) ->
  next = next() while typeof next is 'function'
  next

slocModule = (code, lang) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  loc   = 1 + code.match(newLines)?.length or 0
  nloc  = code.match(/^\s*$/mg)?.length or 0

  comments = countComments code, getCommentExpressions lang

  res =
    block  : []
    mixed  : []
    single : []

  res[c.type]?.push c for c in comments

  lineSum = (comments) ->
    sum = 0
    for c,i in comments
      d = (c.stop - c.start) + 1
      d-- if comments[i+1]?.start is c.stop
      sum += d
    sum

  cloc = 0
  for b, i in res.block
    d = (b.stop - b.start) + 1
    if (s for s in res.single when s.start is b.start or s.start is b.stop).length > 0
      d -= 3
    cloc += d

  scloc = lineSum res.single
  cloc += scloc

  mcloc= lineSum res.block
  mxloc= lineSum res.mixed

  sloc = loc - scloc - mcloc - nloc + mxloc

  # result
  { loc, sloc, cloc, scloc, mcloc, nloc }

slocModule.extensions = [
  "coffeescript", "coffee"
  "python", "py"
  "javascript", "js"
  "c"
  "cc"
  "erl"
  "java"
  "php", "php5"
  "go"
  "lua"
  "scss"
  "less"
  "css"
  "styl", "stylus"
  "html" ]

slocModule.keys = keys

# AMD support
if define?.amd? then define -> slocModule

# Node.js support
else if module?.exports? then module.exports = slocModule

# Browser support
else if window? then window.sloc = slocModule
