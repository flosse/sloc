module.exports =
  [
    {
      names: ["coffee", "coffeescript"]
      code:
        """
          # a
          source.code() # comment

          ### block
          comment # commented comment
          ###
          source() ### one line block ###
          ### one line block ### code()
          ### block ### code() ###
          ### souce() # comment ### no block ###
          ###### code() ###### code()
        """
      cloc: 10
      sloc: 5
      scloc: 3
      mcloc: 8
      loc: 11
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
      cloc: 9
      sloc: 1
      mcloc: 7
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
      cloc: 9
      sloc: 1
      mcloc: 6
      loc: 10
      scloc: 3
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
      cloc: 11
      sloc: 2
      mcloc: 10
      scloc: 1
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
      cloc: 10
      sloc: 4
      mcloc: 9
      loc: 12
      nloc: 0
      scloc: 1
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
      cloc: 5
      sloc: 1
      mcloc: 3
      loc: 6
      nloc: 1
      scloc: 2
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
      cloc: 7
      sloc: 3
      mcloc: 6
      loc: 9
      nloc: 0
      scloc: 1
    }
    {
      names: ["css"]
      code:
        """
        /* comment */
        selector { property: value; /* comment */ }
        * { color: blue; }
        /* block
           comment */
        """
      cloc: 4
      sloc: 2
      mcloc: 4
      loc: 5
      nloc: 0
      scloc: 0
    }
    {
      names: ["scss"]
      code:
        """
        /* comment */
        selector { property: value; /* comment */ }
        * { color: blue; }
        /* block
           comment */
        body { margin: 0 }
        // double slash line comment
        """
      cloc: 5
      sloc: 3
      mcloc: 4
      loc: 7
      nloc: 0
      scloc: 1
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
      cloc: 5
      sloc: 3
      mcloc: 4
      loc: 7
      nloc: 0
      scloc: 1
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
      cloc: 5
      sloc: 5
      mcloc: 5
      loc: 9
      nloc: 0
      scloc: 0
    }
    {
      names: ["styl", "stylus"]
      code:
        """
        $foo = "bar"
        html
          font-size 2em
          // one line comment
          h2 // foo
          /* multi
             line comment
           */

          /*! multi-line
             buffered
           */
        """
      loc: 12
      cloc: 8
      sloc: 4
      mcloc: 6
      nloc: 1
      scloc: 2
    }
    {
      names: ["lua"]
      code:
        """
        local x = 3
        -- on line comment
        y = 42 -- of course
        --[[
          multiline [comment]
        --]]
        s = [[ multi
               line
               string]]
        """
      loc: 9
      cloc: 5
      sloc: 5
      mcloc: 3
      scloc: 2
      nloc: 0
    }
    {
      names: ["erl"]
      code:
        """
        -module(foo).
        -export([bar/1]).
        % on line comment
        bar(0) -> 1;
        %% oohh
        bar(42) -> -3; %%% don't tell!
        bar(N) -> N * bar(N-1).
        """
      loc: 7
      cloc: 3
      sloc: 5
      mcloc: 0
      scloc: 3
      nloc: 0
    }
  ]
