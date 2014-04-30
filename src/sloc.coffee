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

whiteSpaceLine = ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    $       # end of the line
  ///

sharpComment = ///
    \#{1}   # exactly one sharp character
    [^      # not followed by
    \#]{2}  # two sharp characters
  ///

doubleSlashComment = new RegExp ///
    /{2}    # exactly two slash
  ///

doubleHyphenComment = new RegExp ///
    -{2}    # exactly two hypens
  ///

doubleSquareBracketOpen = new RegExp ///
    \[{2}   # exactly two open square brackets
  ///

doubleSquareBracketClose = new RegExp ///
    \]{2}   # exactly two open square brackets
  ///

trippleSharpComment = new RegExp ///
    \#{3}   # exactly 3 sharp character
  ///

slashStarComment = new RegExp ///
    /       # slash character
    \*+     # one or more stars
  ///

starSlashComment = new RegExp ///
    \*      # one star characters
    /{1}    # slash character
  ///

trippleQuoteComment = new RegExp ///
    \"{3}   # exactly three quote characters
    |       # or
    \'{3}   # exactly three single quote characters
  ///

combine = (r1, r2, type='|') ->
  new RegExp r1.toString()[1...-1] + type + r2.toString()[1...-1]

startHtmlComment = new RegExp ///
    <!--    # html start comment
  ///

stopHtmlComment = new RegExp ///
    -->     # html stop comment
  ///

getEmptyLinesCount = (lines) ->
  (i for l,i in lines when whiteSpaceLine.test l).length

getMatches = (line, regex) ->

  exec = (r) ->
    return [] unless r?
    l = line
    while (m = l.match r)?
      l = l.substring m.index+m[0].length
      m

  start  : exec regex.startBlock
  stop   : exec regex.stopBlock
  single : exec regex.single

countComments = (lines, regex) ->

  blocks      = []
  single      = []
  mixed       = []
  start       = null
  whiteSpaces = /[^\s]/


  checkForMixedLine = (l, match, idx) ->
    if (l.substring(0, match.index).match whiteSpaces)?
      mixed.push {start: idx, stop: idx }

  handleSingle = (l, m, idx) ->
    single.push {start: idx, stop: idx }
    checkForMixedLine l, m.single[0], idx

  handleStart = (l, m, idx) ->
    start = idx
    checkForMixedLine l, m.start[0], idx
    checkLine l.substring(m.start[0].index+m.start[0][0].length), idx

  handleStop = (l, m, idx) ->
    blocks.push {start, stop: idx }
    start = null
    checkLine l.substring(m.stop[0].index+m.stop[0][0].length), idx, idx

  checkLine  = (l, idx, lastComment) ->

    return if l is ''

    m           = getMatches l, regex
    singleMatch = m.single?[0]
    startMatch  = m.start?[0]
    stopMatch   = m.stop?[0]

    if not start?
      if singleMatch and startMatch
        if startMatch.index <= singleMatch.index
          handleStart l, m, idx
        else
          handleSingle l, m, idx

      else if singleMatch
        handleSingle l, m, idx

      else if startMatch
        handleStart l, m, idx

      else if l.match(whiteSpaces)? and idx is lastComment
         mixed.push {start: idx, stop: idx }

    else if start? and stopMatch
      handleStop l, m, idx

  checkLine l,idx for l, idx in lines

  lineSum = (comments) ->
    sum = 0
    for c,i in comments
      d = (c.stop - c.start) + 1
      d-- if comments[i+1]?.start is c.stop
      sum += d
    sum

  cloc = 0
  for b, i in blocks
    d = (b.stop - b.start) + 1
    if (s for s in single when s.start is b.start or s.start is b.stop).length > 0
      d -= 3
    cloc += d

  slen = lineSum single
  cloc += slen

  scloc: slen
  mcloc: lineSum blocks
  mxloc: lineSum mixed
  cloc:  cloc

getCommentExpressions = (lang) ->

  # single line comments
  single =
    switch lang

      when "coffeescript", "coffee", "python", "py"
        sharpComment
      when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "scss", "less", "styl", "stylus"
        doubleSlashComment
      when "css"
        null
      when "html"
        null
      when "lua"
        doubleHyphenComment
      when "erl"
        /\%/
      else
        doubleSlashComment

  ## block comments
  switch lang

    when "coffeescript", "coffee"
      startBlock = trippleSharpComment
      stopBlock  = trippleSharpComment

    when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "css", "scss", "less", "styl", "stylus"
      startBlock = slashStarComment
      stopBlock  = starSlashComment

    when "python", "py"
      startBlock = trippleQuoteComment
      stopBlock  = trippleQuoteComment

    when "html"
      startBlock = startHtmlComment
      stopBlock  = stopHtmlComment

    when "lua"
      startBlock = combine doubleHyphenComment, doubleSquareBracketOpen , ''
      stopBlock  = combine doubleHyphenComment, doubleSquareBracketClose, ''

    when "erl"
      startBlock = null
      stopBlock  = null

    else
      throw new TypeError "File extension '#{lang}' is not supported"

  { startBlock, stopBlock, single }

slocModule = (code, lang) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  lines = code.split '\n'
  loc   = lines.length
  nloc  = getEmptyLinesCount lines

  { scloc, mcloc, mxloc, cloc } = countComments lines, getCommentExpressions lang

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
if define?.amd?
  define -> slocModule

# Node.js support
else if module?.exports?
  module.exports = slocModule

# Browser support
else if window?
  window.sloc = slocModule
