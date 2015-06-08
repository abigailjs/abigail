# Dependencies
Utility= (require './utility').Utility

gaze= require 'gaze'
Promise= require 'bluebird'
npmPath= (require 'npm-path')()

path= require 'path'
{exec,spawn}= require 'child_process'

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
            child=
              if script.pipe
                @exec script
              else
                @spawn script

            child
            .then (code)->
              codes.push code
    
    queues.then =>

      @busy= no

      if scripts.length>1
        @log "End #{@strong(scripts)}. Exit code #{@strong(codes)}."

      if @noWatch
        process.exit ~~(1 in codes)

      codes

  exec: (script)->
    options=
      cwd: process.cwd()
      env: process.env
    options.env.PATH= npmPath

    @log "Run #{@strong(script)} (exec)"

    new Promise (resolve)=>
      exec script,options,(error,stdout,stderr)=>
        if error?
          @log @sweat+" Failing #{@strong(script)}. Due to #{error}..."
          resolve 1
        else
          @log "Done #{@strong(script)}. "
          resolve 0

  spawn: (script)->
    [bin,args...]= script.split /\s+/
    options=
      cwd: process.cwd()
      env: process.env
      stdio:'inherit'
    options.env.PATH= npmPath
    options.stdio= 'ignore' if @test

    @log "Run #{@strong(script)} (spawn)"

    new Promise (resolve)=>
      child= spawn bin,args,options

      child.on 'error',(error)=>
        @log @sweat+" Failing #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code

module.exports.Task= Task