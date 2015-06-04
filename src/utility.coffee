# Dependencies
chalk= require 'chalk'

pkg= require '../package'
path= require 'path'

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

  npm: (arg)->
    chalk.bgRed arg

  strong: (args,conjunctive=', ')->
    args= [args] unless args instanceof Array
    args= (arg?.raw ? arg for arg in args)

    (chalk.underline arg for arg in args).join(conjunctive)

  whereabouts: (args,conjunctive=' and ')->
    args= [args] if typeof args is 'string'
    args= [chalk.red('undefined')] if args[0] is undefined

    (chalk.underline arg for arg in args).join(conjunctive)

  help: ->
    log= console.log
    
    log ""
    log "  #{@icon} Abigail v#{pkg.version}"
    log "  "
    log "  Usage:"
    log "    $ abigail #{@strong('scripts')} #{@whereabouts('globs')} [#{@strong('scripts')} #{@whereabouts('globs')}] ..."
    log "  "
    log "  Example:"
    log "    $ #{chalk.inverse('abigail compile "*.coffee"')}"
    log "      > #{@icon} Watch #{@whereabouts('*.coffee')} for #{@strong('npm run compile')}"
    log "      > #{@icon} Run #{@strong('compile')}"
    log "      > ..."
    log "  "
    log "    $ #{chalk.inverse('abigail test test/**,src/**')}"
    log "      > #{@icon} Watch #{@whereabouts(['test/**','src/**'])} for #{@strong('test')}"
    log "      > #{@icon} Run #{@strong('test')}"
    log "      > ..."
    log "  "
    log "    $ #{chalk.inverse('abigail test,lint test/**,src/**')}"
    log "      > #{@icon} Watch #{@whereabouts(['test/**','src/**'])} for #{@strong('test')}"
    log "      > #{@icon} Begin #{@strong(['test','lint'])} ..."
    log "      > #{@icon} Run #{@strong('test')}"
    log "      > ..."
    log "      > #{@icon} Run #{@strong('lint')}"
    log "      > ..."
    log "  "
    log "    $ #{chalk.inverse('abigail \'echo cool\' "*.md"')}"
    log "      > #{@icon} Watch #{@whereabouts('*.md')} for #{@strong('echo cool')}"
    log "      > #{@icon} Run #{@strong('echo cool')}"
    log "      > ..."
    log "  "
    log "    $ #{chalk.inverse('abigail _test test/**,src/**')}"
    log "      > #{@icon} Watch #{@whereabouts(['test/**','src/**'])} for #{@strong('test')}"
    log "  "
    log "    $ #{chalk.inverse('abigail _test test/**,_src/**')}"
    log "      > #{@icon} Watch #{@whereabouts(['test/**','!src/**'])} for #{@strong('test')}"
    log ""

    process.exit 0

  version: ->
    log= console.log
    
    log "v#{pkg.version}"
    
    process.exit 0

module.exports.Utility= Utility