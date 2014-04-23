###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

fs        = require 'fs'
path      = require 'path'
async     = require 'async'
programm  = require 'commander'
readdirp  = require 'readdirp'
sloc      = require './sloc'
helpers   = require './helpers'
pkg       = require '../package.json'
csvify    = require './formatters/csv'
cliTable  = require './formatters/cli-table'
simpleOut = require './formatters/simple'

list      = (val) -> val.split ','
exts      = ("*.#{k}" for k in sloc.extensions)

parseFile = (f, cb=->) ->
  res = { path: f, stats: {}, badFile: no }
  fs.readFile f, "utf8", (err, code) ->
    if err
      res.badFile = yes
      return cb err, res
    res.stats = sloc code, path.extname(f)[1...]
    cb null, res

print = (err, result) ->
  return console.error "Error: #{err}" if err
  unless f = programm.format
    console.log simpleOut result, options
  else
    out = switch f
      when 'json'      then JSON.stringify result, null, 2
      when 'csv'       then csvify result, options
      when 'cli-table' then cliTable result, options

    if typeof out is 'string' then console.log out
    else console.error "Error: format #{f} is not supported"

addResult = (res, global) ->
  if res.badFile then global.brokenFiles++
  global.files.push res

filterFiles = (files) ->
  res =
    if programm.exclude
      exclude = new RegExp programm.exclude
      files.filter (x) -> not exclude.test x.path
    else
      files

  (path.normalize(p + r.path) for r in res)

programm
  .version pkg.version
  .usage '[option] <file> | <directory>'
  .option '-e, --exclude <regex>',  'regular expression to exclude files and folders'
  .option '-f, --format <format>',  'format output: json, csv, cli-table'
  .option '-k, --keys <keys>',      'report only numbers of the given keys', list
  .option '-d, --details',          'report stats of each analized file'

programm.parse process.argv
options         = {}
options.keys    = programm.keys
options.details = programm.details

return programm.help() if programm.args.length < 1

result = files: []

readSingleFile = (f) -> parseFile p, (err, res) ->
  addResult res, result
  result.summary = res.stats
  print err, result

readDir = (dir) ->

  finish = (err, x) ->
    result.summary = helpers.summarize result.files.map (x) -> x.stats
    print err, result

  processFile = (f, next) -> parseFile f, (err, r) ->
    addResult r, result
    next()

  readdirp { root: dir, fileFilter: exts }, (err, res) ->
    async.forEach (filterFiles res.files), processFile, finish

p = programm.args[0]

fs.lstat p, (err, stats) ->
  return console.error "Error: invalid path argument" if err
  if stats.isDirectory() then readDir p
  else if stats.isFile() then readSingleFile p
