Table = require 'cli-table'
i18n  = require '../i18n'

module.exports = (data) ->

  keys = ['path', 'loc', 'sloc', 'cloc', 'scloc', 'mcloc', 'nloc']
  headers = for h in ['Path', keys[1...]...]
    i18n.en[h]

  table = new Table head: headers

  toArray = (d) ->
    for k in keys
      if k is 'path'
        d[k] or i18n.en.Total
      else
        d[k] or ''

  if data.details
    table.push toArray d for d in data.details
  else
    table.push toArray data

  table.toString()
