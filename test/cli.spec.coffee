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
      expect(arg.scripts[0]).toEqual 'npm run test'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**'
      expect(arg.globs[1]).toBe 'test/**'

  describe 'Multi task',->
    it '$ abigail test src/**,test/** compile src/**/*.js',->
      cli= $abigail 'test src/**,test/** compile src/**/*.js'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'npm run test'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**'
      expect(arg.globs[1]).toBe 'test/**'

      arg= cli.args[1]
      expect(arg.scripts[0]).toEqual 'npm run compile'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**/*.js'

  describe 'Lazy script',->
    it '$ abigail _test test/**',->
      cli= $abigail '_test src/**,test/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'npm run test'
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'

  describe 'Exclude from watch',->
    it '$ abigail test **,_node_modules',->
      cli= $abigail 'test **,_node_modules'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'npm run test'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual '**'
      expect(arg.globs[1]).toBe '!node_modules'

  describe 'Raw script',->
    it '$ abigail "raw script" src/**',->
      cli= $abigail '"raw script" src/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'raw script'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**'

    it '$ abigail "_raw script" src/**',->
      cli= $abigail '"_raw script" src/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'raw script'
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'

describe 'Irregular',->
  it '$ abigail "The quick brown fox jumps over the lazy dog"',->
    cli= $abigail '"The quick brown fox jumps over the lazy dog"'

    arg= cli.args[0]
    expect(arg.scripts[0]).toEqual 'The quick brown fox jumps over the lazy dog'
    expect(arg.scripts[0].lazy).toBe false
    expect(arg.globs[0]).toEqual undefined
