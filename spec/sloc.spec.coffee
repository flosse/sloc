global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

sloc = require "../src/sloc"

describe "sloc", ->

  it "sloc should be a function", ->
    (expect typeof sloc).toEqual "function"

  it "should count all lines", ->
    (expect sloc("a\nb\nc", "js").loc).toEqual 3

  it "should count all single line comments", ->
    coffeeCode =
      """
        # a
        source.code() # comment
        # comment
      """
    jsCode =
      """
        /* a */
        source.code(); //comment
        // comment
      """
    pyCode =
      """
        # a
        source.code(); #comment
        # comment
      """
    cCode =
      """
        /* a */
        source.code(); /* comment */
        // comment
      """
    javaCode =
      """
        /* a */
        public void source(){ /* comment */
          code();
        }
        // comment
      """
    phpCode =
      """
      /**
       * block
       **/

       $test = 0;  // bla
       // comment
      """

    (expect sloc(coffeeCode,  "coffee"      ).cloc).toEqual 2
    (expect sloc(coffeeCode,  "coffeescript").sloc).toEqual 1
    (expect sloc(jsCode,      "js"          ).cloc).toEqual 2
    (expect sloc(jsCode,      "javascript"  ).sloc).toEqual 1
    (expect sloc(pyCode,      "py"          ).cloc).toEqual 2
    (expect sloc(pyCode,      "python"      ).sloc).toEqual 1
    (expect sloc(cCode,       "c"           ).cloc).toEqual 2
    (expect sloc(cCode,       "c"           ).sloc).toEqual 1
    (expect sloc(javaCode,    "java"        ).cloc).toEqual 2
    (expect sloc(javaCode,    "java"        ).sloc).toEqual 3
    (expect sloc(phpCode,     "php"         ).cloc).toEqual 4
    (expect sloc(phpCode,     "php"         ).sloc).toEqual 1

  it "should include block comments", ->
    coffeeCode =
      """
        ### block
        comment
        ###
        source.code() # comment
        # comment
      """
    jsCode =
      """
        /** foo
        block comment
        */
        source.code() /* comment */
        // comment
        /*
        another block comment
        // */
      """
    pyCode = '"""\n block comment\n """\n' +
      'source.code() # comment\n' +
      " '''\n another block comment\n '''"
    cCode =
      """
        /* comment */ some.source.code()
        source.code() /* comment */
        // comment
        /* comment */
        /*
          comment
        */
        /**
          //
          another block comment
         */
      """
    javaCode =
      """
        /** foo
        block comment
        */
        source.code() /* comment */
        // comment
        /*
        another block comment
        // */
      """

    (expect sloc(coffeeCode, "coffee").cloc).toEqual  4
    (expect sloc(coffeeCode, "coffee").sloc).toEqual  1
    (expect sloc(coffeeCode, "coffee").mcloc).toEqual 3

    (expect sloc(jsCode,"js").cloc).toEqual  7
    (expect sloc(jsCode,"js").sloc).toEqual  1
    (expect sloc(jsCode,"js").mcloc).toEqual 6
    (expect sloc(jsCode,"js").scloc).toEqual 1

    (expect sloc(pyCode,"py").cloc).toEqual  6
    (expect sloc(pyCode,"py").sloc).toEqual  1
    (expect sloc(pyCode,"py").mcloc).toEqual 6

    (expect sloc(cCode,"c").cloc).toEqual  9
    (expect sloc(cCode,"c").sloc).toEqual  2
    (expect sloc(cCode,"c").mcloc).toEqual 7
    (expect sloc(cCode,"c").scloc).toEqual 2

    (expect sloc(javaCode,"java").cloc).toEqual 7
    (expect sloc(javaCode,"java").loc).toEqual 8

  it "should count empty lines", ->
    coffeeCode =
      """

        source.code() # comment

        # comment
      """
    (expect sloc(coffeeCode, "coffee").nloc).toEqual 2
