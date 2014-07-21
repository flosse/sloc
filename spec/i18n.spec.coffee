chai    = require 'chai'
should  = chai.should()
i18n    = require "../src/i18n"

describe "The i18n module", ->

  it "should be a object", ->
    i18n.should.be.a 'object'

  it "should contain at least the english strings", ->

    i18n.en.total   .should.equal "Physical"
    i18n.en.source  .should.equal "Source"
    i18n.en.comment .should.equal "Comment"
    i18n.en.single  .should.equal "Single-line comment"
    i18n.en.block   .should.equal "Block comment"
    i18n.en.empty   .should.equal "Empty"
    i18n.en.mixed   .should.equal "Mixed"

    i18n.en.Result  .should.equal "Result"
    i18n.en.Total   .should.equal "Total"
    i18n.en.Error   .should.equal "Error"
    i18n.en.Details .should.equal "Details"
    i18n.en.Path    .should.equal "Path"

    i18n.en.BadDir    .should.equal "Bad directory"
    i18n.en.BadFile   .should.equal "Bad file"
    i18n.en.BadFormat .should.equal "Bad format"

    i18n.en.BrokenFiles         .should.equal "Broken files"
    i18n.en.UnknownSourceFiles  .should.equal "Unknown source files"
    i18n.en.NumberOfFilesRead   .should.equal "Number of files read"
    i18n.en.BrokenDirectories   .should.equal "Broken directories"
