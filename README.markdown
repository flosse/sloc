# sloc

Count source lines by

- source lines
- comment lines
- multiline comment lines
- single comment lines
- empty lines
- physical lines

[![Build Status](https://secure.travis-ci.org/flosse/sloc.png)](http://travis-ci.org/flosse/sloc)

## Supported languages

- CoffeeScript
- C / C++
- JavaScript
- Python
- Java
- PHP

## Install

```
sudo npm install -g sloc
```

## Usage

```
sloc [option] <file>|<directory>
```

Options:

```
-h, --help             output usage information
-V, --version          output the version number
-j, --json             return JSON object
-s, --sloc             print only number of source lines
-v, --verbose          print or add analzed files
-e, --exclude <regex>  regular expression to exclude files and folders
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

Or use it in your own node module

```javascript
var fs    = require('fs');
var sloc  = require('sloc');

fs.readFile("mySourceFile.coffee", "utf8", function(err, code){

  if(err){ console.error(err); }
  else{
    stats = sloc(code,"coffeescript");
    console.log("total   lines: " + stats.loc);
    console.log("source  lines: " + stats.sloc);
    console.log("comment lines: " + stats.cloc);
  }

});
```

## Run tests

    npm test

## License

sloc is licensed under the GPLv3 licence
