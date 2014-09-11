fs        = require 'fs'
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

  describe "language support", ->
    for l in langs then do (l) ->
      for n in l.names then do (n) ->
        it "should support #{n}", ->
          res = sloc l.code, n
          (n in sloc.extensions).should.equal true
          if l.total
            res.total   .should.equal l.total
          if l.source
            res.source  .should.equal l.source
          if l.comment
            res.comment .should.equal l.comment
          if l.single
            res.single  .should.equal l.single
          if l.block
            res.block   .should.equal l.block
          if l.empty
            res.empty   .should.equal l.empty
          if l.mixed
            res.mixed   .should.equal l.mixed

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

  it "evaluates an emty file correctly", (done) ->
    fs.readFile "./spec/testfiles/empty.js", "utf-8", (err, code) ->
      res = sloc code, "js"
      res.empty.should.equal 1
      res.source.should.equal 0
      res.total.should.equal 1
      done()
