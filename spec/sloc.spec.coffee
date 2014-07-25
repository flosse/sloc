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
    sloc("a\nb\nc", "js").total.should.equal 3

  it "should handle CRLF line endings", ->
    sloc("a\r\nb\r\nc", "js").should.eql
      block:    0
      comment:  0
      empty:    0
      mixed:    0
      single:   0
      source:   3
      total:    3

  it "should create correct stats for all languages", ->
    for l in langs
      for n in l.names
        res = sloc l.code, n
        res.total   .should.equal l.total
        res.source  .should.equal l.source
        res.comment .should.equal l.comment
        res.single  .should.equal l.single
        res.block   .should.equal l.block
        res.empty   .should.equal l.empty
        if l.mixed
          res.mixed.should.equal l.mixed

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
      'total'
      'source'
      'comment'
      'single'
      'block'
      'mixed'
      'empty'  ]
    sloc.keys.should.be.an 'array'
    for k in sloc.keys
      (k in keys).should.be.true

  it "can handle at least 10.000 lines", ->
    (-> sloc manyLines, "coffee") .should.not.throw()

  it "can handle lines with at least 10.000 characters", ->
    (-> sloc longLine, "coffee") .should.not.throw()
