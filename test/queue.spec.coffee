# Dependencies
Queue= (require '../src/queue').Queue

# Specs
describe 'Queue',->
  describe '::push,::then',(done)->
    it 'echo',(done)->
      queue= new Queue
      queue.test= yes
      queue.push 'echo'
      queue.then (codes)->
        expect(codes).toEqual [0]
        done()

  describe '::exec',->
    it 'echo',(done)->
      queue= new Queue
      queue.test= yes
      queue.exec 'echo'
      .then (code)->
        expect(code).toBe 0
        done()

  describe '::spawn',->
    it 'echo',(done)->
      queue= new Queue
      queue.test= yes
      queue.spawn 'echo'
      .then (code)->
        expect(code).toBe 0
        done()
