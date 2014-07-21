chai      = require 'chai'
csv       = require '../../src/formatters/csv'
should    = chai.should()

describe "The CSV formatter", ->

  it "should be a function", ->
    csv.should.be.a 'function'

  it "should return a string", ->
    csv({}).should.be.a 'string'

  it "should create a csv", ->
    stats =
      total   : 1
      source  : 2
      comment : 3
      single  : 4
      block   : 5
      mixed   : 6
      empty   : 7
    csv(summary: stats).should.equal """
      Path,Physical,Source,Comment,Single-line comment,Block comment,Mixed,Empty
      Total,1,2,3,4,5,6,7
      """
