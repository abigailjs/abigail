# Dependencies
Utility= (require './utility').Utility

gaze= require 'gaze'
chalk= require 'chalk'

path= require 'path'
spawn= (require 'child_process').spawn

class Task extends Utility
  constructor: (@script,@globs=[],@lazy=false,debug=false)->
    @process= null

    @log "Watch #{@whereabouts(@globs)} for #{@strong(@script)}."

    @globs=
      for glob in @globs
        blacklist= glob[0] is '!'
        glob= glob.slice 1 if blacklist

        globAbsolute= path.resolve process.cwd(),glob
        globAbsolute= '!'+globAbsolute if blacklist
        globAbsolute

    return if debug

    gaze @globs,(error,watcher)=>
      throw error if error?

      @execute() unless @lazy

      watcher.on 'all',(event,filepath)=>
        return if @process

        name= path.relative process.cwd(),filepath
        @log 'File',@whereabouts(name),event
        @execute()

  execute: ->
    return if @process

    @log "Execute #{@strong(@script)}"

    [bin,args...]= @script.split /\s+/

    @process= spawn bin,args,{cwd:process.cwd(),stdio:'inherit'}
    @process.on 'error',(error)=>
      @log ';;',"Failing #{@strong(@script)}, Due to #{error}."
      @process= null
    @process.on 'exit',(code)=>
      @log "Finish #{@strong(@script)}, Exit code #{code}."
      @process= null
    @process

module.exports.Task= Task