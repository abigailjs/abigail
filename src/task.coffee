# Dependencies
Utility= (require './utility').Utility

gaze= require 'gaze'
Promise= require 'bluebird'

path= require 'path'
spawn= (require 'child_process').spawn

# Public
class Task extends Utility
  constructor: (@scripts=[],globs=[],@test=false)->
    @globs= @toAbsolute globs

    gaze @globs,(error,@watcher)=>
      throw error if error?

      if @globs.length
        @log "Watch #{@whereabouts(globs)} for #{@strong(@scripts)}."

      @busy= no
      @execute @scripts unless @scripts[0]?.lazy

      @watcher.on 'all',(event,filepath)=>
        return if @busy

        name= path.relative process.cwd(),filepath
        @log 'File',@whereabouts(name),event

        @execute @scripts

  toAbsolute: (globs)->
    for glob in globs
      blacklist= glob[0] is '!'
      glob= glob.slice 1 if blacklist

      globAbsolute= path.resolve process.cwd(),glob
      globAbsolute= '!'+globAbsolute if blacklist
      globAbsolute

  execute: (scripts)->
    return if @busy

    @busy= yes

    if scripts.length>1
      @log "Begin #{@strong(scripts)} ..."

    codes= []

    queues= Promise.resolve()
    for script,i in scripts
      do (script,i)=>
        queues=
          queues.then =>
            @spawn script
            .then (code)->
              codes.push code
    
    queues.then =>

      @busy= no

      if scripts.length>1
        @log "End #{@strong(scripts)}. Exit code #{@strong(codes)}."

      if @noWatch
        process.exit ~~(1 in codes)

      codes

  spawn: (script)->
    [bin,args...]= script.split /\s+/
    options=
      cwd: process.cwd()
      stdio:'inherit'
    options.stdio= 'ignore' if @test

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      child= spawn bin,args,options

      child.on 'error',(error)=>
        @log @sweat+" Failing #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code

module.exports.Task= Task