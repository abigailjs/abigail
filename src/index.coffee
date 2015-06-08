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

      scripts= (@toScript name for name in names)
      globs= minimistArgv[i++]?.split ','
      globs?= []
      if globs[0] is 'PKG'
        globs= ['*','src/**','test/**']

      globs= 
        for glob in globs
          glob.replace /^_/,'!'

      {scripts,globs}

  toScript: (name,hook=on)->
    lazy= name[0] is '_'
    name= name.slice 1 if lazy

    script=
      if @scripts[name]?
        new String @scripts[name]
      else
        new String name

    script.pipe= no
    for arg in script.toString().match /".*?"|'.*?'|[^\s]+/g
      continue if arg.match /^"|"$|^'|'$/g
      script.pipe= yes if arg.match(/\||>|</)?

    script.lazy= lazy
    script.raw= name
    if script.raw isnt script.toString() and hook
      script.pre= @toScript 'pre'+name,off if @scripts['pre'+name]?
      script.post= @toScript 'post'+name,off if @scripts['pre'+name]?

    script

module.exports= new Abigail
module.exports.Abigail= Abigail