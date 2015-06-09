# Dependencies
Task= (require '../src/task').Task

path= require 'path'

# Specs
describe 'Task',->
  task= new Task
  task.options.test= yes

  describe '::toAbsolute',->
    it 'resolved **',->
      globs= task.toAbsolute ['**']
      expect(globs).toEqual [path.join process.cwd(),'**']

    it 'ignored _',->
      globs= task.toAbsolute ['_**']
      expect(globs).toEqual [path.join process.cwd(),'_**']

  describe '::run',->
    it 'echo,echo,echo',(done)->
      task.run ['echo','echo','echo']
      .then (codes)->
        expect(codes).toEqual [0,0,0]
        done()