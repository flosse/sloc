module.exports = (res, options, fmtOpts) ->
  JSON.stringify res, null, (if 'no-indent' in fmtOpts then 0 else 2)
