# Dependencies
Utility= (require './utility').Utility

Promise= require 'bluebird'
npmPath= require 'npm-path'
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
        process= @spawn script
        process.then (code)->
          codes.push code
          codes

    @push script.post if script.post?

  then: (fn)->
    @queues.then fn

  spawn: (script)->
    options=
      cwd: process.cwd()
      env: process.env
      stdio: 'inherit'
    options.stdio= 'ignore' if @test

    [bin,args...]= script.match /\$\(.*?\)|".*?"|'.*?'|[^\s]+/g

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