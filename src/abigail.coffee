# Dependencies
chalk= require 'chalk'
minimist= require 'minimist'

path= require 'path'
fs= require 'fs'

Maid= require './maid'

class Abigail extends require './utility'
  cli: (argv,stdout=on)->
    [tasks,options,scripts]= @parse argv,stdout
    @help() if tasks.length is 0 or '-v' in argv

    if stdout
      @log "Using #{chalk.bgRed('./package.json')}" if Object.keys(scripts).length
      @log ';;',"Not found #{chalk.bgRed('./package.json')}" if Object.keys(scripts).length is 0

    maids= []
    for task in tasks
      maids.push new Maid task,options

    process.on 'exit',->
      maid.close() for maid in maids

    maids

  parse: (argv,stdout=yes)->
    args= minimist argv

    try
      scripts= require(require('path').join process.cwd(),'package').scripts
    catch
    finally
      scripts?= {}

    tasks= []
    for arg in args._
      [glob,raw]= arg.split ':'

      task= {}
      task.glob= glob#.replace /@/g,'*'#
      task.raw= raw?.replace /(^'|'$)/g,''
      task.script= "npm run #{raw}"
      task.script= task.raw if scripts?[raw] is undefined
      tasks.push task

    options= {}
    options.execute= yes if args.execute or args.e
    options.ignored= @getIgnored(stdout) if args.ignore or args.i

    [tasks,options,scripts]

module.exports= Abigail