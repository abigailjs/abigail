class Abigail
  cli: (argv)->
    [tasks,options,scripts]= @parse argv
    @help() if tasks.length is 0 or '-v' in argv

    @log "Using #{chalk.bgRed('./package.json')}" if Object.keys(scripts).length
    @log ';;',"Not found #{chalk.bgRed('./package.json')}" if Object.keys(scripts).length is 0

    maids= []
    for task in tasks
      maids.push new @Maid task,options

    process.on 'exit',->
      maid.close() for maid in maids

  parse: (argv)->
    args= require('minimist') argv

    try
      scripts= require(require('path').join process.cwd(),'package').scripts
    catch
      scripts?= {}

    tasks= []
    for arg in args._
      [glob,raw]= arg.split ':'

      task= {}
      task.glob= glob#.replace /@/g,'*'#
      task.raw= raw?.replace /(^'|'$)/g,''
      task.script= "npm run #{raw}"
      task.script= task.raw if scripts[raw] is undefined
      tasks.push task

    options= {}
    options.execute= yes if args.execute or args.e
    options.ignored= @getIgnored() if args.ignore or args.i

    [tasks,options,scripts]

  getIgnored: ->
    home= process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

    paths= []
    try
      homeIgnore= fs.readFileSync(path.join home,'.gitignore').toString()
      paths= paths.concat homeIgnore.trim().split '\n'

      cwdIgnore= fs.readFileSync(path.join process.cwd(),'.gitignore').toString()
      paths= paths.concat cwdIgnore.trim().split '\n'
    catch

    @log "Using #{chalk.gray('./.gitignore')} and #{chalk.gray('~/.gitignore')}"

    paths

  _log: Date.now()
  log: (args...)->
    suffix= ' ms'
    diff= Date.now()-@_log ? 0
    if diff>1000
      diff= ~~(diff/1000)
      suffix= 'sec'
      if diff>60
        diff= ~~(diff/60)
        suffix= 'min'
        if diff>60
          diff= ~~(diff/60)
          suffix= ' hr'
    console.log ([chalk.gray(('     +'+diff+suffix).slice(-8)),@icon].concat args)...
    @_log= Date.now()

  Maid: class Maid extends Abigail
    constructor: (task,@options)->
      @glob= task.glob
      @raw= task.raw
      @script= task.script

      @busy= yes

      @watch= chokidar.watch @glob,@options
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
        @log 'File',chalk.underline(file),'has been deleted.' if not @busy
        @task()
      @watch.on 'change',(file,stats)=>
        @log 'File',chalk.underline(file),'has been changed.' if not @busy
        @task()
      @watch.on 'error',=> @log ';;','error',arguments

    task: ->
      return if @busy

      @log "Execute #{chalk.cyan(@script)}"
      @busy= yes

      [bin,args...]= @script.split /\s+/
      child= childProcess.spawn bin,args,{cwd:process.cwd(),stdio:'inherit'}
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

  help: ->
    # TODO markup

    console.log "  "
    console.log "  #{@icon} Abigail v#{require('./package').version}"
    console.log "  "
    console.log "  Usage:"
    console.log "    abigail #{chalk.underline('glob')}:#{chalk.cyan('script')} #{chalk.underline('glob')}:#{chalk.cyan('script')} ..."
    console.log "  "
    console.log "  Options:"
    console.log "    -e --execute : Execute #{chalk.cyan('script')} after ready"
    console.log "    -i --ignore  : Using #{chalk.gray('.gitignore')}, Exclude from the #{chalk.underline('glob')}"
    console.log "  "
    console.log "  Example:"
    console.log "    $ #{chalk.inverse('abigail *.coffee:compile')}"
    console.log "      > #{@icon} Start watching #{chalk.underline('*.coffee')} for #{chalk.cyan('npm run compile')}"
    console.log "  "
    console.log "    $ #{chalk.inverse('abigail *.coffee:compile --execute')}"
    console.log "      > #{@icon} Start watching  #{chalk.underline('*.coffee')} for #{chalk.cyan('npm run compile')}"
    console.log "      > #{@icon} Execute #{chalk.cyan('npm run compile')}"
    console.log "  "
    console.log "    $ #{chalk.inverse('abigail *.md:\'echo cool\'')}"
    console.log "      > #{@icon} Start watching #{chalk.underline('*.md')} for #{chalk.cyan('echo cool')}"
    console.log "  "
    console.log "    $ #{chalk.inverse('abigail **/*.jade:\'$(npm bin)/jade test/viaAvigail.jade -o .\'')}"
    console.log "      > #{@icon} Start watching #{chalk.underline('**/*.jade')} for #{chalk.cyan('$(npm bin)/jade test/viaAvigail.jade -o .')}"
    console.log "  "

    process.exit 0

{
  fs
  path
  childProcess

  minimist
  chokidar
  chalk
}= require('node-module-all') builtinLibs:true,change:'camelCase'

Abigail::icon= chalk.magenta '@'+chalk.underline(' ')+'@'

module.exports= new Abigail