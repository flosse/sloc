global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

sloc = require "../src/sloc"

describe "sloc", ->

  it "sloc should be a function", ->
    (expect typeof sloc).toEqual "function"

  it "should count all lines", ->
    (expect sloc("a\nb\nc").loc).toEqual 3

  it "should count all single line comments", ->
    coffeeCode =
      """
        # a
        source.code() # comment
        # comment
      """
    jsCode =
      """
        // a
        source.code(); //comment
        // comment
      """
    pyCode =
      """
        # a
        source.code(); #comment
        # comment
      """

    (expect sloc(coffeeCode, "coffee").cloc).toEqual 2
    (expect sloc(coffeeCode, "coffee").sloc).toEqual 1
    (expect sloc(jsCode, "js").cloc).toEqual 2
    (expect sloc(jsCode, "js").sloc).toEqual 1
    (expect sloc(pyCode, "py").cloc).toEqual 2
    (expect sloc(pyCode, "py").sloc).toEqual 1

  it "should include block comments", ->
    coffeeCode =
      """
        ###
        block comment
        ###
        source.code() # comment
        # comment
      """
    jsCode =
      """
        /**
        block comment
        */
        source.code() /* comment */
        // comment
        /*
        another block comment
        */
      """
    pyCode = '"""\n block comment\n """\n' +
      'source.code() # comment\n' +
      " '''\n another block comment\n '''"

    (expect sloc(coffeeCode, "coffee").cloc).toEqual  4
    (expect sloc(coffeeCode, "coffee").sloc).toEqual  1
    (expect sloc(coffeeCode, "coffee").bcloc).toEqual 3

    (expect sloc(jsCode,"js").cloc).toEqual  7
    (expect sloc(jsCode,"js").sloc).toEqual  1
    (expect sloc(jsCode,"js").bcloc).toEqual 6

    (expect sloc(pyCode,"py").cloc).toEqual  6
    (expect sloc(pyCode,"py").sloc).toEqual  1
    (expect sloc(pyCode,"py").bcloc).toEqual 6

  it "should count empty lines", ->
    coffeeCode =
      """

        source.code() # comment

        # comment
      """
    (expect sloc(coffeeCode).nloc).toEqual 2
