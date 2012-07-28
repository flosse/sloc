###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

whiteSpaceLine = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    $       # end of the line
  ///

sharpComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    \#      # sharp character
  ///

slashComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    /       # slash character
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
    \*+     # followed by one or more stars
  ///

starSlashComment = new RegExp ///
    ^       # beginning of the line
    \s*     # zero or more spaces
    \*+     # one or ore star characters
    /{1}    # followed by one slash character
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

module.exports = (code, lang) ->

  throw new TypeError "'code' has to be a string" unless typeof code is "string"

  switch lang

    when "coffeescript", "coffee"

      startMultiLineComment = trippleSharpComment
      stopMultiLineComment  = trippleSharpComment
      comment               = sharpComment

    when "javascript", "js"

      startMultiLineComment = slashStarComment
      stopMultiLineComment  = starSlashComment
      comment               = slashComment

    when "python", "py"
      comment               = sharpComment
      startMultiLineComment = trippleQuoteComment
      stopMultiLineComment  = trippleQuoteComment

    else
      startMultiLineComment = slashStarComment
      stopMultiLineComment  = starSlashComment
      comment               = slashComment

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

    if startMultiLineComment.test(l)    and start is false
      start = true
      startLine = i

    else if stopMultiLineComment.test(l) and start is true
      start = false
      x = i - startLine + 1
      commentLineNumbers.push nr for nr in [startLine..i]
      bCounter += x

    else if comment.test l
      cCounter++
      commentLineNumbers.push i

  cCounter += bCounter
  sloc      = loc - cCounter - nloc

  # result
  loc:    loc        # physical lines of code
  sloc:   sloc       # source loc
  cloc:   cCounter   # comment loc
  bcloc:  bCounter   # block comment loc
  nloc:   nloc       # null loc
