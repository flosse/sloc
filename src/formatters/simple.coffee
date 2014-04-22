i18n    = require '../i18n'
helpers = require '../helpers'
align   = helpers.alignRight
col     = 20

BAD_FILE    = i18n.en.BadFile
BAD_FORMAT  = i18n.en.BadFormat
BAD_DIR     = i18n.en.BadDir

stat = (data, options={}) ->

  if data.err
    return "#{align i18n.en.Error, col} :  #{data.err}"

  if options.sloc
   return data.sloc

  """
  #{align i18n.en.loc,   col} :  #{data.loc}
  #{align i18n.en.sloc,  col} :  #{data.sloc}
  #{align i18n.en.cloc,  col} :  #{data.cloc}
  #{align i18n.en.scloc, col} :  #{data.scloc}
  #{align i18n.en.mcloc, col} :  #{data.mcloc}
  #{align i18n.en.nloc,  col} :  #{data.nloc}
  """

module.exports = (data, options) ->

  result = "\n---------- #{i18n.en.Result} ------------\n\n"

  result += stat data, options

  if data.filesRead?
    result += "\n\n#{i18n.en.NumberOfFilesRead} :  #{data.filesRead}"

  if data[BAD_FORMAT]
    result += "\n#{align i18n.en.UnknownSourceFiles, col} :  #{data[BAD_FORMAT]}"

  if data[BAD_FILE]
    result += "\n#{align i18n.en.Brokenfiles, col} :  #{data[BAD_FILE]}"

  if data[BAD_DIR]
    result += "\n#{align i18n.en.BrokenDirectories, col} :  #{data[BAD_DIR]}"

  if data.details?
    result += "\n\n---------- #{i18n.en.Details} -----------\n"
    d = for detail in data.details
      "\n--- #{detail.path}\n\n#{stat detail, options}\n"

    result += d.join ''

  result += "\n\n------------------------------\n"
