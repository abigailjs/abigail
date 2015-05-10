# Dependencies
chalk= require 'chalk'
fs= require 'fs'
path= require 'path'
pkg= require '../package'

class Utility
  icon: chalk.magenta '@'+chalk.underline(' ')+'@'

  _log: Date.now()
  log: (args...)->
    suffix= ' ms'
    diff= Date.now()-@_log ? 0
    if diff>1000
      diff= ~~(diff/1000)
      suffix= 'sec'
      if diff>60
        diff= ~~(diff/60)
        suffix= 'min'
        if diff>60
          diff= ~~(diff/60)
          suffix= ' hr'
    console.log ([chalk.gray(('     +'+diff+suffix).slice(-8)),@icon].concat args)...
    @_log= Date.now()

  getIgnored: (stdout=yes)->
    home= process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
    
    paths= []
    try
      homeIgnore= fs.readFileSync(path.join home,'.gitignore').toString()
      paths= paths.concat homeIgnore.trim().split '\n'

      cwdIgnore= fs.readFileSync(path.join process.cwd(),'.gitignore').toString()
      paths= paths.concat cwdIgnore.trim().split '\n'
    catch

    if stdout
      @log "Using #{chalk.gray('./.gitignore')} and #{chalk.gray('~/.gitignore')}"

    paths= (path= '!'+path for path in paths)
    paths
  
  help: ->
    console.log "  "
    console.log "  #{@icon} Abigail v#{pkg.version}"
    console.log "  "
    console.log "  Usage:"
    console.log "    abigail #{chalk.underline('glob')}:#{chalk.cyan('script')} #{chalk.underline('glob')}:#{chalk.cyan('script')} ..."
    console.log "  "
    console.log "  Options:"
    console.log "    -e --execute : Execute #{chalk.cyan('script')} after ready"
    console.log "  "
    console.log "  Example:"
    console.log "    $ #{chalk.inverse('abigail *.coffee:compile')}"
    console.log "      > #{@icon} Start watching #{chalk.underline('*.coffee')} for #{chalk.cyan('npm run compile')}"
    console.log "  "
    console.log "    $ #{chalk.inverse('abigail *.coffee:compile --execute')}"
    console.log "      > #{@icon} Start watching  #{chalk.underline('*.coffee')} for #{chalk.cyan('npm run compile')}"
    console.log "      > #{@icon} Execute #{chalk.cyan('npm run compile')}"
    console.log "  "
    console.log "    $ #{chalk.inverse('abigail *.md:\'echo cool\'')}"
    console.log "      > #{@icon} Start watching #{chalk.underline('*.md')} for #{chalk.cyan('echo cool')}"
    console.log "  "
    console.log "    $ #{chalk.inverse('abigail **/*.jade:\'$(npm bin)/jade test/viaAvigail.jade -o .\'')}"
    console.log "      > #{@icon} Start watching #{chalk.underline('**/*.jade')} for #{chalk.cyan('$(npm bin)/jade test/viaAvigail.jade -o .')}"
    console.log "  "

    process.exit 0

module.exports= Utility