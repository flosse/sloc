module.exports =
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
    {
      names: ["scss"]
      code:
        """
        /* line comment */
        selector { property: value; /* comment */ }
        * { color: blue; }
        /* block
           comment */
        body { margin: 0 }
        // double slash line comment
        """
      cloc: 4
      sloc: 3
      mcloc: 2
      loc: 7
      nloc: 0
      scloc: 2
    }
    {
      names: ["less"]
      code:
        """
        /* line comment */
        selector { property: value; /* comment */ }
        * { color: blue; }
        /* block
           comment */
        body { margin: 0 }
        // double slash line comment
        """
      cloc: 4
      sloc: 3
      mcloc: 2
      loc: 7
      nloc: 0
      scloc: 2
    }
    {
      names: ["html"]
      code:
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
      cloc: 4
      sloc: 5
      mcloc: 3
      loc: 9
      nloc: 0
      scloc: 1
    }
  ]
