###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

keys = [
  'loc'    # physical lines of code
  'sloc'   # source loc
  'cloc'   # total comment loc
  'scloc'  # single line comments
  'mcloc'  # multiline comment loc
  'nloc'   # null loc
  ]

whiteSpaceLine = ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    $       # end of the line
  ///

sharpComment = ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    \#      # sharp character
  ///

doubleSlashComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    /{2}    # exactly two slash
  ///

doubleHyphenComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    -{2}    # exactly two hypens
  ///

doubleSquareBracketOpen = new RegExp ///
    \[{2}    # exactly two open square brackets
  ///

doubleSquareBracketClose = new RegExp ///
    \]{2}    # exactly two open square brackets
  ///

trippleSharpComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    \#{3}   # exactly 3 sharp character
  ///

slashStarComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    /       # slash character
    \*+     # one or more stars
    (?!     # start negative lookahead
      .*    # zero or more of any kind
      \*    # start character
      /     # slash character
    )       # end lookahead
    .*      # zero or more of any kind
    $       # end of line
  ///

singleLineSlashStarComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    /       # slash character
    \*+     # one or more stars
    .*      # any or no characters
    \*+     # one or more stars
    /{1}    # exactly one slash character
    \s*     # zero or more spaces
    $       # end of line
  ///

starSlashComment = new RegExp ///
    ^       # beginning of the line
    .*      # any or no characters
    \*      # one star characters
    /{1}    # slash character
    \s*     # zero or more spaces
    $       # end of line
  ///

trippleQuoteComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    (
      \"{3} # exactly three quote characters
      |     # or
      \'{3} # exactly three single quote characters
    )
  ///

combine = (r1, r2, type='|') ->
  new RegExp r1.toString()[1...-1] + type + r2.toString()[1...-1]

singleLineHtmlComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    <!--    # html start comment
    .*      # any or no characters
    -->     # html stop comment
    \s*     # zero or more spaces
    $       # end of line
  ///

startHtmlComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    <!--    # html start comment
    (?!     # start negative lookahead
      .*    # zero or more of any kind
      -->   # html stop comment
    )       # end lookahead
    .*      # zero or more of any kind
    $       # end of line
  ///

stopHtmlComment = new RegExp ///
    -->     # html stop comment
    \s*     # zero or more spaces
    $       # end of line
  ///

getEmptyLinesCount = (lines) ->
  (i for l,i in lines when whiteSpaceLine.test l).length

countComments = (lines, cExpr, l, idx=0, startLine, counter={scloc:0, mcloc:0}) ->

  l ?= lines[idx]

  return counter if idx >= lines.length

  if not startLine? and (m = l.match cExpr.startBlock)?
    startLine = idx
    countComments lines, cExpr, l.substring(m.index+m[0].length), idx, startLine, counter

  else if startLine? is true and (m = l.match cExpr.stopBlock)?
    x = idx - startLine + 1
    counter.mcloc += x
    countComments lines, cExpr, l.substring(m.index+m[0].length), idx, null, counter

  else
    counter.scloc++ if not startLine? and cExpr.single.test l
    countComments lines, cExpr, lines[idx+1], idx+1, startLine, counter

getCommentExpressions = (lang) ->

  # single line comments
  single =
    switch lang

      when "coffeescript", "coffee", "python", "py"
        sharpComment
      when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "scss", "less", "styl", "stylus"
        combine doubleSlashComment, singleLineSlashStarComment
      when "css"
        singleLineSlashStarComment
      when "html"
        singleLineHtmlComment
      when "lua"
        doubleHyphenComment
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

    else
      throw new TypeError "File extension '#{lang}' is not supported"

  { startBlock, stopBlock, single }

slocModule = (code, lang) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  lines = code.split '\n'
  loc   = lines.length
  nloc  = getEmptyLinesCount lines

  { scloc, mcloc } = countComments lines, getCommentExpressions lang

  sloc = loc - scloc - mcloc - nloc
  cloc = scloc + mcloc

  # result
  { loc, sloc, cloc, scloc, mcloc, nloc }

slocModule.extensions = [
  "coffeescript", "coffee"
  "python", "py"
  "javascript", "js"
  "c"
  "cc"
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
