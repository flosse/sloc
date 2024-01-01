###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2023 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

keys = [
  'total'      # physical lines of code
  'source'     # lines of source
  'comment'    # lines with comments
  'single'     # lines with single-line comments
  'block'      # lines with block comments
  'mixed'      # lines mixed up with source and comments
  'blockEmpty' # empty lines with a block comment
  'empty'      # empty lines
  'todo'
  ]

nonEmpty    = /[^\s]/
endOfLine   = /$/m
newLines    = /\n/g
emptyLines  = /^\s*$/mg
todoLines   = /^.*TODO.*$/mg

getCommentExpressions = (lang) ->

  # single line comments
  single =
    switch lang

      when "coffee", "iced"
        /\#[^\{]/ # hashtag not followed by opening curly brace
      when "cr", "py", "ls", "mochi", "nix", "r", \
           "rb", "jl", "pl", "prql", "yaml", "hr", "rpy"
        /\#/
      when "js", "jsx", "mjs", "c", "cc", "cpp", "cs", "cxx", "h", "m", "mm", \
           "hpp", "hx", "hxx", "ino", "java", "php", "php5", "go", "groovy", \
           "scss", "less", "rs", "sass", "styl", "scala", "swift", "ts", \
           "jade", "pug", "gs", "nut", "kt", "kts", "tsx", \
           "fs", "fsi", "fsx", "bsl", "dart"
        /\/{2}/

      when "latex", "tex", "sty", "cls"
        start = /\%/
      when "agda", "lua", "hs", "sql"
        /--/
      when "erl"
        /\%/
      when "brs", "monkey", "vb"
        /'/
      when "nim"
        r =
          ///
          (?:           # non-capturing group
            ^           # start of line
            [^\#]*      # any char but '#'
          )
          (             # start group
            \#          # exact one '#'
          )
          (?:           # non-capturing group
            (?!         # negative lookahead
              [\#\!]    # any char but '#' and '!'
            )
          )
          ///
        r._matchGroup_ = 1 # dirty fix
        r
      when "rkt", "clj", "cljs", "hy", "asm"
        /;/
      when "ly", "ily"
        start = /%/
      when "f90", "f95", "f03", "f08", "f18"
        /\!/
      else null

  ## block comments
  switch lang

    when "coffee", "iced"
      start = stop = /\#{3}/

    when "js", "jsx", "mjs", "c", "cc", "cpp", "cs", "cxx", "h", "m", "mm", \
         "hpp", "hx", "hxx", "ino", "java", "ls", "nix", "php", "php5", \
         "go", "css", "sass", "scss", "less", "rs", "styl", "scala", "ts", \
         "gs", "groovy", "nut", "kt", "kts", "tsx", "sql", "dart"
      start = /\/\*+/
      stop  = /\*\/{1}/

    when "python", "py", "rpy"
      start = stop = /\"{3}|\'{3}/

    when "handlebars", "hbs", "mustache"
      start = /\{\{\!/
      stop = /\}\}/

    when "hs", "agda"
      start = /\{-/
      stop  = /-\}/

    when "html", "htm", "svg", "xml", "vue"
      start = /<\!--/
      stop  = /-->/

    when "lua"
      start = /--\[{2}/
      stop  = /--\]{2}/

    when "monkey"
      start = /#rem/i
      stop  = /#end/i

    when "nim"
      # nim has no real block comments but doc comments so we distinguish
      # between single line comments and doc comments
      start = /\#{2}/
      # stop is end of line
    when "rb"
      start = /\=begin/
      stop  = /\=end/

    when "rkt"
      start = /#\|/
      stop  = /\|#/

    when "jl"
      start = /\#\=/
      stop  = /\=\#/

    when "ml", "mli", "fs", "fsi", "fsx"
      start = /\(\*/
      stop  = /\*\)/

    when "ly", "ily"
      start = /%\{/
      stop  = /%\}/

    else
      if lang in extensions then start = stop = null
      else throw new TypeError "File extension '#{lang}' is not supported"

  { start, stop, single }

countMixed = (res, lines, idx, startIdx, match) ->

  if (nonEmpty.exec lines[0]) and (res.last?.stop is idx or startIdx is idx)
    res.mixed.push start: idx, stop: idx
  if match? and nonEmpty.exec lines[-1..][0].substr 0, match.index
    res.mixed.push start: startIdx, stop: startIdx

getStopRegex = (type, regex) ->
  switch type
    when 'single' then endOfLine
    when 'block'  then regex or endOfLine

getType = (single, start) ->
  if      single  and not start   then 'single'
  else if start   and not single  then 'block'
  else
    if start.index <= single.index then 'block' else 'single'

matchIdx = (m) -> m.index + m[0].length

emptyLns = (c) -> c.match(emptyLines)?.length or 0

newLns   = (c) -> c.match(newLines)?.length or 0

todoLns  = (c) -> c.match(todoLines)?.length or 0

indexOfGroup = (match, n) ->
  ix = match.index
  ix+= match[i].length for i in [1..n]
  ix

matchDefinedGroup = (reg, code) ->
  res = reg?.exec code
  # This is dirty but it works ;-)
  if res? and (g = reg?._matchGroup_)?
    res.index = indexOfGroup res, g
    res[0] = res[g]
  res

countComments = (code, regex) ->

  myself = (res, code, idx) ->
    return res if code is ''
    if code[0] is '\n' then return -> myself res, code.slice(1), ++idx

    start  = matchDefinedGroup regex.start, code
    single = matchDefinedGroup regex.single, code

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
    stop      = matchDefinedGroup (getStopRegex type, regex.stop), comment

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
  todo    = todoLns code
  bIdx    = (b.stop for b in res.block)
  comment-- for s in res.single when s.start in bIdx
  blockEmpty = 0
  blockEmpty += x.empty for x in res.block
  source  = total - comment - empty + blockEmpty + mixed

  console.log res if opt.debug

  # result
  { total, source, comment, single, block, mixed, empty, todo, blockEmpty }

extensions = [
  "agda"
  "asm"
  "brs"
  "c"
  "cc"
  "clj"
  "cljs"
  "cls"
  "coffee"
  "cpp"
  "cr"
  "cs"
  "css"
  "cxx"
  "dart"
  "erl"
  "f90"
  "f95"
  "f03"
  "f08"
  "f18"
  "fs", "fsi", "fsx"
  "go"
  "groovy"
  "gs"
  "h"
  "handlebars", "hbs"
  "hpp"
  "hr"
  "hs"
  "html", "htm"
  "hx"
  "hxx"
  "hy"
  "iced"
  "ily"
  "ino"
  "jade"
  "java"
  "jl"
  "js"
  "jsx"
  "mjs"
  "kt"
  "kts"
  "latex"
  "less"
  "ly"
  "lua"
  "ls"
  "ml"
  "mli"
  "mochi"
  "monkey"
  "mustache"
  "nix"
  "nim"
  "nut"
  "php", "php5"
  "pl"
  "prql"
  "py"
  "r"
  "rb"
  "rkt"
  "rpy"
  "rs"
  "sass"
  "scala"
  "scss"
  "sty"
  "styl"
  "svg"
  "sql"
  "swift"
  "tex"
  "ts"
  "tsx"
  "vb"
  "vue"
  "xml"
  "yaml"
  "m"
  "mm"
  "bsl"
]

slocModule.extensions = extensions

slocModule.keys = keys

# AMD support
if define?.amd? then define -> slocModule

# Node.js support
else if module?.exports? then module.exports = slocModule

# Browser support
else if window? then window.sloc = slocModule
