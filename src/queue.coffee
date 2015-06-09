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
  constructor: (scripts=[],@options={})->
    @queues= Promise.resolve []
    @push script for script in scripts

  push: (script)->
    @push script.pre if script.pre?

    @queues=
      @queues.then (codes)=>
        process= if script.pipe then @exec script else @spawn script
        process.then (code)=>
          codes.push code
          return Promise.reject codes unless code is 0 or (@options.force or @options.f)
          codes

    @push script.post if script.post?

    this

  last: (fn)->
    @queues.then fn,->
      # BUG? fixed unhandled rejection Error via 27:Promise.reject
    @queues.catch fn

  exec: (script)->
    options=
      cwd: process.cwd()
      env: process.env
      maxBuffer: 1024*1024* 1#MB

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      child= exec script,options
      child.stdout.pipe process.stdout unless @options.test
      child.stderr.pipe process.stderr unless @options.test

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
    options.stdio= 'ignore' if @options.test

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