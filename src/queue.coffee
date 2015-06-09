# Dependencies
Utility= (require './utility').Utility

Promise= require 'bluebird'
npmPath= require 'npm-path'
exec= (require 'child_process').exec

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
        process= @exec script
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
      maxBuffer: 1024*1024* 10# MB

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

module.exports.Queue= Queue