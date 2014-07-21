Table = require 'cli-table'
i18n  = require '../i18n'
sloc  = require '../sloc'

module.exports = (data, options={}) ->

  keys = options.keys or sloc.keys

  heads = if options.details then ['Path', keys...] else keys

  table = new Table head: (i18n.en[k] for k in heads)

  statToArray = (d) -> d[k] for k in keys

  if options.details
    table.push [f.path, statToArray(f.stats)...] for f in data.files

  else if (s = data.summary)?
    table.push statToArray s

  table.toString()
