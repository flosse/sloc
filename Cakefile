fs     = require 'fs'
{exec} = require 'child_process'
coffee = require 'coffee-script'

isCoffeeFile = (f) -> (f.indexOf('.coffee') isnt -1) and (f[0] isnt '.')

watchDir = (dir) ->

  console.log "Watching for changes in #{dir}"
  files = fs.readdirSync "#{dir}"
  files = ("#{dir}/#{f}" for f in files when isCoffeeFile f)
  for file in files then do (file) ->
    fs.watchFile file, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "Saw change in #{file}"
        invoke 'build'

checkDir = (d) -> fs.mkdirSync d if not fs.existsSync d
checkTargetDir = -> checkDir targetDir

task 'build', 'compile sources', ->
  exec "coffee -c -o lib src", (err, stdout, stderr) ->
    console.error err if err
    console.error stderr if stderr

task 'watch', 'Watch source files and build changes', ->

  invoke "build"
  watchDir "src"
