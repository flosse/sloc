###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

fs        = require 'fs'
async     = require 'async'
sloc      = require './sloc'
programm  = require 'commander'

BAD_FILE    = "badFile"
BAD_FORMAT  = "badFormat"
BAD_DIR     = "badDirectory"

getExtension = (f) ->
  i = f.lastIndexOf '.'
  if i < 0 then '' else f.substr(i)[1...]

parseFile = (f, cb) ->
  fs.readFile f, "utf8", (err, code) ->
    if err?
      cb? BAD_FILE
    else
      try
        cb? null, sloc code, getExtension f
      catch e
        cb? BAD_FORMAT

parseDir = (dir, cb) ->

  files = []
  res = []
  exclude = null
  if programm.exclude
    exclude = new RegExp programm.exclude

  # get a list of all files (env in sub directories)
  inspect = (dir, done) ->
    # exit if directory is excluded
    return done() if exclude?.test dir
    fs.readdir dir, (err, items) ->
      if err?
        res.push err: BAD_DIR, path: path
        return done()
      async.forEach items, (item, next) ->
        path = "#{dir}/#{item}"
        # exit if folder is excluded
        return next() if exclude?.test path
        fs.lstat path, (err, stat) ->
          if err?
            res.push err: BAD_FILE, path: path
            return next()
          # recursively inspect directory
          return inspect path, next if stat.isDirectory()
          files.push path
          next()
      , done

  inspect dir, ->
    async.forEach files, (f, next) ->
      parseFile f, (err, r) ->
        if err?
          r =
            err: err
            path: f
        else
          r.path = f
        res.push r
        next()
    , (err) ->
      if err?
        cb err
      else
        # Initialize counter to handle case of first analyzed file filed in error
        init =
          loc: 0
          sloc: 0
          cloc: 0
          scloc: 0
          mcloc: 0
          nloc: 0
        init[BAD_FILE] = 0
        init[BAD_FORMAT] = 0
        init[BAD_DIR] = 0
        res.splice 0, 0, init
        sums = res.reduce (a,b) ->
          o = {}
          o[k] = a[k] + (b[k] or 0) for k,v of a
          o[b.err]++ if b.err?
          o
        sums.filesRead  = res.length-1
        if programm.verbose
          # remove counter initialization
          res.splice 0, 1
          sums.details = res
        cb null, sums

# convert data to CSV format for easy import into Spreadsheets
csvify = (data) ->
  lines = "Path,Physical lines,Lines of source code,Total comment,Singleline,Multiline,Empty\n"

  lineize = (t) ->
    (if t.path then t.path else "Total") + "," + ([t.loc, t.sloc, t.cloc, t.scloc, t.mcloc, t.nloc].join ",") + "\n"

  if data.details
    for sf in data.details
      lines += lineize sf
  else
    lines += lineize data

  lines

print = (err, r, file=null) ->
  if programm.json
    return console.log JSON.stringify if err? then err: err else r

  if programm.csv
    return console.log if err? then err: err else csvify r

  unless file?
    console.log "\n---------- result ------------\n"
  else
    console.log "\n--- #{file}"

  if err?
    console.log "               error :  #{err}"
  else if programm.sloc
    console.log r.sloc
  else
    console.log """      physical lines :  #{r.loc}
      lines of source code :  #{r.sloc}
             total comment :  #{r.cloc}
                singleline :  #{r.scloc}
                 multiline :  #{r.mcloc}
                     empty :  #{r.nloc}"""
  unless file?
    if r.filesRead?
      console.log "\n\nnumber of files read :  #{r.filesRead}"

    if r[BAD_FORMAT]
      console.log "unknown source files :  #{r[BAD_FORMAT]}"
    if r[BAD_FILE]
      console.log "        broken files :  #{r[BAD_FILE]}"
    if r[BAD_DIR]
      console.log "  broken directories :  #{r[BAD_DIR]}"

    if r.details?
      console.log '\n---------- details -----------'
      print details.err, details, details.path for details in r.details

    console.log "\n------------------------------\n"

programm
  .version('0.0.2')
  .usage('[option] <file>|<directory>')
  .option('-j, --json', 'return JSON object')
  .option('-c, --csv', 'return CSV')
  .option('-s, --sloc', 'print only number of source lines')
  .option('-v, --verbose', 'print or add analzed files')
  .option('-e, --exclude <regex>', 'regular expression to exclude files and folders')

programm.parse process.argv

if programm.args.length < 1
  programm.help()

else
  stats = fs.lstatSync programm.args[0]

  if stats.isDirectory() then parseDir  programm.args[0], print
  else if stats.isFile() then parseFile programm.args[0], print
