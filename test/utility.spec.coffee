# Dependencies
Utility= (require '../src/utility').Utility

chalk= require 'chalk'

pkg= require '../package'

# Specs
describe 'Utility',->
  utility= new Utility
  utility.test= true

  it '::log',->
    texts= utility.log 'foo'

    expect(texts[0]).toBeTruthy()
    expect(texts[1]).toBe utility.icon
    expect(texts[2]).toBe 'foo'

  it '::json',->
    text= utility.json 'bar'

    expect(text).toBe chalk.bgRed 'bar'

  it '::strong',->
    texts= utility.strong 'foo'

    expect(texts).toBe chalk.underline 'foo'

  it '::whereabouts',->
    texts= utility.strong 'foo'

    expect(texts).toBe chalk.underline 'foo'

  it '::help',->
    text= utility.help()

    expect(text).toBeTruthy()

  it '::version',->
    text= utility.version()

    expect(text).toBe 'v'+pkg.version

  it '::output(process.exit() if producion)',->
    text= utility.output 'baz'

    expect(text).toBe 'baz'
