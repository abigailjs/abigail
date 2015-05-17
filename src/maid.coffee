# Dependencies
path= require 'path'
spawn= (require 'child_process').spawn

watch= require 'glob-watcher'
chalk= require 'chalk'

class Maid extends require './utility'
  constructor: (task,@options)->
    @glob= task.glob
    @raw= task.raw
    @script= task.script

    @busy= yes

    glob= @glob
    glob= glob.concat @options.ignored if @options.ignored?
    @watch= watch glob
    @watch.on 'ready',=>
      @log "Start watching #{chalk.underline(@glob)} for #{chalk.cyan(@script)}"
      @busy= no

      @task() if @options.execute

    @count= 0
    @watch.on 'add',(dir)=>
      @count++

      @log 'File',chalk.underline(dir),'has been added.' if not @busy
      @task()
    @watch.on 'unlink',(file)=>
      @count--
      @log 'File',chalk.underline(path.relative process.cwd(),file.path),'has been deleted.' if not @busy
      @task()
    @watch.on 'change',(file)=>
      @log 'File',chalk.underline(path.relative process.cwd(),file.path),'has been changed.' if not @busy
      @task()
    @watch.on 'error',=> @log ';;','error',arguments

  task: ->
    return if @busy

    @log "Execute #{chalk.cyan(@script)}"
    @busy= yes

    [bin,args...]= @script.split /\s+/
    child= spawn bin,args,{cwd:process.cwd(),stdio:'inherit'}
    child.on 'error',(error)=>
      @log ';;',"Broken #{chalk.cyan(@script)}, Due to #{error}."
      @busy= no
    child.on 'exit',(code)=>
      @log "Finished #{chalk.cyan(@script)}, Exit code #{code}."
      @busy= no
    child

  close: ->
    return if @watch is undefined

    @log "Stop #{chalk.cyan(@script)}"
    @busy= yes

    @watch.close()
    delete @watch

module.exports= Maid