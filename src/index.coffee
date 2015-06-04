# Dependencies
Utility= (require './utility').Utility
Task= (require './task').Task

chalk= require 'chalk'
minimist= require 'minimist'

path= require 'path'
fs= require 'fs'

# Public
class Abigail extends Utility
  parse: (argv,stdout=on)->
    @[key]= value for key,value of minimist argv.slice 2

    @version() if @V
    @help() if @_.length is 0

    try
      @scripts= (require path.join process.cwd(),'package').scripts
      @log "Use #{chalk.bgRed('./package.json')}" unless @test

    catch
      @scripts= {}
      @log "Missing #{chalk.bgRed('./package.json')}" unless @test

    i= 0
    @args=
      while @_[i]?
        names= @_[i++].split ','

        scripts=
          for name in names
            lazy= name[0] is '_'
            name= name.slice 1 if lazy

            script= new String(if @scripts[name]? then 'npm run '+name else name)
            script.lazy= lazy
            script.raw= name
            script

        globs= @_[i++]?.split ','
        globs?= []
        globs= (glob.replace /^_/,'!' for glob in globs)

        {scripts,globs}

    return if @test
    
    @tasks= []
    @tasks.push new Task scripts,globs for {scripts,globs} in @args

module.exports= new Abigail
module.exports.Abigail= Abigail