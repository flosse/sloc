sloc    = require '../sloc'
i18n    = require '../i18n'
helpers = require '../helpers'
align   = helpers.alignRight
col     = 20
colors  =
  source  : "green"
  comment : "cyan"
  empty   : "yellow"

stat = (data, options) ->

  if data.badFile
    return "#{align i18n.en.Error, col} :  #{i18n.en.BadFile}"

  str = for k in options.keys when (x = data.stats[k])?
    n = if (c = colors[k])? and (i = String(x)[c])? then i else x
    "#{align i18n.en[k], col} :  #{n}"

  str.join '\n'

module.exports = (data, options={}, fmtOpts) ->

  if options.keys?.length is 1 and not options.reportDetails
    return data.summary[options.keys[0]]

  if not options.keys?
    options.keys = sloc.keys

  result = "\n---------- #{i18n.en.Result} ------------\n\n"

  result += stat {stats: data.summary}, options

  badFiles = data.files.filter (x) -> x.badFile

  fileCount = data.files.length - badFiles.length
  result += "\n\n#{i18n.en.NumberOfFilesRead} :  #{fileCount}"

  if bl = badFiles.length > 0
    result += "\n#{align i18n.en.Brokenfiles, col} :  #{badFiles.length}"

  if options.details and data.files.length > 1
    result += "\n\n---------- #{i18n.en.Details} -----------\n"
    d = for f in data.files
      "\n\n--- #{f.path}\n\n#{stat f, options}"

    result += d.join ''

  result += "\n\n------------------------------\n"
