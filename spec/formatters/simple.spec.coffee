chai      = require 'chai'
simple    = require '../../src/formatters/simple'
should    = chai.should()

describe "The simple formatter", ->

  it "should be a function", ->
    simple.should.be.a 'function'

  it "should return a string", ->
    simple(summary: {}, files: []).should.be.a 'string'
