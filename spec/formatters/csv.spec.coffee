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
      loc   : 1
      sloc  : 2
      cloc  : 3
      scloc : 4
      mcloc : 5
      nloc  : 6
    csv(summary: stats).should.equal """
      Path,Physical,Source,Total comment,Single-line comment,Multi-line comment,Empty
      Total,1,2,3,4,5,6
      """
