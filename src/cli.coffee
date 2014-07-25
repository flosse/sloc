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
fmts      = require './formatters'

list = (val) -> val.split ','
exts = ("*.#{k}" for k in sloc.extensions)

collect = (val, memo) ->
  memo.push val
  memo

colorRegex = /\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]/g

parseFile = (f, cb=->) ->
  res = { path: f, stats: {}, badFile: no }
  fs.readFile f, "utf8", (err, code) ->
    if err
      res.badFile = yes
      return cb err, res
    res.stats = sloc code, path.extname(f)[1...]
    cb null, res

print = (err, result, opts, fmtOpts) ->
  return console.error "Error: #{err}" if err
  f = programm.format or 'simple'
  unless (fmt = fmts[f])?
    return console.error "Error: format #{f} is not supported"
  out = fmt result, opts, fmtOpts
  out = out.replace colorRegex, '' if programm.stripColors
  console.log out if typeof out is "string"

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

  (path.join p, r.path for r in res)

options = {}
fmtOpts = []
programm
  .version pkg.version
  .usage '[option] <file> | <directory>'
  .option '-e, --exclude <regex>',        'regular expression to exclude files and folders'
  .option '-f, --format <format>',        'format output:' + (" #{k}" for k of fmts).join ','
  .option '    --format-option [value]',  'add formatter option', collect, fmtOpts
  .option '    --strip-colors',           'remove all color characters'
  .option '-k, --keys <keys>',            'report only numbers of the given keys', list
  .option '-d, --details',                'report stats of each analized file'

programm.parse process.argv
options.keys        = programm.keys
options.details     = programm.details

return programm.help() if programm.args.length < 1

result = files: []

readSingleFile = (f) -> parseFile p, (err, res) ->
  addResult res, result
  result.summary = res.stats
  print err, result, options, fmtOpts

readDir = (dir) ->

  finish = (err, x) ->
    result.summary = helpers.summarize result.files.map (x) -> x.stats
    print err, result, options, fmtOpts

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
