# Dependencies
Utility= (require './utility').Utility

Promise= require 'bluebird'
npmPath= require 'npm-path'
exec= (require 'child_process').exec
spawn= require 'win-spawn'

# Environment
npmPath()# Update the process.env

class Queue extends Utility
  constructor: (scripts=[])->
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

    @log "Run #{@strong(script)} (using pipe...)"

    new Promise (resolve)=>
      exec script,options,(error,stdout,stderr)=>
        
        console.log stdout
        console.log stderr

        if error?
          @log @sweat+" Failed #{@strong(script)}."
          resolve 1
        else
          @log "Done #{@strong(script)}."
          resolve 0

  spawn: (script)->
    options=
      cwd: process.cwd()
      env: process.env
      stdio:'inherit'
    options.stdio= 'ignore' if @test

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      [bin,args...]= script.split /\s+/
      
      child= spawn bin,args,options
      child.on 'error',(error)=>
        @log @sweat+" Failed #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code
    
module.exports.Queue= Queue