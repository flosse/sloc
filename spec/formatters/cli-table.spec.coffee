chai      = require 'chai'
table     = require '../../src/formatters/cli-table'
should    = chai.should()

describe "The table formatter", ->

  it "should be a function", ->
    table.should.be.a 'function'

  it "should return a string", ->
    table({}).should.be.a 'string'
