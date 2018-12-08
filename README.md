# sloc

Create stats of your source code:

- physical lines
- lines of code (source)
- lines with comments
- lines with single-line comments
- lines with block comments
- lines mixed up with source and comments
- empty lines within block comments
- empty lines
- lines with TODO's

[![Build Status](https://secure.travis-ci.org/flosse/sloc.svg?branch=master)](http://travis-ci.org/flosse/sloc)
[![Dependency Status](https://gemnasium.com/flosse/sloc.svg)](https://gemnasium.com/flosse/sloc)
[![NPM version](https://badge.fury.io/js/sloc.svg)](http://badge.fury.io/js/sloc)
[![Bower version](https://img.shields.io/bower/v/sloc.svg)](https://github.com/flosse/sloc)
[![License](https://img.shields.io/npm/l/sloc.svg)](https://github.com/flosse/sloc/blob/master/LICENCE.txt)
[![Minified size](http://img.shields.io/badge/size-6,1K-blue.svg)](https://github.com/flosse/sloc)

## Supported outputs

In addition to the default terminal output (see examples below), sloc provides an alternative set of output formatters:

- CSV
- JSON
- Commandline table

## Install

To use sloc as an application install it globally:

```
sudo npm install -g sloc
```

If you're going to use it as a Node.js module within your project:

```
npm install --save sloc
```

### Browser

You can also use sloc within your browser application.

Link `sloc.js` in your HTML file:

```html
<script src="lib/sloc.js"></script>
```

sloc is also available via [bower](http://twitter.github.com/bower/):

```
bower install sloc
```

**Note**:
You need to compile the coffee-script files yourself.
If you want to use a precompiled bower package, you can run

```
bower install sloc-bower
```

## Usage

### CLI

```
sloc [option] <file>|<directory>
```

Options:

```
-h, --help                  output usage information
-V, --version               output the version number
-e, --exclude <regex>       regular expression to exclude files and folders
-f, --format <format>       format output: json, csv, cli-table
    --format-option [value] add formatter option
-k, --keys <keys>           report only numbers of the given keys
-d, --details               report stats of each analzed file
-a, --alias <custom ext>=<standard ext> alias custom ext to act like standard ext (eg. php5=php,less=css)
```

e.g.:

```
$ sloc src/

---------- Result ------------

            Physical :  1202
              Source :  751
             Comment :  322
 Single-line comment :  299
       Block comment :  23
               Mixed :  116
               Empty :  245

Number of files read :  10

------------------------------
```

or

```
$ sloc --details \
       --format cli-table \
       --keys total,source,comment \
       --exclude i18n*.\.coffee \
       --format-option no-head src/

┌─────────────────────────────────┬──────────┬────────┬─────────┐
│ src/cli.coffee                  │ 98       │ 74     │ 7       │
├─────────────────────────────────┼──────────┼────────┼─────────┤
│ src/helpers.coffee              │ 26       │ 20     │ 0       │
├─────────────────────────────────┼──────────┼────────┼─────────┤
│ src/sloc.coffee                 │ 196      │ 142    │ 20      │
├─────────────────────────────────┼──────────┼────────┼─────────┤
│ src/formatters/simple.coffee    │ 44       │ 28     │ 7       │
├─────────────────────────────────┼──────────┼────────┼─────────┤
│ src/formatters/csv.coffee       │ 25       │ 14     │ 5       │
├─────────────────────────────────┼──────────┼────────┼─────────┤
│ src/formatters/cli-table.coffee │ 22       │ 13     │ 0       │
└─────────────────────────────────┴──────────┴────────┴─────────┘
```

### Node.js

Or use it in your own node module

```javascript
var fs    = require('fs');
var sloc  = require('sloc');

fs.readFile("mySourceFile.coffee", "utf8", function(err, code){

  if(err){ console.error(err); }
  else{
    var stats = sloc(code,"coffee");
    for(i in sloc.keys){
      var k = sloc.keys[i];
      console.log(k + " : " + stats[k]);
    }
  }
});
```

### Browser

```javascript
var sourceCode = "foo();\n /* bar */\n baz();";

var stats = window.sloc(sourceCode,"javascript");
```

### Contribute an new formatter

1. Fork this repo

2. add the new formatter into `src/formatters/` that exports a
   method with three arguments:
   1. results (object)
   2. global options (object)
   3. formatter specific options (array)

3. add the formatter in `src/cli.coffee`

4. open a pull request

### sloc adapters

- Grunt
    - [grunt-sloc](https://github.com/rhiokim/grunt-sloc).
    - [grunt-sloccount](https://github.com/asciidisco/grunt-sloccount)
    - [grunt-maxlines](https://github.com/zerok/grunt-maxlines)
    - [grunt-file-sloc](https://github.com/bubkoo/grunt-file-sloc)

- Gulp
    - [gulp-sloc](https://github.com/oddjobsman/gulp-sloc):
    - [gulp-sloc2](https://github.com/pnarielwala/gulp-sloc2)

- [Atom](https://atom.io/)

    - [atom-sloc](https://github.com/sgade/atom-sloc)
    - [line-count](https://github.com/mark-hahn/line-count)

- Jenkins
    - [sloc-for-jenkins](https://www.npmjs.com/package/sloc-for-jenkins)
    - [sloccount](https://github.com/asciidisco/sloccount)

- Istanbbul
    - [istanbul-reporter-clover-limits](https://github.com/Cellarise/istanbul-reporter-clover-limits/)

- Codemetrics
    - [codemetrics-process-sloc](https://github.com/maxdow/codemetrics-process-sloc)

## Supported languages

- Assembly
- Brightscript
- C / C++
- C#
- Clojure / ClojureScript
- CoffeeScript / IcedCoffeeScript
- Crystal
- CSS / SCSS / SASS / LESS / Stylus
- Erlang
- F#
- Fortran
- Go
- Groovy
- Handlebars
- Haskell
- Haxe
- Hilbert
- HTML
- hy
- Jade
- Java
- JavaScript
- JSX
- Julia
- Kotlin
- LaTeX
- LilyPond
- LiveScript
- Lua
- MJS
- Mochi
- Monkey
- Mustache
- Nim
- Nix
- Objective-C / Objective-C++
- OCaml
- Perl 5
- PHP
- Python
- R
- Racket
- Ruby
- Rust
- Scala
- Squirrel
- SVG
- Swift
- Typescript
- Visual Basic
- XML
- Yaml

## Run tests

    npm test

## Build

    npm run prepublish

## Changelog

see `CHANGELOG.md`

## License

sloc is licensed under the MIT license
