chai      = require 'chai'
csv       = require '../../src/formatters/cli-table'
should    = chai.should()

describe "The table formatter", ->

  it "should be a function", ->
    csv.should.be.a 'function'

  it "should return a string", ->
    csv({}).should.be.a 'string'
