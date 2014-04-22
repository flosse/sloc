###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

fs        = require 'fs'
path      = require 'path'
async     = require 'async'
programm  = require 'commander'
sloc      = require './sloc'
i18n      = require './i18n'
pkg       = require '../package.json'
csvify    = require './formatters/csv'
cliTable  = require './formatters/cli-table'
simpleOut = require './formatters/simple'

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
        p = path.normalize "#{dir}/#{item}"
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

print = (err, r) ->

  opt = {}
  opt.sloc = true if programm.sloc

  return console.error "Error: #{err}" if err

  if f = programm.format
    switch f
      when 'json'
        return console.log JSON.stringify r
      when 'csv'
        return console.log csvify r, opt
      when 'cli-table'
        return console.log cliTable r, opt
      else
        return console.error "#{i18n.en.Error}: format #{f} is not supported"

  return console.log simpleOut r, opt

programm

  .version pkg.version

  .usage '[option] <file>|<directory>'

  .option '-e, --exclude <regex>',  'regular expression to exclude files and folders'
  .option '-f, --format <format>',  'format output: json, csv, cli-table'
  .option '-s, --sloc',             'print only number of source lines'
  .option '-v, --verbose',          'append stats of each analized file'

programm.parse process.argv

if programm.args.length < 1
  programm.help()

else
  stats = fs.lstatSync programm.args[0]

  if stats.isDirectory() then parseDir  programm.args[0], print
  else if stats.isFile() then parseFile programm.args[0], print
