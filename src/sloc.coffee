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

      when "coffee", "py", "ls", "nix", "r", "rb", "jl", "pl", "yaml", "hr"
        /\#/
      when "js", "c", "cc", "cpp", "cs", "h", "hpp", "hx", "ino", "java", \
           "php", "php5", "go", "groovy", "scss", "less", "rs", "styl", \
            "scala", "swift", "ts"
        /\/{2}/
      when "lua", "hs"
        /--/
      when "erl"
        /\%/
      when "monkey", "vb"
        /'/
      when "rkt", "clj", "cljs", "hy"
        /;/
      else null

  ## block comments
  switch lang

    when "coffee"
      start = stop = /\#{3}/

    when "js", "c", "cc", "cpp", "cs", "h", "hpp", "hx", "ino", "java", "ls", \
         "nix", "php", "php5", "go", "groovy", "css", "scss", "less", "rs", \
         "styl", "scala", "ts"
      start = /\/\*+/
      stop  = /\*\/{1}/

    when "python", "py"
      start = stop = /\"{3}|\'{3}/

    when "handlebars", "hbs", "mustache"
      start = /\{\{\!/
      stop = /\}\}/

    when "hs"
      start = /\{-/
      stop  = /-\}/

    when "html", "htm", "svg", "xml"
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

    else
      if lang in extensions then start = stop = null
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

matchIdx = (m) -> m.index + m[0].length

emptyLns = (c) -> c.match(emptyLines)?.length or 0

newLns   = (c) -> c.match(newLines)?.length or 0

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

    cStartIdx = matchIdx match
    comment   = code.substring cStartIdx
    lines     = code.substring(0, match.index).split '\n'
    startIdx  = lines.length - 1 + idx
    stop      = getStop comment, type, regex

    unless stop
      res.error = yes
      return res

    empty   = emptyLns code.substring match.index, cStartIdx + matchIdx stop
    comment = comment.substring 0, stop.index
    len     = newLns comment
    splitAt = cStartIdx + comment.length + stop[0].length
    code    = code.substring splitAt

    countMixed res, lines, idx, startIdx, match

    res.last = start: startIdx, stop: startIdx + len, empty: empty
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

slocModule = (code, lang, opt={}) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  code = code.replace /\r\n|\r/g, '\n'
  code = code[0...-1] if code[-1..] is '\n'

  total   = (1 + newLns code) or 1
  empty   = emptyLns code
  res     = countComments code, getCommentExpressions lang
  single  = lineSum res.single
  block   = lineSum res.block
  mixed   = lineSum res.mixed
  comment = block + single
  bIdx    = (b.stop for b in res.block when not (b.stop in _results))
  comment-- for s in res.single when s.start in bIdx
  blockEmpty = 0
  blockEmpty =+ x.empty for x in res.block
  source  = total - comment - empty + blockEmpty + mixed

  console.log res if opt.debug

  # result
  { total, source, comment, single, block, mixed, empty }

extensions = [
  "c"
  "cc"
  "clj"
  "cljs"
  "coffee"
  "cpp"
  "cs"
  "css"
  "erl"
  "go"
  "groovy"
  "h"
  "handlebars", "hbs"
  "hpp"
  "hr"
  "hs"
  "html", "htm"
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
  "mustache"
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
  "svg"
  "swift"
  "ts"
  "vb"
  "xml"
  "yaml"
]

slocModule.extensions = extensions

slocModule.keys = keys

# AMD support
if define?.amd? then define -> slocModule

# Node.js support
else if module?.exports? then module.exports = slocModule

# Browser support
else if window? then window.sloc = slocModule
