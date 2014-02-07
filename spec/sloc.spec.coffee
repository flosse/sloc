chai      = require 'chai'
should    = chai.should()
langs     = require "./languages"
sloc      = require "../src/sloc"

describe "sloc", ->

  it "sloc should be a function", ->
    sloc.should.be.a.function

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
