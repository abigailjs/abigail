# Dependencies
Utility= (require './utility').Utility
Task= (require './task').Task

minimist= require 'minimist'
parse= (require 'shell-quote').parse

path= require 'path'
fs= require 'fs'

# Public
class Abigail extends Utility
  parse: (argv,stdout=on)->
    @[key]= value for key,value of minimist argv.slice 2

    @version() if @V or @v
    @help() if @_.length is 0

    try
      @scripts= (require path.join process.cwd(),'package').scripts
      @log "Use #{@json('./package.json')}"

    catch
      @log "Missing #{@json('./package.json')}"
    @scripts?= {}

    @args= @toArgs @_

    return if @test
    
    @tasks= []
    @tasks.push new Task scripts,globs,this for {scripts,globs} in @args

    singleArgument= @tasks.length is 1 and @tasks[0].globs[0] is undefined
    if singleArgument
      @tasks[0].noWatch= on

  toArgs: (minimistArgv)->
    i= 0
    
    while minimistArgv[i]?
      names= minimistArgv[i++].split ','

      scripts= (@toScript name for name in names)
      watch= minimistArgv[i++]?.split ','
      watch?= []

      globs= []
      for glob in watch
        if glob is 'PKG'
          globs= globs.concat ['*','src/**','test/**']
        else
          globs.push glob.replace /^_/,'!'

      {scripts,globs}

  toScript: (name,hook=on)->
    lazy= name[0] is '_'
    name= name.slice 1 if lazy

    script=
      if @scripts[name]?
        new String @scripts[name]
      else
        new String name

    script.defined= @scripts[name]?
    script.fork= fs.existsSync path.join process.cwd(),script.toString()
    script.pipe= no
    for arg in parse script.toString()
      script.pipe= yes if typeof arg is 'object'

    script.lazy= lazy
    script.raw= name
    if script.raw isnt script.toString() and hook
      script.pre= @toScript 'pre'+name,off if @scripts['pre'+name]?
      script.post= @toScript 'post'+name,off if @scripts['post'+name]?

    script

module.exports= new Abigail
module.exports.Abigail= Abigail
