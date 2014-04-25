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

slocModule = (code, lang) ->

  unless typeof code is "string"
    throw new TypeError "'code' has to be a string"

  # single line comments
  switch lang

    when "coffeescript", "coffee", "python", "py"
      comment = sharpComment
    when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "scss", "less", "styl", "stylus"
      comment = combine doubleSlashComment, singleLineSlashStarComment
    when "css"
      comment = singleLineSlashStarComment
    when "html"
      comment = singleLineHtmlComment
    when "lua"
      comment = doubleHyphenComment
    else
      comment = doubleSlashComment

  ## block comments
  switch lang

    when "coffeescript", "coffee"
      startMultiLineComment = trippleSharpComment
      stopMultiLineComment  = trippleSharpComment

    when "javascript", "js", "c", "cc", "java", "php", "php5", "go", "css", "scss", "less", "styl", "stylus"
      startMultiLineComment = slashStarComment
      stopMultiLineComment  = starSlashComment

    when "python", "py"
      startMultiLineComment = trippleQuoteComment
      stopMultiLineComment  = trippleQuoteComment

    when "html"
      startMultiLineComment = startHtmlComment
      stopMultiLineComment  = stopHtmlComment

    when "lua"
      startMultiLineComment = combine doubleHyphenComment, doubleSquareBracketOpen , ''
      stopMultiLineComment  = combine doubleHyphenComment, doubleSquareBracketClose, ''

    else
      throw new TypeError "File extension '#{lang}' is not supported"

  nullLineNumbers     = []

  lines = code.split '\n'
  loc   = lines.length
  nloc  = (for l,i in lines when whiteSpaceLine.test l
            nullLineNumbers.push i; l
          ).length

  start               = false
  cCounter            = 0
  bCounter            = 0

  for l,i in lines

    if start is false and startMultiLineComment.test l
      start = true
      startLine = i

    else if start is true and stopMultiLineComment.test l
      start = false
      x = i - startLine + 1
      bCounter += x

    else if start is false and comment.test l
      cCounter++

  sloc      = loc - cCounter - bCounter - nloc
  totalC    = cCounter + bCounter

  # result
  loc:    loc
  sloc:   sloc
  cloc:   totalC
  scloc:  cCounter
  mcloc:  bCounter
  nloc:   nloc

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
  "styl"
  "stylus"
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
