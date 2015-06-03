# Dependencies
Abigail= (require '../src').Abigail

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
