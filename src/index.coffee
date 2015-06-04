# Dependencies
Utility= (require './utility').Utility
Task= (require './task').Task

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
      @log "Use #{@json('./package.json')}"

    catch
      @scripts= {}
      @log "Missing #{@json('./package.json')}"

    @args= @toArgs @_

    return if @test
    
    @tasks= []
    @tasks.push new Task scripts,globs,@test for {scripts,globs} in @args

    singleArgument= @tasks.length is 1 and @tasks[0].globs[0] is undefined
    if singleArgument
      @tasks[0].noWatch= on

  toArgs: (minimistArgv)->
    i= 0
    
    while minimistArgv[i]?
      names= minimistArgv[i++].split ','

      scripts=
        for name in names
          lazy= name[0] is '_'
          name= name.slice 1 if lazy

          script=
            if @scripts[name]?
              new String 'npm run '+name
            else
              new String name

          script.lazy= lazy
          script.raw= name

          script

      globs= minimistArgv[i++]?.split ','
      globs?= []

      globs= 
        for glob in globs
          glob.replace /^_/,'!'

      {scripts,globs}

module.exports= new Abigail
module.exports.Abigail= Abigail