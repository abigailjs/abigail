# Dependencies
Utility= (require './utility').Utility

gaze= require 'gaze'
Promise= require 'bluebird'

path= require 'path'
spawn= (require 'child_process').spawn

class Task extends Utility
  constructor: (@scripts=[],@globs=[],test=false)->
    @busy= no

    @globs=
      for glob in @globs
        blacklist= glob[0] is '!'
        glob= glob.slice 1 if blacklist

        globAbsolute= path.resolve process.cwd(),glob
        globAbsolute= '!'+globAbsolute if blacklist
        globAbsolute

    return if test

    gaze @globs,(error,watcher)=>
      throw error if error?

      unless @noWatch
        @log "Watch #{@whereabouts(@globs)} for #{@strong(@scripts)}."

      @execute @scripts unless @scripts[0].lazy

      watcher.on 'all',(event,filepath)=>
        return if @busy

        name= path.relative process.cwd(),filepath
        @log 'File',@whereabouts(name),event

        @execute @scripts

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
            console.log '' if i>0 # margin-top

            @spawn script
            .then (code)->
              codes.push code
    
    queues.then =>

      @busy= no

      if scripts.length>1
        @log "End #{@strong(scripts)}. Exit code #{@strong(codes)}."

      if @noWatch
        process.exit ~~(1 in codes)

  spawn: (script)->
    [bin,args...]= script.split /\s+/

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      child= spawn bin,args,{cwd:process.cwd(),stdio:'inherit'}

      child.on 'error',(error)=>
        @log ';;',"Failing #{@strong(script)}, Due to #{error}."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code

module.exports.Task= Task