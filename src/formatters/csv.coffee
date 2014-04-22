###
convert data to CSV format for easy import into spreadsheets
###

i18n = require '../i18n'

module.exports = (data, options) ->

  return new Error "missing data" unless data?

  headers = ['loc', 'sloc', 'cloc', 'scloc', 'mcloc', 'nloc']

  lines = "#{i18n.en.Path},#{(i18n.en[k] for k in headers).join ','}\n"

  lineize = (t) ->
    "#{t.path or i18n.en.Total},#{(t[k] for k in headers).join ','}\n"

  if data.details
    for sf in data.details
      lines += lineize sf
  else
    lines += lineize data

  if lines[lines.length-1] is '\n'
    lines = lines.slice 0, -1
  lines
