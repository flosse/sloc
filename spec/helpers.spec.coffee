chai    = require 'chai'
should  = chai.should()
helpers = require "../src/helpers"

describe "The helper module", ->

  describe "alignRight method", ->

    it "should always return a string", ->

      helpers.alignRight().should.be.a 'string'
      helpers.alignRight(234, "x").should.eql ''
      helpers.alignRight(Error).should.eql ''

    it "should align a string to the given length", ->
      helpers.alignRight("foo", 8).should.equal '     foo'
      helpers.alignRight("foo", -3).should.equal ''
      helpers.alignRight(" foo bar baz", 5).should.equal 'r baz'
      helpers.alignRight(" foo bar baz", -1).should.equal ''

  describe "summarize method", ->
    it "reduces the file stats", ->
      helpers.summarize().should.eql {}
      helpers.summarize([]).should.eql {}
      helpers.summarize([{x: 3, y: 2}]).should.eql {x:3, y:2}
      helpers.summarize([{x: 3, y: 2},{x: 2, y: 5} ]).should.eql {x:5, y:7}
      helpers.summarize([{y: 1},{x: 2, y: 5} ]).should.eql {x:2, y:6}

    it "does not modify the original file stats", ->
      stat1 = {x: 4, y: 3 }
      stat2 = {x: 1, y: 7 }
      files = [{stats: stat1},{stats: stat2}]

      helpers.summarize((files.map (x) -> x.stats)).should.eql {x:5, y:10}
      stat1.x.should.equal 4
