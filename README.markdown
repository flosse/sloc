# sloc

Count source lines by

- source lines
- comment lines
- multiline comment lines
- single comment lines
- empty lines
- physical lines

[![Build Status](https://secure.travis-ci.org/flosse/sloc.png)](http://travis-ci.org/flosse/sloc)
[![Dependency Status](https://gemnasium.com/flosse/sloc.png)](https://gemnasium.com/flosse/sloc)
[![NPM version](https://badge.fury.io/js/sloc.png)](http://badge.fury.io/js/sloc)

## Supported languages

- CoffeeScript
- C / C++
- CSS / SCSS / LESS
- Go
- HTML
- Java
- JavaScript
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
-s, --sloc             print only number of source lines
-v, --verbose          print or add analzed files
```

e.g.:

```
$ sloc src/

---------- result ------------

      physical lines :  301
lines of source code :  236
       total comment :  17
          singleline :  9
           multiline :  8
               empty :  48


number of files read :  2

------------------------------
```

### Node.js

Or use it in your own node module

```javascript
var fs    = require('fs');
var sloc  = require('sloc');

fs.readFile("mySourceFile.coffee", "utf8", function(err, code){

  if(err){ console.error(err); }
  else{
    var stats = sloc(code,"coffeescript");
    console.log("total   lines: " + stats.loc);
    console.log("source  lines: " + stats.sloc);
    console.log("comment lines: " + stats.cloc);
  }

});
```

### Browser

```javascript
var sourceCode = "foo();\n /* bar */\n baz();";

var stats = window.sloc(sourceCode,"javascript");

console.log("total   lines: " + stats.loc);
console.log("source  lines: " + stats.sloc);
console.log("comment lines: " + stats.cloc);
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

## License

sloc is licensed under the GPLv3 licence
