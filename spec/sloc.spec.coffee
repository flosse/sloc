chai      = require 'chai'
should    = chai.should()
langs     = require "./languages"
sloc      = require "../src/sloc"
manyLines = ('# \n'    for i in [0...10000]).join('')
longLine  = ('### ###' for i in [0...10000]).join('')

describe "The sloc module", ->

  it "should be a function", ->
    sloc.should.be.a 'function'

  it "should count all lines", ->
    sloc("a\nb\nc", "js").loc.should.equal 3

  it "should create correct stats for all languages", ->
    for l in langs
      for n in l.names
        res = sloc l.code, n
        res.loc   .should.equal l.loc
        res.sloc  .should.equal l.sloc
        res.cloc  .should.equal l.cloc
        res.scloc .should.equal l.scloc
        res.mcloc .should.equal l.mcloc
        res.nloc  .should.equal l.nloc

  it "should throw an error", ->
    (-> sloc "foo", "foobar").should.throw()
    (-> sloc null, "coffee") .should.throw()

  it "keeps an array with all supported extensions", ->
    sloc.extensions.should.be.an 'array'
    for l in langs
      for n in l.names
        (n in sloc.extensions).should.be.true

  it "keeps an array with all supported keys", ->
    keys = [
      'loc'
      'sloc'
      'cloc'
      'scloc'
      'mcloc'
      'nloc'  ]
    sloc.keys.should.be.an 'array'
    for k in sloc.keys
      (k in keys).should.be.true

  it "can handle at least 10.000 lines", ->
    (-> sloc manyLines, "coffee") .should.not.throw()

  it "can handle lines with at least 10.000 characters", ->
    (-> sloc longLine, "coffee") .should.not.throw()
