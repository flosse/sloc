###
This program is distributed under the terms of the GPLv3 license.
Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

fs        = require 'fs'
async     = require 'async'
sloc      = require './sloc'
programm  = require 'commander'

BAD_FILE_ERR    = new Error "bad file"
BAD_FORMAT_ERR  = new Error "bad format"

getExtension = (f) ->
  i = f.lastIndexOf '.'
  if i < 0 then '' else f.substr(i)[1...]

parseFile = (f, cb) ->
  fs.readFile f, "utf8", (err, code) ->
    if err?
      cb? BAD_FILE_ERR
    else
      try
        cb? null, sloc code, getExtension f
      catch e
        cb? BAD_FORMAT_ERR

parseDir = (dir, cb) ->

  badFileCounter   = 0
  badFormatCounter = 0

  files = ("#{dir}/#{f}" for f in fs.readdirSync dir)

  parseFunctions = []

  for f in files then do (f) ->
    parseFunctions.push (next) ->
      parseFile f, (err, res) ->
        if err?
          switch err
            when BAD_FORMAT_ERR then badFormatCounter++
            when BAD_FILE_ERR   then badFileCounter++
        next null, res

  async.parallel parseFunctions, (err, res) ->
    if err?
      cb err
    else
      res = (r for r in res when r?)
      numberOfFiles = res.length
      res = res.reduce (a,b) ->
        o = {}
        o[k] = a[k] + b[k] for k,v of a
        o
      res.badFiles   = badFileCounter
      res.badFormats = badFormatCounter
      res.filesRead  = numberOfFiles
      cb null, res

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
            physical lines :  #{r.loc}
      lines of source code :  #{r.sloc}
             total comment :  #{r.cloc}
                singleline :  #{r.scloc}
                 multiline :  #{r.mcloc}
                     empty :  #{r.nloc}
      ------------------------------
      """

    if r.filesRead?
      console.log """
        number of files read :  #{r.filesRead}
        """
    if r.badFiles? or r.badFormats?
      console.log """
        unknown source files :  #{r.badFormats}
                broken files :  #{r.badFiles}
        ------------------------------
        """

programm
  .version('0.0.2')
  .usage('[option] <file>|<directory>')
  .option('-j, --json', 'return JSON object')
  .option('-s, --sloc', 'print only number of source lines')

programm.parse process.argv

if programm.args.length < 1
  programm.help()

else
  stats = fs.lstatSync programm.args[0]

  if stats.isDirectory() then parseDir  programm.args[0], print
  else if stats.isFile() then parseFile programm.args[0], print
