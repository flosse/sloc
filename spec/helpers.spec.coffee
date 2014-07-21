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
