# sloc

Count source lines by

- source lines
- comment lines
- multiline comment lines
- single comment lines
- empty lines
- physical lines

[![Build Status](https://secure.travis-ci.org/flosse/sloc.png)](http://travis-ci.org/flosse/sloc)

## supported languages

- CoffeeScript
- C / C++
- JavaScript
- Python

## Usage

```
sudo npm install -g sloc
```

```
sloc <file>
```

    $ sloc src/
    ---------- result ------------
         physical :  220
           source :  167
    total comment :  11
       singleline :  3
        multiline :  8
            empty :  42
    ------------------------------

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
