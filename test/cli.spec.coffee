# Dependencies
Abigail= (require '../src').Abigail
Task= (require '../src/task').Task

path= require 'path'

# Fixture
$abigail= (args)->
  argv= ['node',__filename]
  for arg in args.match /".*?"|[^\s]+/g
    argv.push arg.replace /^"|"$/g,''

  cli= new Abigail
  cli.test= yes
  cli.parse argv

  cli

# Specs
describe 'CLI',->
  describe 'Globs',->
    it '$ abigail test src/**,test/**',->
      cli= $abigail 'test src/**,test/**'

      arg= cli.args[0]
      expect(arg.script).toBe 'npm run test'
      expect(arg.globs[0]).toBe 'src/**'
      expect(arg.globs[1]).toBe 'test/**'
      expect(arg.lazy).toBe false

  describe 'Multi task',->
    it '$ abigail test src/**,test/** compile src/**/*.js',->
      cli= $abigail 'test src/**,test/** compile src/**/*.js'

      arg= cli.args[0]
      expect(arg.script).toBe 'npm run test'
      expect(arg.globs[0]).toBe 'src/**'
      expect(arg.globs[1]).toBe 'test/**'
      expect(arg.lazy).toBe false

      arg= cli.args[1]
      expect(arg.script).toBe 'npm run compile'
      expect(arg.globs[0]).toBe 'src/**/*.js'
      expect(arg.lazy).toBe false

  describe 'Lazy script',->
    it '$ abigail _test test/**',->
      cli= $abigail '_test src/**,test/**'

      arg= cli.args[0]
      expect(arg.script).toBe 'npm run test'
      expect(arg.globs[0]).toBe 'src/**'
      expect(arg.lazy).toBe true

  describe 'Exclude from watch',->
    it '$ abigail test **,_node_modules',->
      cli= $abigail 'test **,_node_modules'

      arg= cli.args[0]
      expect(arg.script).toBe 'npm run test'
      expect(arg.globs[0]).toBe '**'
      expect(arg.globs[1]).toBe '!node_modules'
      expect(arg.lazy).toBe false

  describe 'Raw script',->
    it '$ abigail "raw script" src/**',->
      cli= $abigail '"raw script" src/**'

      arg= cli.args[0]
      expect(arg.script).toBe 'raw script'
      expect(arg.globs[0]).toBe 'src/**'
      expect(arg.lazy).toBe false

describe 'class Task',->
  it '$ abigail foo bar,!baz',->
    task= new Task 'foo',['bar','!baz'],null,true

    expect(task.script).toBe 'foo'
    expect(task.globs[0]).toEqual path.join process.cwd(),'bar'
    expect(task.globs[1]).toEqual '!'+path.join process.cwd(),'baz'
    expect(task.lazy).toBe false

describe 'Irregular',->
  it '$ abigail "The quick brown fox jumps over the lazy dog"',->
    cli= $abigail '"The quick brown fox jumps over the lazy dog"'

    arg= cli.args[0]
    expect(arg.script).toBe 'The quick brown fox jumps over the lazy dog'
    expect(arg.globs[0]).toBe undefined
    expect(arg.lazy).toBe false
