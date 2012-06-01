whirlwind = require '../'
should = require 'should'
require 'mocha'
whirlwind.api_server = "http://localhost:8080"

key = "pub-aea7-c6c8-abb9-ac76"

describe 'whirlwind', ->
  describe 'execute()', ->
    it 'should perform a sandboxed task', (done) ->
      code = "(function (a,b,done){ done(a+b+third); })"
      whirlwind.execute code, [1,2], {third:3}, (result) ->
        should.exist result
        result.should.equal 6
        done()

  describe 'work()', ->
    it 'should poll the API properly', (done) ->
      whirlwind.work key, (ok) ->
        ok.should.equal true
        done()

  describe 'consume()', ->
    it 'should poll the API properly', (done) ->
      count = 0
      donezo = -> done() if ++count is 2
      whirlwind.consume key, 1, donezo