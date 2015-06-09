# Dependencies
Utility= (require './utility').Utility

Promise= require 'bluebird'
npmPath= require 'npm-path'
parse= (require 'shell-quote').parse

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
      maxBuffer: 1024*1024* 1#MB

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      child= exec script,options
      child.stdout.pipe process.stdout
      child.stderr.pipe process.stderr

      child.on 'error',(error)=>
        @log @sweat+" Failed #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'close',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code

  spawn: (script)->
    options=
      cwd: process.cwd()
      env: process.env
      stdio: 'inherit'
    options.stdio= 'ignore' if @test

    [bin,args...]= parse script

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      child= spawn bin,args,options

      child.on 'error',(error)=>
        @log @sweat+" Failed #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code

module.exports.Queue= Queue