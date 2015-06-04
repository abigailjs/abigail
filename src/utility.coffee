# Dependencies
chalk= require 'chalk'

pkg= require '../package'
path= require 'path'

# Public
class Utility
  log: (args...)->
    elapsed= chalk.gray ('     +'+@getElapsed()).slice -8
    output= [elapsed,@icon].concat args
    
    return output if @test

    console.log output...

  json: (arg)->
    chalk.bgRed arg

  strong: (args,conjunctive=', ')->
    args= [args] unless args instanceof Array
    args= (arg?.raw ? arg for arg in args)

    (chalk.underline arg for arg in args).join conjunctive

  whereabouts: (args,conjunctive=' and ')->
    args= [args] unless args instanceof Array
    args= [chalk.red('undefined')] if args[0] is undefined

    (chalk.underline arg for arg in args).join conjunctive

  help: ->
    text= ""
    
    text+= "\n  #{@icon} Abigail v#{pkg.version}"
    text+= "\n  "
    text+= "\n  Usage:"
    text+= "\n    $ abigail #{@strong('scripts')} #{@whereabouts('globs')} [#{@strong('scripts')} #{@whereabouts('globs')}] ..."
    text+= "\n  "
    text+= "\n  Example:"
    text+= "\n    $ #{chalk.inverse('abigail compile "*.coffee"')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts('*.coffee')} for #{@strong('npm run compile')}"
    text+= "\n      > #{@icon} Run #{@strong('compile')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail test test/**,src/**')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['test/**','src/**'])} for #{@strong('test')}"
    text+= "\n      > #{@icon} Run #{@strong('test')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail test,lint test/**,src/**')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['test/**','src/**'])} for #{@strong('test')}"
    text+= "\n      > #{@icon} Begin #{@strong(['test','lint'])} ..."
    text+= "\n      > #{@icon} Run #{@strong('test')}"
    text+= "\n      > ..."
    text+= "\n      > #{@icon} Run #{@strong('lint')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail \'echo cool\' "*.md"')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts('*.md')} for #{@strong('echo cool')}"
    text+= "\n      > #{@icon} Run #{@strong('echo cool')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail _test test/**,src/**')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['test/**','src/**'])} for #{@strong('test')}"
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail _test test/**,_src/**')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['test/**','!src/**'])} for #{@strong('test')}"
    text+= "\n"

    @output text

  version: ->
    @output "v#{pkg.version}"

  output: (text)->
    return text if @test

    console.log text
    process.exit 0

  # Private
  icon: chalk.magenta '@'+chalk.underline(' ')+'@'
  sweat: chalk.magenta ';'

  elapsed: Date.now()
  getElapsed: ->
    suffix= ' ms'

    diff= Date.now()-@elapsed ? 0
    @elapsed= Date.now()

    if diff>1000
      diff= ~~(diff/1000)
      suffix= 'sec'
      if diff>60
        diff= ~~(diff/60)
        suffix= 'min'
        if diff>60
          diff= ~~(diff/60)
          suffix= ' hr'

    diff+suffix

module.exports.Utility= Utility