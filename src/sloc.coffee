###
This program is distributed under the terms of the MIT license.
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

nonEmpty    = /[^\s]/
endOfLine   = /$/m
newLines    = /\n/g
emptyLines  = /^\s*$/mg

getCommentExpressions = (lang) ->

  # single line comments
  single =
    switch lang

      when "coffee", "py", "ls", "nix", "r", "rb", "jl", "pl"
        /\#/
      when "js", "c", "cc", "cpp", "cs", "h", "hpp", "hx", "ino", "java", "php", \
           "php5", "go", "scss", "less", "rs", "styl", "scala", "swift", "ts"
        /\/{2}/
      when "lua", "hs"
        /--/
      when "erl"
        /\%/
      when "monkey", "vb"
        /'/
      when "rkt", "clj", "hy"
        /;/
      else null

  ## block comments
  switch lang

    when "coffee"
      start = stop = /\#{3}/

    when "js", "c", "cc", "cpp", "cs", "h", "hpp", "hx", "ino", "java", "ls", "nix", \
         "php", "php5", "go", "css", "scss", "less", "rs", "styl", "scala", "ts"
      start = /\/\*+/
      stop  = /\*\/{1}/

    when "python", "py"
      start = stop = /\"{3}|\'{3}/

    when "hs"
      start = /\{-/
      stop  = /-\}/

    when "html"
      start = /<\!--/
      stop  = /-->/

    when "lua"
      start = /--\[{2}/
      stop  = /--\]{2}/

    when "monkey"
      start = /#rem/i
      stop  = /#end/i

    when "rb"
      start = /\=begin/
      stop  = /\=end/

    when "rkt"
      start = /#\|/
      stop  = /\|#/

    when "jl"
      start = /\#\=/
      stop  = /\=\#/

    when "erl", "swift", "vb", "r", "clj", "hy", "pl"
      start = stop = null

    else throw new TypeError "File extension '#{lang}' is not supported"

  { start, stop, single }

countMixed = (res, lines, idx, startIdx, match) ->

  if (nonEmpty.exec lines[0]) and (res.last?.stop is idx or startIdx is idx)
      res.mixed.push start: idx, stop: idx
  if match? and nonEmpty.exec lines[-1..][0].substr 0, match.index
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

  myself = (res, code, idx) ->
    return res if code is ''
    if code[0] is '\n' then return -> myself res, code.slice(1), ++idx

    start  = regex.start?.exec code
    single = regex.single?.exec code

    unless start or single
      countMixed res, code.split('\n'), idx
      return res

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

    countMixed res, lines, idx, startIdx, match

    res.last = start: startIdx, stop: startIdx + len
    res[type].push res.last

    -> myself res, code, startIdx + len

  trampoline myself {single:[], block:[], mixed:[]}, code, 0

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

slocModule = (code, lang) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  code = code.replace /\r/g, ''

  total   = 1 + code.match(newLines)?.length or 0
  empty   = code.match(emptyLines)?.length   or 0
  res     = countComments code, getCommentExpressions lang
  single  = lineSum res.single
  block   = lineSum res.block
  mixed   = lineSum res.mixed
  comment = block + single
  bIdx    = (b.stop for b in res.block when not (b.stop in _results))
  comment-- for s in res.single when s.start in bIdx
  source  = total - comment - empty + mixed

  # result
  { total, source, comment, single, block, mixed, empty }

slocModule.extensions = [
  "c"
  "cc"
  "clj"
  "coffee"
  "cpp"
  "cs"
  "css"
  "erl"
  "go"
  "h"
  "hpp"
  "hs"
  "html"
  "hx"
  "hy"
  "ino"
  "java"
  "jl"
  "js"
  "less"
  "lua"
  "ls"
  "monkey"
  "nix"
  "php", "php5"
  "pl"
  "py"
  "r"
  "rb"
  "rkt"
  "rs"
  "scala"
  "scss"
  "styl"
  "swift"
  "ts"
  "vb"
]

slocModule.keys = keys

# AMD support
if define?.amd? then define -> slocModule

# Node.js support
else if module?.exports? then module.exports = slocModule

# Browser support
else if window? then window.sloc = slocModule
