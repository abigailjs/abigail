# Dependencies
Utility= (require './utility').Utility
Queue= (require './queue').Queue

gaze= require 'gaze'
Promise= require 'bluebird'

path= require 'path'

# Public
class Task extends Utility
  constructor: (@scripts=[],globs=[],@test=false)->
    @globs= @toAbsolute globs

    gaze @globs,(error,@watcher)=>
      throw error if error?

      if @globs.length
        @log "Watch #{@whereabouts(globs)} for #{@strong(@scripts)}."

      @busy= no
      @run @scripts unless @scripts[0]?.lazy

      @watcher.on 'all',(event,filepath)=>
        return if @busy

        name= path.relative process.cwd(),filepath
        @log 'File',@whereabouts(name),event

        @run @scripts

  toAbsolute: (globs)->
    for glob in globs
      blacklist= glob[0] is '!'
      glob= glob.slice 1 if blacklist

      globAbsolute= path.resolve process.cwd(),glob
      globAbsolute= '!'+globAbsolute if blacklist
      globAbsolute

  run: (scripts)->
    return Promise.resolve [0] if @busy
    @busy= yes

    if scripts.length>1
      @log "Begin #{@strong(scripts)} ..."

    queue= new Queue scripts
    queue.test= yes if @test
    queue.then (codes)=>
      @busy= no

      if scripts.length>1
        @log "End #{@strong(scripts)}. Exit code #{@strong(codes)}."

      if @noWatch
        process.exit ~~(1 in codes)

      codes

module.exports.Task= Task