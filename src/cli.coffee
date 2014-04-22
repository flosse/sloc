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
helpers   = require './helpers'
pkg       = require '../package.json'
csvify    = require './formatters/csv'

BAD_FILE    = i18n.en.BadFile
BAD_FORMAT  = i18n.en.BadFormat
BAD_DIR     = i18n.en.BadDir

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

print = (err, r, file=null) ->

  align = helpers.alignRight
  col   = 20

  if f = programm.format
    switch f
      when 'json'
        return console.log JSON.stringify if err? then err: err else r
      when 'csv'
        return console.log if err? then err: err else csvify r
      else
        return console.error "Error: format #{f} is not supported"

  unless file?
    console.log "\n---------- #{i18n.en.Result} ------------\n"
  else
    console.log "\n--- #{file}"

  if err?
    console.log "#{align i18n.en.Error, col} :  #{err}"
  else if programm.sloc
    console.log r.sloc
  else
    console.log """
      #{align i18n.en.loc,   col} :  #{r.loc}
      #{align i18n.en.sloc,  col} :  #{r.sloc}
      #{align i18n.en.cloc,  col} :  #{r.cloc}
      #{align i18n.en.scloc, col} :  #{r.scloc}
      #{align i18n.en.mcloc, col} :  #{r.mcloc}
      #{align i18n.en.nloc,  col} :  #{r.nloc}
      """
  unless file?
    if r.filesRead?
      console.log "\n\n#{i18n.en.NumberOfFilesRead} :  #{r.filesRead}"

    if r[BAD_FORMAT]
      console.log "#{align i18n.en.UnknownSourceFiles, col} :  #{r[BAD_FORMAT]}"
    if r[BAD_FILE]
      console.log "#{align i18n.en.Brokenfiles, col} :  #{r[BAD_FILE]}"
    if r[BAD_DIR]
      console.log "#{align i18n.en.BrokenDirectories, col} :  #{r[BAD_DIR]}"

    if r.details?
      console.log "\n---------- #{i18n.en.Details} -----------"
      print details.err, details, details.path for details in r.details

    console.log "\n------------------------------\n"

programm

  .version pkg.version

  .usage '[option] <file>|<directory>'

  .option '-e, --exclude <regex>',  'regular expression to exclude files and folders'
  .option '-f, --format <format>',  'format output: json, csv'
  .option '-s, --sloc',             'print only number of source lines'
  .option '-v, --verbose',          'append stats of each analized file'

programm.parse process.argv

if programm.args.length < 1
  programm.help()

else
  stats = fs.lstatSync programm.args[0]

  if stats.isDirectory() then parseDir  programm.args[0], print
  else if stats.isFile() then parseFile programm.args[0], print
