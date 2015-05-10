EventEmitter= require('events').EventEmitter
spawn= require('child_process').spawn

spawnVerbose= (args,options={},timeout=1000)->
  manager= new EventEmitter

  setTimeout ->
    child.kill()
  ,timeout
  [bin,args...]= args
  options.cwd?= process.cwd()
  options.silent?= yes

  console.log '' unless options.silent

  error= stdout= stderr= ''
  child= spawn bin,args,options
  child.on 'error',(error)->
    error+= error.stack.toString()
    console.error 'Error:',error.stack.toString() unless options.silent

  child.stdout.on 'data',(buffer)->
    stdout+= buffer.toString()
    process.stdout.write buffer unless options.silent

  child.stderr.on 'data',(buffer)->
    stderr+= buffer.toString()
    process.stderr.write buffer unless options.silent

  child.on 'exit',(code)->
    manager.emit 'exit',code,error,stdout,stderr

  manager

module.exports= spawnVerbose