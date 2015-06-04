# Dependencies
Task= (require '../src/task').Task

path= require 'path'

# Specs
describe 'Task',->
  task= new Task
  task.test= true

  describe 'toAbsolute',->
    it 'resolved **',->
      globs= task.toAbsolute ['**']
      expect(globs).toEqual [path.join process.cwd(),'**']

    it 'ignored _',->
      globs= task.toAbsolute ['_**']
      expect(globs).toEqual [path.join process.cwd(),'_**']

  describe 'execute',->
    it 'scripts [echo]',(done)->
      task.execute ['echo']
      .then (exitCodes)->
        expect(exitCodes).toEqual [0]
        done()

  describe 'spawn',->
    it 'script echo',(done)->
      task.spawn 'echo'
      .then (exitCode)->
        expect(exitCode).toEqual 0
        done()

