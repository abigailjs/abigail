# Dependencies
Utility= (require './utility').Utility

Promise= require 'bluebird'
npmPath= require 'npm-path'
parse= (require 'shell-quote').parse

exec= (require 'child_process').exec
spawn= require 'win-spawn'
fork= (require 'child_process').fork

# Environment
npmPath()# Update the process.env

class Queue extends Utility
  constructor: (scripts=[],@options={})->
    @queues= Promise.resolve []
    @pending= []
    @push script for script in scripts

  push: (script)->
    @push script.pre if script.pre?

    @queues=
      @queues.then (codes)=>
        process=
          switch
            when script.pipe then @exec script
            when script.fork then @fork script
            else @spawn script
        
        process.then (code)=>
          codes.push code
          return Promise.reject codes unless code is 0 or (@options.force or @options.f)
          codes

    @push script.post if script.post?

    this

  last: (fn)->
    exitCodes= null

    @queues
    .then (codes)->
      exitCodes= codes
    .catch (codes)->
      exitCodes= codes
    .finally =>
      for child in @pending
        child.removeAllListeners()
        child.kill()

      fn exitCodes

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

  fork: (script)->
    options=
      cwd: process.cwd()
      env: process.env
      stdio: 'inherit'
    options.stdio= 'ignore' if @options.test

    [bin,args...]= parse script

    @log "Run #{@strong(script)}"

    new Promise (resolve)=>
      child= fork bin,args,options

      child.on 'message',(message)=>
        return if message?.abigail isnt 'pending'
        @log "Pending #{@strong(script)}."
        @pending.push child

        resolve 0

      child.on 'error',(error)=>
        @log @sweat+" Failed #{@strong(script)}. Due to #{error}..."
        resolve 1

      child.on 'exit',(code)=>
        @log "Done #{@strong(script)}. Exit code #{@strong(code)}."
        resolve code

module.exports.Queue= Queue
