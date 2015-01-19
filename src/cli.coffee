###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2015 (c) Markus Kohlhase <mail@markus-kohlhase.de>
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
keyvalue = (val) -> val.split '='
object = (val) ->
  result = {}
  for split in list(val).map(keyvalue)
    [custom, original] = split
    result[custom] = original
  result
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
    ext = path.extname(f)[1...]
    res.stats = sloc code, options.alias[ext] or ext
    cb null, res

print = (err, result, opts, fmtOpts) ->
  return console.error "Error: #{err}" if err
  f = programm.format or 'simple'
  unless (fmt = fmts[f])?
    return console.error "Error: format #{f} is not supported"
  out = fmt result, opts, fmtOpts
  out = out.replace colorRegex, '' if programm.stripColors
  console.log out if typeof out is "string"

addResult = (res, all) ->
  if res.badFile then all.brokenFiles++
  all.files.push res

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

  .option '-e, --exclude <regex>',
    'regular expression to exclude files and folders'

  .option '-f, --format <format>',
    'format output:' + (" #{k}" for k of fmts).join ','

  .option '--format-option [value]',
    'add formatter option', collect, fmtOpts

  .option '--strip-colors',
    'remove all color characters'

  .option '-k, --keys <keys>',
    'report only numbers of the given keys', list

  .option '-d, --details',
    'report stats of each analyzed file'

  .option '-a, --alias <custom ext>=<standard ext>',
    'alias custom ext to act like standard ext', object

programm.parse process.argv

options.keys    = programm.keys
options.details = programm.details
options.alias   = programm.alias

return programm.help() if programm.args.length < 1

result = files: []

groupByExt = (data) ->
  map = {}
  for f in data.files
    ext = (path.extname f.path)[1...]
    m   = map[ext] ?= { files: [] }
    m.files.push f

  for ext, d of map
    d.summary = helpers.summarize d.files.map (x) -> x.stats
  map

readSingleFile = (f) -> parseFile p, (err, res) ->
  addResult res, result
  result.summary = res.stats
  print err, result, options, fmtOpts

readDir = (dir) ->

  finish = (err, x) ->
    result.summary = helpers.summarize result.files.map (x) -> x.stats
    result.byExt = groupByExt result
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
