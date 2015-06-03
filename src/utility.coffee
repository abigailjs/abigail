# Dependencies
chalk= require 'chalk'

pkg= require '../package'
path= require 'path'
fs= require 'fs'

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

  strong: (arg)->
    chalk.cyan arg

  whereabouts: (args,conjunctive=' and ')->
    args= [args] if typeof args is 'string'
    args= [chalk.red('undefined')] if args[0] is undefined

    (chalk.underline arg for arg in args).join(conjunctive)

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
    log= console.log
    
    log ""
    log "  #{@icon} Abigail v#{pkg.version}"
    log "  "
    log "  Usage:"
    log "    $ abigail #{@strong('script')} #{@whereabouts('globs')} [#{@strong('script')} #{@whereabouts('globs')}] ..."
    log "  "
    log "  Example:"
    log "    $ #{chalk.inverse('abigail compile "*.coffee"')}"
    log "      > #{@icon} Watch #{@whereabouts('*.coffee')} for #{@strong('npm run compile')}"
    log "      > #{@icon} Execute #{@strong('npm run compile')}"
    log "      > ..."
    log "  "
    log "    $ #{chalk.inverse('abigail test test/**/*.es6,src/**/*.es6')}"
    log "      > #{@icon} Watch #{@whereabouts(['test/**/*.es6','src/**/*.es6'])} for #{@strong('npm run test')}"
    log "      > #{@icon} Execute #{@strong('npm run test')}"
    log "      > ..."
    log "  "
    log "    $ #{chalk.inverse('abigail \'echo cool\' "*.md"')}"
    log "      > #{@icon} Watch #{@whereabouts('*.md')} for #{@strong('echo cool')}"
    log "      > #{@icon} Execute #{@strong('echo cool')}"
    log "      > ..."
    log ""

    process.exit 0

  version: ->
    log= console.log
    
    log "v#{pkg.version}"
    
    process.exit 0

module.exports.Utility= Utility