# sloc

Create stats of your source code:

- lines of code
- lines with comments
- lines with block comments
- lines with single-line comments
- lines mixed up with source and comments
- empty lines
- physical lines

[![Build Status](https://secure.travis-ci.org/flosse/sloc.png)](http://travis-ci.org/flosse/sloc)
[![Dependency Status](https://gemnasium.com/flosse/sloc.png)](https://gemnasium.com/flosse/sloc)
[![NPM version](https://badge.fury.io/js/sloc.png)](http://badge.fury.io/js/sloc)

## Supported languages

- CoffeeScript
- C / C++
- CSS / SCSS / LESS / Stylus
- Erlang
- Go
- HTML
- Haxe
- Java
- JavaScript
- Lua
- Python
- PHP

## Supported outputs

sloc provides a set of output formatters:

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

## Usage

### CLI

```
sloc [option] <file>|<directory>
```

Options:

```
-h, --help             output usage information
-V, --version          output the version number
-e, --exclude <regex>  regular expression to exclude files and folders
-f, --format <format>  format output: json, csv, cli-table
-k, --keys <keys>      report only numbers of the given keys
-d, --details          report stats of each analzed file
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
$ sloc --details --format cli-table --keys total,source,comment --exclude i18n*.\.coffee src/

┌─────────────────────────────────┬──────────┬────────┬─────────┐
│ Path                            │ Physical │ Source │ Comment │
├─────────────────────────────────┼──────────┼────────┼─────────┤
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
    console.log("total   lines: " + stats.total);
    console.log("source  lines: " + stats.source);
    console.log("comment lines: " + stats.comment);
  }

});
```

### Browser

```javascript
var sourceCode = "foo();\n /* bar */\n baz();";

var stats = window.sloc(sourceCode,"javascript");

console.log("total   lines: " + stats.total);
console.log("source  lines: " + stats.source);
console.log("comment lines: " + stats.comment);
```

### Grunt

If you'd like to use sloc within your grunt process you can use
[grunt-sloc](https://github.com/rhiokim/grunt-sloc).

Install it:

    npm install grunt-sloc --save-dev

and use it:

    grunt.loadNpmTasks('grunt-sloc');

For more details navigate to the
[project site](https://github.com/rhiokim/grunt-sloc).

### Gulp

sloc is also available for gulp.

Install [gulp-sloc](https://github.com/oddjobsman/gulp-sloc):

    npm install --save-dev gulp-sloc

and use it:

```javascript
var sloc = require('gulp-sloc');

gulp.task('sloc', function(){
  gulp.src(['scripts/*.js']).pipe(sloc());
});
```

## Run tests

    npm test

## Changelog

### v0.1.0

- changed API (now it has a better readability)
- refactored the algorithm
- relicensed under the MIT license
- support counting mixed lines (comment + source code)
- limit reported numbers by a list of keys
- multiple output formatters
    - csv
    - cli table
    - json
- new supported languages
    - erlang
    - less
    - lua
    - haxe

### v0.0.x

Please run `git log v0.0.1...v0.0.8` ;-)

## License

sloc is licensed under the MIT license
