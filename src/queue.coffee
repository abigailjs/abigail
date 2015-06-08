# Dependencies
Utility= (require './utility').Utility

Promise= require 'bluebird'
npmPath= (require 'npm-path')()
{exec,spawn}= require 'child_process'

class Queue extends Utility
  constructor: (scripts=[],@PATH=npmPath)->
    @queues= Promise.resolve []
    @push script for script in scripts

  push: (script)->
    @push script.pre if script.pre?

    @queues=
      @queues.then (codes)=>
        process= if script.pipe then @exec script else @spawn script
        process.then (code)->
          codes.push code
          codes

    @push script.post if script.post?

  then: (fn)->
    @queues.then fn

  exec: (script)->
    options=
      cwd: process.cwd()
      env: process.env
    options.env.PATH= @PATH

    @log "Run #{@strong(script)} (using pipe...)"

    new Promise (resolve)=>
      exec script,options,(error,stdout,stderr)=>
        if error?
          @log @sweat+" Failing #{@strong(script)}. Due to #{error}..."
          resolve 1
        else
          @log "Done #{@strong(script)}. Stdout/stderr: #{stdout+stderr}"
          resolve 0

  spawn: (script)->
    options=
      cwd: process.cwd()
      env: process.env
      stdio:'inherit'
    options.env.PATH= @PATH
    options.stdio= 'ignore' if @test

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      [bin,args...]= script.split /\s+/
      
      child= spawn bin,args,options
      child.on 'error',(error)=>
        @log @sweat+" Failing #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code
    
module.exports.Queue= Queue