###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

keys = [
  'total'     # physical lines of code
  'source'    # lines of source
  'comment'   # lines with comments
  'single'    # lines with single-line comments
  'block'     # lines with block comments
  'mixed'     # lines mixed up with source and comments
  'empty'     # empty lines
  ]

nonEmptyLine = /[^\s]/
endOfLine    = /$/m
newLines     = /\n/g
emptyLines   = /^\s*$/mg

getCommentExpressions = (lang) ->

  # single line comments
  single =
    switch lang

      when "coffee", "py"
        /\#/
      when "js", "c", "cc", "cpp", "h", "hpp", "hx", "ino", "java", \
           "php", "php5", "go", "scss", "less", "styl"
        /\/{2}/
      when "lua"
        /--/
      when "erl"
        /\%/
      when "monkey"
        /'/
      else null

  ## block comments
  switch lang

    when "coffee"
      start = stop = /\#{3}/

    when "js", "c", "cc", "cpp", "h", "hpp", "hx", "ino", "java", \
          "php", "php5", "go", "css", "scss", "less", "styl"
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

    when "monkey"
      start = /#rem/i
      stop  = /#end/i

    else throw new TypeError "File extension '#{lang}' is not supported"

  { start, stop, single }

countMixed = (lines, match, idx, startIdx, res) ->

  if nonEmptyLine.exec(lines[0]) and idx isnt 0
    res.mixed.push start: idx, stop: idx

  if nonEmptyLine.exec lines[startIdx-idx]
    res.mixed.push start: startIdx, stop: startIdx

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
      res.error = yes
      return res

    comment = comment.substring 0, stop.index
    len     = comment.match(newLines)?.length or 0
    splitAt = cContentIdx + comment.length + stop[0].length
    code    = code.substring splitAt

    countMixed lines, match, idx, startIdx, res
    res[type].push start: startIdx, stop: startIdx + len

    -> myself code, startIdx + len, res

  trampoline myself code, 0, {single:[], block:[], mixed:[]}

trampoline = (next) ->
  next = next() while typeof next is 'function'
  next

lineSum = (comments) ->
  sum = 0
  for c,i in comments
    d = (c.stop - c.start) + 1
    d-- if comments[i+1]?.start is c.stop
    sum += d
  sum

countBlock = (res) ->
  cloc = 0
  for b,i in res.block
    d = (b.stop - b.start) + 1
    for s in res.single when s.start is b.start or s.start is b.stop
      d -= 3
      break
    cloc += d
  cloc

slocModule = (code, lang) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  code = code.replace /\r/g, ''

  total   = 1 + code.match(newLines)?.length or 0
  empty   = code.match(emptyLines)?.length   or 0
  res     = countComments code, getCommentExpressions lang
  comment = countBlock res
  single  = lineSum res.single
  block   = lineSum res.block
  mixed   = lineSum res.mixed
  comment = comment + single
  source  = total - single - block - empty + mixed

  # result
  { total, source, comment, single, block, mixed, empty }

slocModule.extensions = [
  "coffee"
  "py"
  "js"
  "c"
  "cc"
  "cpp"
  "h"
  "hpp"
  "hx"
  "ino"
  "erl"
  "monkey"
  "java"
  "php", "php5"
  "go"
  "lua"
  "scss"
  "less"
  "css"
  "styl",
  "html" ]

slocModule.keys = keys

# AMD support
if define?.amd? then define -> slocModule

# Node.js support
else if module?.exports? then module.exports = slocModule

# Browser support
else if window? then window.sloc = slocModule
