###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

fs        = require 'fs'
async     = require 'async'
sloc      = require './sloc'
programm  = require 'commander'

getExtension = (f) ->
  i = f.lastIndexOf '.'
  if i < 0 then '' else f.substr i

parseFile = (f, cb) ->
  fs.readFile f, "utf8", (err, code) ->
    if err
      console.error err
      cb? err
    else
      cb? null, sloc code, getExtension f

parseDir = (dir, cb) ->

  files = ("#{dir}/#{f}" for f in fs.readdirSync dir)

  parseFunctions = []

  for f in files then do (f) ->
    parseFunctions.push (next) -> parseFile f, next

  async.parallel parseFunctions, (err, res) ->
    if err?
      cb err
    else
      cb null, res.reduce (a,b) ->
        o = {}
        o[k] = a[k] + b[k] for k,v of a
        o

print = (err, r) ->
  if err?
    console.error err
  else if programm.json
    console.log JSON.stringify r
  else if programm.sloc
    console.log r.sloc
  else
    console.log """
      ---------- result ------------
           physical lines:  #{r.loc}
             source lines:  #{r.sloc}
      total comment lines:  #{r.cloc}
      block comment lines:  #{r.bcloc}
              empty lines:  #{r.nloc}
      ------------------------------
      """

programm
  .version('0.0.1')
  .usage('[option] <file>|<directory>')
  .option('-j, --json', 'return JSON object')
  .option('-s, --sloc', 'print only number of source lines')

programm.parse(process.argv)

stats = fs.lstatSync programm.args[0]

if stats.isDirectory() then parseDir  programm.args[0], print
else if stats.isFile() then parseFile programm.args[0], print
