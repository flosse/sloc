###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

fs        = require 'fs'
path      = require 'path'
async     = require 'async'
programm  = require 'commander'
sloc      = require './sloc'
i18n      = require './i18n'
pkg       = require '../package.json'

BAD_FILE    = "badFile"
BAD_FORMAT  = "badFormat"
BAD_DIR     = "badDirectory"

parseFile = (f, cb=->) ->
  fs.readFile f, "utf8", (err, code) ->
    return cb BAD_FILE if err
    try
      cb null, sloc code, path.extname(f)[1...]
    catch e
      cb BAD_FORMAT

parseDir = (dir, cb) ->

  files   = []
  res     = []
  exclude = null

  if programm.exclude
    exclude = new RegExp programm.exclude

  # get a list of all files (env in sub directories)
  inspect = (dir, done) ->
    # exit if directory is excluded
    return done() if exclude?.test dir
    fs.readdir dir, (err, items) ->
      if err?
        res.push err: BAD_DIR, path: dir
        return done()
      async.forEach items, (item, next) ->
        p = "#{dir}/#{item}"
        # exit if folder is excluded
        return next() if exclude?.test p
        fs.lstat p, (err, stat) ->
          if err?
            res.push err: BAD_FILE, path: p
            return next()
          # recursively inspect directory
          return inspect p, next if stat.isDirectory()
          files.push p
          next()
      , done

  inspect dir, ->

    processResults = (err) ->

      return cb err if err

      # Initialize counter to handle case of first analyzed file filed in error
      init =
        loc   : 0
        sloc  : 0
        cloc  : 0
        scloc : 0
        mcloc : 0
        nloc  : 0

      init[BAD_FILE]   = 0
      init[BAD_FORMAT] = 0
      init[BAD_DIR]    = 0

      res.splice 0, 0, init
      sums = res.reduce (a,b) ->
        o = {}
        o[k] = a[k] + (b[k] or 0) for k,v of a
        o[b.err]++ if b.err?
        o
      sums.filesRead = res.length-1

      if programm.verbose
        # remove counter initialization
        res.splice 0, 1
        sums.details = res
      cb null, sums

    async.forEach files, (f, next) ->
      parseFile f, (err, r) ->
        if err
          r = err: err, path: f
        else
          r.path = f
        res.push r
        next()
    , processResults

# convert data to CSV format for easy import into Spreadsheets
csvify = (data) ->

  headers = ['loc', 'sloc', 'cloc', 'scloc', 'mcloc', 'nloc']

  lines = "Path,#{(i18n.en[k] for k in headers).join ','}\n"

  lineize = (t) ->
    "#{t.path or "Total"},#{(t[k] for k,v of headers).join ','}\n"

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
    console.log "\n---------- #{i18n.en.Result} ------------\n"
  else
    console.log "\n--- #{file}"

  if err?
    console.log "               error :  #{err}"
  else if programm.sloc
    console.log r.sloc
  else
    console.log """
            physical lines :  #{r.loc}
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
  .version(pkg.version)
  .usage('[option] <file>|<directory>')
  .option('-j, --json', 'return JSON object')
  .option('-c, --csv', 'return CSV')
  .option('-s, --sloc', 'print only number of source lines')
  .option('-v, --verbose', 'print or add analized files')
  .option('-e, --exclude <regex>', 'regular expression to exclude files and folders')

programm.parse process.argv

if programm.args.length < 1
  programm.help()

else
  stats = fs.lstatSync programm.args[0]

  if stats.isDirectory() then parseDir  programm.args[0], print
  else if stats.isFile() then parseFile programm.args[0], print
