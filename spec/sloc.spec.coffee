chai   = require 'chai'
should = chai.should()

sloc = require "../src/sloc"

describe "sloc", ->

  it "sloc should be a function", ->
    sloc.should.be.a.function

  it "should count all lines", ->
    sloc("a\nb\nc", "js").loc.should.equal 3

  languages =
    [
      {
        names: ["coffee", "coffeescript"]
        code:
          """
            # a
            source.code() # comment

            ### block
            comment
            ###
          """
        cloc: 4
        sloc: 1
        scloc: 1
        mcloc: 3
        loc: 6
        nloc: 1
      }
      {
        names: ["js", "javascript"]
        code:
          """
            /* a */
            source.code(); //comment
            // comment
            /** foo
            block comment
            */
            /*
            another block comment
            // */
          """
        cloc: 8
        sloc: 1
        mcloc: 6
        scloc: 2
        loc: 9
        nloc: 0
      }
      {
        names: ["py", "python"]
        code:
          """
            \"""
            block comment
            \"""
            # a
            source.code(); #comment

            # comment
            '''
            another block comment
            '''
          """
        cloc: 8
        sloc: 1
        mcloc: 6
        loc: 10
        scloc: 2
        nloc: 1
      }
      {
        names: ["c"]
        code:
          """
            /* a */
            source.code(); /* comment */
            // comment
            /* a */ more.code();
            /*
              comment
            */
            /**
              //
              another block comment
             */
          """
        cloc: 9
        sloc: 2
        mcloc: 7
        scloc: 2
        loc: 11
        nloc: 0
      }
      {
        names: ["java"]
        code:
          """
            /** foo
            block comment
            */
            /* a */
            public void source(){ /* comment */
              code();
            }
            // comment
            /* b */ more.code();
            /*
            another block comment
            // */
          """
        cloc: 8
        sloc: 4
        mcloc: 6
        loc: 12
        nloc: 0
        scloc: 2
      }
      {
        names: ["php", "php5"]
        code:
          """
          /**
           * block
           **/

           $test = 0;  // bla
           // comment
          """
        cloc: 4
        sloc: 1
        mcloc: 3
        loc: 6
        nloc: 1
        scloc: 1
      }
      {
        names: ["go"]
        code:
          """
          /* foo
          block comment
          */
          // line comment
          func main() { /* comment */
	          fmt.Println("Hello World")
          }
          /* general
          // comment */
          """
        cloc: 6
        sloc: 3
        mcloc: 5
        loc: 9
        nloc: 0
        scloc: 1
      }
      {
        names: ["css"]
        code:
          """
          /* line comment */
          selector { property: value; /* comment */ }
          * { color: blue; }
          /* block
             comment */
          """
        cloc: 3
        sloc: 2
        mcloc: 2
        loc: 5
        nloc: 0
        scloc: 1
      }
    ]

  it "should count all single line comments and block comments", ->
    for l in languages
      for n in l.names
        res = sloc l.code, n
        res.loc   .should.equal l.loc
        res.sloc  .should.equal l.sloc
        res.cloc  .should.equal l.cloc
        res.scloc .should.equal l.scloc
        res.mcloc .should.equal l.mcloc
        res.nloc  .should.equal l.nloc

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
