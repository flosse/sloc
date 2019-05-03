###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2018 (c) Markus Kohlhase <mail@markus-kohlhase.de>
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

print = (result, opts, fmtOpts) ->
  f = programm.format or 'simple'
  unless (fmt = fmts[f])?
    return console.error "Error: format #{f} is not supported"
  out = fmt result, opts, fmtOpts
  out = out.replace colorRegex, '' if programm.stripColors
  console.log out if typeof out is "string"

filterFiles = (files) ->
  res =
    if programm.exclude
      exclude = new RegExp programm.exclude
      files.filter (x) -> not exclude.test x.path
    else
      files

  res2 =
    if programm.include
      include = new RegExp programm.include
      res.filter (x) -> include.test x.path
    else
      res

  (r.path for r in res2)

options = {}
fmtOpts = []
programm

  .version pkg.version

  .usage '[option] <file> | <directory>'

  .option '-e, --exclude <regex>',
    'regular expression to exclude files and folders'

  .option '-i, --include <regex>',
  'regular expression to include files and folders'

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
for k of options.alias
  exts.push "*.#{k}"

return programm.help() if programm.args.length < 1

groupByExt = (data) ->
  map = {}
  for f in data.files
    ext = (path.extname f.path)[1...]
    m   = map[ext] ?= { files: [] }
    m.files.push f

  for ext, d of map
    d.summary = helpers.summarize d.files.map (x) -> x.stats
  map

readSingleFile = (f, done) -> parseFile f, (err, res) ->
  done err, [res]

readDir = (dir, done) ->
  processFile = (f, next) -> parseFile (path.join dir, f), next

  readdirp { root: dir, fileFilter: exts }, (err, res) ->
    return done(err) if err
    async.mapLimit (filterFiles res.files), 1000, processFile, done

readSource = (p, done) ->
  fs.lstat p, (err, stats) ->
    if err
      console.error "Error: invalid path argument #{p}"
      return done(err)
    if stats.isDirectory() then return readDir p, done
    else if stats.isFile() then return readSingleFile p, done

async.map programm.args, readSource, (err, parsed) ->
  return console.error "Error: #{err}" if err

  result = files: []

  parsed.forEach (files) ->
    files.forEach (f) ->
      if f.badFile then result.brokenFiles++
      result.files.push f

  result.summary = helpers.summarize result.files.map (x) -> x.stats
  result.byExt = groupByExt result
  print result, options, fmtOpts
