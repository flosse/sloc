module.exports =
  [
    {
      names: ["coffee"]
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
      comment: 10
      source: 6
      single: 3
      block: 8
      total: 11
      mixed: 6
      empty: 1
    }
    {
      names: ["js", "jsx", "ts", "gs"]
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
      comment: 9
      source: 1
      block: 7
      single: 2
      total: 9
      mixed: 1
      empty: 0
    }
    {
      names: ["py"]
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
      comment: 9
      source: 1
      block: 6
      total: 10
      single: 3
      mixed: 1
      empty: 1
    }
    {
      names: ["hx"]
      code:
        """
        /* a */
        source.code(); //comment
        // comment
        /** foo
        block comment
        */
        var people = [
          "Elizabeth" /* block comment */ => "Programming",
          "Joel" => "Design" // mixed
        ];
        /*
        another block comment
        // */
        """
      comment: 11
      source: 5
      block: 8
      single: 3
      total: 13
      mixed: 3
      empty: 0
    }
    {
      names: ["c", "h", "cpp", "hpp", "cxx", "hxx"]
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
      comment: 11
      source: 2
      block: 10
      single: 1
      total: 11
      mixed: 2
      empty: 0
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
      comment: 10
      source: 4
      block: 9
      total: 12
      empty: 0
      single: 1
      mixed: 2
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
      comment: 5
      source: 1
      block: 3
      total: 6
      empty: 1
      single: 2
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
      comment: 7
      source: 3
      block: 6
      total: 9
      empty: 0
      single: 1
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
      comment: 4
      source: 2
      block: 4
      total: 5
      empty: 0
      single: 0
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
      comment: 5
      source: 3
      block: 4
      total: 7
      empty: 0
      single: 1
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
      comment: 5
      source: 3
      block: 4
      total: 7
      empty: 0
      single: 1
    }
    {
      names: ["html", "htm"]
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
      comment: 5
      source: 5
      block: 5
      total: 9
      empty: 0
      single: 0
    }
    {
      names: ["xml", "svg"]
      code:
        """
        <svg>
          <!-- one line comment -->
          <defs>
            <!-- one line comment -->
            <rect id="box" width="10" height="10"/>
          </defs>
          <use x="100" y="100" xlink:href="#box"/>
          <!-- multiple
               line comment
           -->
        </svg>
        """
      comment: 5
      source: 6
      block: 5
      total: 11
      empty: 0
      single: 0
    }
    {
      names: ["mustache"]
      code:
        """
        {{! line comment }}
        {{!-- line comment --}}
        {{#list}} {{.}} {{/list}}
        {{^list.length}}nothing{{/list.length}}
        {{! multiple
            line comment
        }}
        {{!-- multiple
              line comment
        --}}
        """
      comment: 8
      source: 2
      block: 8
      total: 10
      empty: 0
      single: 0
    }
    {
      names: ["handlebars", "hbs"]
      code:
        """
        {{! line comment }}
        {{!-- line comment --}}
        {{#each list}} {{@index}} {{/each}}
        {{#unless list.length}}nothing{{/unless}}
        {{! multiple
            line comment
        }}
        {{!-- multiple
              line comment
        --}}
        """
      comment: 8
      source: 2
      block: 8
      total: 10
      empty: 0
      single: 0
    }
    {
      names: ["styl"]
      code:
        """
        $foo = "bar" /* x */
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
      total: 12
      comment: 9
      source: 4
      block: 7
      empty: 1
      single: 2
      mixed: 2
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
      total: 9
      comment: 5
      source: 5
      block: 3
      single: 2
      empty: 0
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
      total: 7
      comment: 3
      source: 5
      block: 0
      single: 3
      empty: 0
    }
    {
      names: ["monkey"]
      code:
        """
        Strict
        Import mojo
        Import brl.httprequest
        #rem
        Block comment
        #end
        #Rem
        Case insensitive test
        #ENd
        Function Main:Int()
          Print("Hello World") 'comment
          Return 0
        End Function
        ' comment
        #rem
        Block comment 2
        #end
        """
      comment: 11
      source: 7
      block: 9
      single: 2
      total: 17
      mixed: 1
      empty: 0
    }
    {
      names: ["ls"]
      code:
        """
        # a
        source.code() # comment

        /* block
        comment # commented comment
        */
        source() /* one line block */
        /* one line block */ code()
        /* block */ code() /*
        */ souce() # comment /* no block */
        """
      comment: 9
      source: 5
      block: 7
      single: 3
      total: 10
      mixed: 5
      empty: 1
    }
    {
      names: ["scala"]
      code:
        """
        // define index handler
        def index = Action {
          Ok(views.html.index("Hello World!")) // render index template
        }
        /* block comment */ source()
        """
      comment: 3
      source: 4
      block: 1
      single: 2
      total: 5
      mixed: 2
      empty: 0
    }
    {
      names: ["rb"]
      code:
        """
        # a
        source.code() # comment

        =begin=begin block
        comment # commented comment
        =end
        source() =begin one line block=end
        =begin one line block =end code()
        =begin block =end code() =begin
        =end souce() # comment =begin no block =end
        """
      comment: 9
      source: 5
      block: 7
      single: 3
      total: 10
      mixed: 5
      empty: 1
    }
    {
      names: ["jl"]
      code:
        """
        # Single line comment
        #= block comment =#
        """
      comment: 2
      source: 0
      block: 1
      single: 1
      total: 2
      mixed: 0
      empty: 0
    }
    {
      names: ["rs"]
      code:
        """
        // Single line comment
        /* block comment */
        """
      comment: 2
      source: 0
      block: 1
      single: 1
      total: 2
    }
    {
      names: ["vb"]
      code:
        """
        ' single
        ' line
        """
      comment: 2
      source: 0
      block: 0
      single: 2
      total: 2
    }
    {
      names: ["rkt"]
      code:
        """
        ; a
        (+ 1 1) ; comment

        #| begin block
        comment ; commented comment
        |#
        (not #t) #| begin one line block |#
        #| begin one line block |# #\A
        #| begin block |# (exp 2 3) #| begin
        |# (/ 1 3) ; comment #| begin no block |#
        """
      comment: 9
      source: 5
      block: 7
      single: 3
      total: 10
      mixed: 5
      empty: 1
    }
    {
      names: ["hs"]
      code:
        """
        -- a
        1 + 1 -- comment

        {- begin block
        comment -- commented comment
        -}
        [1..5] {- begin one line block -}
        {- begin one line block -} [x*2 | x <- [1..5]]
        {- begin block -} ("haskell", 1) {- begin
        -} snd ("haskell", 1) -- comment {- begin no block -}
        """
      comment: 9
      source: 5
      block: 7
      single: 3
      total: 10
      mixed: 5
      empty: 1
    }
    {
      names: ["nix"]
      code:
        """
        { pkgs }: /* foo bar baz */

        # setup
        let
          nodePackages = import <nixpkgs/pkgs/top-level/node-packages.nix> {
          inherit pkgs;
          inherit (pkgs) stdenv nodejs fetchurl fetchgit;
          neededNatives = [ pkgs.python ]
          self = nodePackages;
          generated = ./package.nix;
        }; # bla bla
        """
      comment: 3
      source: 9
      block: 1
      single: 2
      total: 11
      mixed: 2
      empty: 1
    }
    {
      names: ["hr"]
      code:
        """
        P | Q # P or Q
        ~P    # not P
        Q?    # Q is TURE?
        => TURE
        """
      comment: 3
      source: 4
      block: 0
      single: 3
      total: 4
      mixed: 0
      empty: 0
    }
    {
      names: ["hy"]
      code:
        """
        (print "Hy!");comment
        ; on line comment
        (.strip " foo   ")
        ;;; comment
        """
      comment: 3
      source: 2
      block: 0
      single: 3
      total: 4
      mixed: 1
      empty: 0
    }
    {
      names: ["mochi"]
      code:
        """
          # a
          source.code(); #comment
          # no.source.code();
        """
      comment: 3
      source: 1
      block: 0
      total: 3
      single: 3
      mixed: 1
      empty: 0
    }
    {
      names: ["m", "mm"]
      code:
        """
          // comment
          NSLog("foo"); // comment

          /* block comment */
        """
      comment: 3
      source: 1
      block: 1
      total: 4
      single: 2
      mixed: 1
      empty: 1
    }
    {
      names: ["sass"]
      code:
        """
        // comment
        body
          font: 100% Helvecia, sans-serif /* multi
          line comments */
        """
      comment: 3
      source: 2
      block: 2
      total: 4
      single: 1
      mixed: 1
      empty: 0
    }
    {
      names: ["cr"]
      code:
        """
        # comment
        def lerp(a, b, v)
          a * (1.0 - v) + b * v
        end
        """
      comment: 1
      source: 3
      block: 0
      total: 4
      single: 1
      mixed: 0
      empty: 0
    }
    {
      names: ["nim"]
      code:
        """
        i = 0  # This is a single comment over multiple lines.
         # The scanner merges these two pieces.
         # The comment continues here.
         # Documentation comments are comments that start with two ##

        #! strongSpaces
        if foo+4 * 4 == 8  and  b&c | 9  ++
            bar:
          echo ""

        proc `host=`*(s: var Socket, value: int) {.inline.} =
         ## setter of hostAddr
         s.FHost = value
        """
      comment: 5
      source: 7
      block: 1
      total: 13
      single: 4
      mixed: 1
      empty: 2
    }
  ]
