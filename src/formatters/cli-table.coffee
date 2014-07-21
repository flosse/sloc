Table = require 'cli-table'
i18n  = require '../i18n'
sloc  = require '../sloc'

module.exports = (data, options={}) ->

  headers = for h in ['Path', sloc.keys...]
    i18n.en[h]

  table = new Table head: headers

  statToArray = (d) -> d[k] for k in sloc.keys

  if options.details
    table.push [f.path, statToArray(f.stats)...] for f in data.files
  else if (s = data.summary)?
    table.push statToArray s

  table.toString()
