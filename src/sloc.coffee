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
  'nloc'    # empty lines
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
      when "js", "c", "cc", "cpp", "h", "hpp", "ino", "java", \
           "php", "php5", "go", "scss", "less", "styl"
        /\/{2}/
      when "lua"
        /--/
      when "erl"
        /\%/
      else null

  ## block comments
  switch lang

    when "coffee"
      start = stop = /\#{3}/

    when "js", "c", "cc", "cpp", "h", "hpp", "ino", "java", \
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

  loc   = 1 + code.match(newLines)?.length or 0
  nloc  = code.match(emptyLines)?.length   or 0
  res   = countComments code, getCommentExpressions lang
  cloc  = countBlock res
  scloc = lineSum res.single
  mcloc = lineSum res.block
  mxloc = lineSum res.mixed
  cloc  = cloc + scloc
  sloc  = loc - scloc - mcloc - nloc + mxloc

  # result
  { loc, sloc, cloc, scloc, mcloc, nloc }

slocModule.extensions = [
  "coffee"
  "py"
  "js"
  "c"
  "cc"
  "cpp"
  "h"
  "hpp"
  "ino"
  "erl"
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
