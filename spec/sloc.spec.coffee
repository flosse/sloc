chai   = require 'chai'
should = chai.should()

sloc = require "../src/sloc"

describe "sloc", ->

  it "sloc should be a function", ->
    sloc.should.be.a.function

  it "should count all lines", ->
    sloc("a\nb\nc", "js").loc.should.equal 3

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
    goCode =
      """
      // line comment
      func main() { /* comment */
	      fmt.Println("Hello World")
      }
      /* general
         comment */
      """
    cssCode =
      """
      /* line comment */
      selector { property: value; /* comment */ }
      * { color: blue; }
      /* block
         comment */
      """
    scssCode =
      """
      /* line comment */
      selector { property: value; /* comment */ }
      * { color: blue; }
      /* block
         comment */
      body { margin: 0 }
      // double slash line comment
      """
    htmlCode =
      """
      <html>
        <!-- one line comment -->
        <head><!-- one line comment --></head>
        <body>
        <!-- multiple
             line comment
         -->
        </body>
      </html>
      """

    sloc(coffeeCode,  "coffee"      ).cloc.should.equal 2
    sloc(coffeeCode,  "coffeescript").sloc.should.equal 1
    sloc(jsCode,      "js"          ).cloc.should.equal 2
    sloc(jsCode,      "javascript"  ).sloc.should.equal 1
    sloc(pyCode,      "py"          ).cloc.should.equal 2
    sloc(pyCode,      "python"      ).sloc.should.equal 1
    sloc(cCode,       "c"           ).cloc.should.equal 2
    sloc(cCode,       "c"           ).sloc.should.equal 1
    sloc(javaCode,    "java"        ).cloc.should.equal 2
    sloc(javaCode,    "java"        ).sloc.should.equal 3
    sloc(phpCode,     "php"         ).cloc.should.equal 4
    sloc(phpCode,     "php"         ).sloc.should.equal 1
    sloc(goCode,      "go"          ).cloc.should.equal 3
    sloc(goCode,      "go"          ).sloc.should.equal 3
    sloc(cssCode,     "css"         ).cloc.should.equal 3
    sloc(cssCode,     "css"         ).sloc.should.equal 2
    sloc(scssCode,    "scss"        ).cloc.should.equal 4
    sloc(scssCode,    "scss"        ).sloc.should.equal 3
    sloc(htmlCode,    "html"        ).cloc.should.equal 4
    sloc(htmlCode,    "html"        ).sloc.should.equal 5

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

    goCode =
      """
        /* foo
        block comment
        */
        source.code() /* comment */
        // comment
        /*
        another block comment
        // */
      """

    scssCode =
      """
      /* line comment */
      selector { property: value; /* comment */ }
      * { color: blue; }
      /* block
         comment */
      body { margin: 0 }
      // double slash line comment
      """

    htmlCode =
      """
      <html>
        <!-- one line comment -->
        <head><!-- one line comment --></head>
        <body>
        <!-- multiple
             line comment
         -->
        </body>
      </html>
      """

    sloc(coffeeCode, "coffee").cloc  .should.equal 4
    sloc(coffeeCode, "coffee").sloc  .should.equal 1
    sloc(coffeeCode, "coffee").mcloc .should.equal 3

    sloc(jsCode,"js").cloc  .should.equal 7
    sloc(jsCode,"js").sloc  .should.equal 1
    sloc(jsCode,"js").mcloc .should.equal 6
    sloc(jsCode,"js").scloc .should.equal 1

    sloc(pyCode,"py").cloc  .should.equal 6
    sloc(pyCode,"py").sloc  .should.equal 1
    sloc(pyCode,"py").mcloc .should.equal 6

    sloc(cCode,"c").cloc    .should.equal 9
    sloc(cCode,"c").sloc    .should.equal 2
    sloc(cCode,"c").mcloc   .should.equal 7
    sloc(cCode,"c").scloc   .should.equal 2

    sloc(javaCode,"java").cloc .should.equal 7
    sloc(javaCode,"java").loc  .should.equal 8

    sloc(goCode,"go").cloc .should.equal 7
    sloc(goCode,"go").loc  .should.equal 8

    sloc(scssCode,"scss").cloc   .should.equal 4
    sloc(scssCode,"scss").sloc   .should.equal 3
    sloc(scssCode,"scss").mcloc  .should.equal 2
    sloc(scssCode,"scss").scloc  .should.equal 2

    sloc(htmlCode,"html").cloc   .should.equal 4
    sloc(htmlCode,"html").sloc   .should.equal 5
    sloc(htmlCode,"html").mcloc  .should.equal 3
    sloc(htmlCode,"html").scloc  .should.equal 1

  it "should count empty lines", ->
    coffeeCode =
      """

        source.code() # comment

        # comment
      """
    sloc(coffeeCode, "coffee").nloc.should.equal 2

  it "should throw an error", ->
    (-> sloc "foo", "foobar").should.throw()
    (-> sloc null, "coffee") .should.throw()
