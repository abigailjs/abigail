# Dependencies
Queue= (require '../src/queue').Queue

# Specs
describe 'Queue',->
  describe '::push,::then',(done)->
    it 'echo',(done)->
      queue= new Queue
      queue.options.test= yes
      queue.push 'echo'
      .last (codes)->
        expect(codes).toEqual [0]
        done()

    it 'echo,bail,skip',(done)->
      queue= new Queue
      queue.options.test= yes
      queue.push 'echo'
      queue.push 'bail'
      queue.push 'skip'
      .last (codes)->
        expect(codes).toEqual [0,1]
        done()

    it 'echo,bail,skip(forced)',(done)->
      queue= new Queue
      queue.options.test= yes
      queue.options.force= yes
      queue.push 'echo'
      queue.push 'bail'
      queue.push 'skip'
      .last (codes)->
        expect(codes).toEqual [0,1,1]
        done()

    it 'server,echo',(done)->
      serverFile= new String 'test/server.js'
      serverFile.fork= true

      queue= new Queue
      queue.options.test= yes
      queue.options.force= yes
      queue.push serverFile
      queue.push 'echo'
      .last (codes)->
        expect(codes).toEqual [0,0]
        done()

  describe '::exec',->
    it 'echo',(done)->
      queue= new Queue
      queue.options.test= yes
      queue.exec 'echo'
      .then (code)->
        expect(code).toBe 0
        done()
  
  describe '::spawn',->
    it 'dirty echo',(done)->
      queue= new Queue
      queue.options.test= yes
      queue.spawn "echo '<this is not pipe>' $(echo echo) \"|\" echo '$(echo foo)'"
      .then (code)->
        expect(code).toBe 0
        done()

