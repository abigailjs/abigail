# Dependencies
chalk= require 'chalk'

pkg= require '../package'
path= require 'path'

# Private
elapsed= Date.now()

# Public
class Utility
  log: (args...)->
    ms= chalk.gray '+ '+(('   '+@getElapsed()).slice -6)
    output= [ms,@icon].concat args
    
    return output if @test or @options?.test

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
    text+= "\n    $ #{chalk.inverse('abigail compile PKG')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['*','src/**','test/**'])} for #{@strong('compile')}"
    text+= "\n      > #{@icon} Run #{@strong('compile')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail _compile PKG')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['*','src/**','test/**'])} for #{@strong('compile')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail compile PKG,_src/**')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['*','src/**','test/**','!_src/**'])} for #{@strong('compile')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail hint PKG,.jshintrc')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['*','src/**','test/**','.jshintrc'])} for #{@strong('hint')}"
    text+= "\n      > #{@icon} Run #{@strong('hint')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail test,hint PKG')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts(['*','src/**','test/**'])} for #{@strong(['test','hint'])}"
    text+= "\n      > #{@icon} Begin #{@strong(['test','hint'])} ..."
    text+= "\n      > #{@icon} Run #{@strong('test')}"
    text+= "\n      > ..."
    text+= "\n      > #{@icon} Run #{@strong('hint')}"
    text+= "\n      > ..."
    text+= "\n  "
    text+= "\n    $ #{chalk.inverse('abigail \'echo cool\' "*.md"')}"
    text+= "\n      > #{@icon} Watch #{@whereabouts('*.md')} for #{@strong('echo cool')}"
    text+= "\n      > #{@icon} Run #{@strong('echo cool')}"
    text+= "\n      > ..."
    text+= "\n  "

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

  getElapsed: ->
    suffix= ' ms'

    diff= Date.now()-elapsed ? 0
    elapsed= Date.now()

    if diff>1000
      diff= ~~(diff/1000)
      suffix= '  s'
      if diff>60
        diff= ~~(diff/60)
        suffix= 'min'
        if diff>60
          diff= ~~(diff/60)
          suffix= ' hr'

    diff+suffix

module.exports.Utility= Utility