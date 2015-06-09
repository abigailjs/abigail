# Dependencies
Abigail= (require '../src').Abigail

path= require 'path'
pkg= require '../package'

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
  describe 'Multi glob',->
    it '$ abigail test src/**,test/**',->
      cli= $abigail 'test src/**,test/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**'
      expect(arg.globs[1]).toBe 'test/**'

  describe 'Multi script',->
    it '$ abigail cover,lint,beep src/**,test/**',->
      cli= $abigail 'test,compile,_beep src/**,test/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.scripts[1]).toEqual pkg.scripts.compile
      expect(arg.scripts[1].pipe).toBe false
      expect(arg.scripts[1].lazy).toBe false
      expect(arg.scripts[2]).toEqual 'beep'
      expect(arg.scripts[2].pipe).toBe false
      expect(arg.scripts[2].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'
      expect(arg.globs[1]).toBe 'test/**'

  describe 'Multi task',->
    it '$ abigail _test src/**,test/** _compile,foo bar,baz',->
      cli= $abigail '_test src/**,test/** _compile,foo bar,baz'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'
      expect(arg.globs[1]).toBe 'test/**'

      arg= cli.args[1]
      expect(arg.scripts[0]).toEqual pkg.scripts.compile
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.scripts[1]).toEqual 'foo'
      expect(arg.scripts[1].pipe).toBe false
      expect(arg.scripts[1].lazy).toBe false
      expect(arg.globs[0]).toEqual 'bar'
      expect(arg.globs[1]).toBe 'baz'

  describe 'Reserved word `PKG` of `<watch>`',->
    it '$ abigail test PKG,.travis.yml',->
      cli= $abigail 'test PKG,.travis.yml'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual '*'
      expect(arg.globs[1]).toEqual 'src/**'
      expect(arg.globs[2]).toEqual 'test/**'
      expect(arg.globs[3]).toEqual '.travis.yml'

    it '$ abigail test .travis.yml,PKG',->
      cli= $abigail 'test .travis.yml,PKG'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual '.travis.yml'
      expect(arg.globs[1]).toEqual '*'
      expect(arg.globs[2]).toEqual 'src/**'
      expect(arg.globs[3]).toEqual 'test/**'

  describe 'Lazy script',->
    it '$ abigail _test test/**',->
      cli= $abigail '_test src/**,test/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'

  describe 'Exclude from watch',->
    it '$ abigail test **,_node_modules',->
      cli= $abigail 'test **,_node_modules'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts.test
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual '**'
      expect(arg.globs[1]).toBe '!node_modules'

  describe 'Raw script',->
    it '$ abigail "raw script" src/**',->
      cli= $abigail '"raw script" src/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'raw script'
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**'

    it '$ abigail "_raw script" src/**',->
      cli= $abigail '"_raw script" src/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'raw script'
      expect(arg.scripts[0].pipe).toBe false
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'

  describe 'Irregular',->
    it '$ abigail fixture',->
      cli= $abigail 'fixture'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual pkg.scripts['fixture']
      expect(arg.scripts[0].pipe).toBe true
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual undefined