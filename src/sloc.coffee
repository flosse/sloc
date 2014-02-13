###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

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

combine = (r1, r2) -> new RegExp r1.toString()[1...-1] + '|' + r2.toString()[1...-1]

slocModule = (code, lang) ->

  throw new TypeError "'code' has to be a string" unless typeof code is "string"

  # single line comments
  switch lang

    when "coffeescript", "coffee", "python", "py"
      comment = sharpComment
    when "javascript", "js", "c", "cc", "java", "php", "go", "scss"
      comment = combine doubleSlashComment, singleLineSlashStarComment
    when "css"
      comment = singleLineSlashStarComment
    when "html"
      comment = singleLineHtmlComment
    else
      comment = doubleSlashComment

  ## block comments
  switch lang

    when "coffeescript", "coffee"
      startMultiLineComment = trippleSharpComment
      stopMultiLineComment  = trippleSharpComment

    when "javascript", "js", "c", "cc", "java", "php", "go", "css", "scss"
      startMultiLineComment = slashStarComment
      stopMultiLineComment  = starSlashComment

    when "python", "py"
      startMultiLineComment = trippleQuoteComment
      stopMultiLineComment  = trippleQuoteComment

    when "html"
      startMultiLineComment = startHtmlComment
      stopMultiLineComment = stopHtmlComment

    else
      throw new TypeError "File extension '#{lang}' is not supported"

  commentLineNumbers  = []
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
      commentLineNumbers.push nr for nr in [startLine..i]
      bCounter += x

    else if start is false and comment.test l
      cCounter++
      commentLineNumbers.push i

  sloc      = loc - cCounter - bCounter - nloc
  totalC    = cCounter + bCounter

  # result
  loc:    loc        # physical lines of code
  sloc:   sloc       # source loc
  cloc:   totalC     # total comment loc
  scloc:  cCounter   # single line comments
  mcloc:  bCounter   # multiline comment loc
  nloc:   nloc       # null loc

# AMD support
if define?.amd?
  define -> slocModule

# Browser support
else if window?
  window.sloc = slocModule

# Node.js support
else if module?.exports?
  module.exports = slocModule
