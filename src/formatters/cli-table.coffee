Table = require 'cli-table'
i18n  = require '../i18n'
sloc  = require '../sloc'

module.exports = (data, options, fmtOpts) ->

  keys = options.keys or sloc.keys

  heads = if options.details then ['Path', keys...] else keys

  head = if 'no-head' in fmtOpts then [] else (i18n.en[k] for k in heads)

  table = new Table { head }

  statToArray = (d) -> d[k] for k in keys

  if options.details
    table.push [f.path, statToArray(f.stats)...] for f in data.files

  else if (s = data.summary)?
    table.push statToArray s

  table.toString()
