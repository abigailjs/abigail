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

  describe '::spawn',->
    it 'dirty echo',(done)->
      queue= new Queue
      queue.test= yes
      queue.spawn "echo '<this is not pipe>' $(echo echo) \"|\" echo '$(echo foo)'"
      .then (code)->
        expect(code).toBe 0
        done()

