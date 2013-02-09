crypto  = require('crypto')
util    = require("util")

exports.timestring = () ->
  date = Math.round((new Date).valueOf() / 86400) - 7000000
  #date = Math.round(since - 15600)
  now = process.hrtime()
  #while now[0] > 86400
  #  now[0] -= 86400
  now[1] = Math.round(now[1] / 100.00000)
  return "#{date}-#{now[1]}"
  
exports.new_token = () ->
  return (new Buffer(exports.timestring(), "ascii")).toString("base64")

module.exports.csrf = csrf = () ->
  (req, res, next) ->
    token = req.session._csrf or (req.session._csrf = exports.new_token())
    next()

module.exports.hash = (name) ->
  return crypto.createHash('md5').update(name).digest("base64")
