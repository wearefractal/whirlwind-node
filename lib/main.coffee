request = require 'superagent'
{runInNewContext} = require 'vm'

whirl =
  api_server: 'http://api.whirlwind.io'
  consume: (token, secs, cb) ->
    throw 'Invalid API token' unless typeof token is 'string'
    throw 'Seconds must be a number' unless typeof secs is 'number'
    throw 'Seconds must be a number over 0' unless secs > 0
    lp = -> 
      whirl.work token, (ok) ->
        cb() if typeof cb is 'function' and ok
        setTimeout lp, secs*1000
    lp()


  work: (token, cb) ->
    request
    .post("#{whirl.api_server}/work")
    .send({token: token})
    .set('Accept', 'application/json')
    .end (res) ->
      return cb false unless res.ok
      return cb false unless res.body.status is 'success'
      order = res.body.result

      whirl.execute order.job.code, order.args, order.scope, (sol) ->
        request
        .post("#{whirl.api_server}/work/#{order._id}")
        .send({token: token, solution: sol})
        .set('Accept', 'application/json')
        .end (res) ->
           return cb false unless res.ok
           return cb false unless res.body.status is 'success'
           return cb true

  execute: (code, args, scope, cb) ->
    ctx =
      global: null
      process: null
      require: null
      console: null
      module: null
      __filename: null
      __dirname: null
      clearInterval: null
      clearTimeout: null
      setInterval: null
      setTimeout: null
      __done: cb
      __args: args
    ctx[k] = v for k,v of scope if scope?
    runInNewContext "#{code}.apply(null,__args.concat([__done]));", ctx, 'whirlwind.vm'

module.exports = whirl