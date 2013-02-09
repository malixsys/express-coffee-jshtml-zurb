util = require("util") 
fs = require("fs")

months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

pad = (n) ->
  (if n < 10 then "0" + n.toString(10) else n.toString(10))

pad3 = (n) ->
  (if n < 100 then "0" + pad(n) else n.toString(10))
  
timestamp = ->
  d = new Date()
  time = [
    pad(d.getHours()), 
    pad(d.getMinutes()), 
    pad(d.getSeconds()) + ".#{pad3(d.getMilliseconds())}"].join(":")
  return "#{months[d.getMonth()]} #{d.getDate()} @ #{time}"

get_message = (msg, obj, use_color) ->
  if obj
    if typeof obj is 'string'
      msg = "#{msg}\n\t#{obj}"
    else
      msg = "#{msg}\n#{util.inspect(obj, false, 4, use_color)}"
  return msg

_reg = new RegExp('(\u001b\\[\\d\\dm)',"g")
add_inspection = (app, type, frm, msg, obj) ->
  fileName = "Log_#{app.CURRENT_VERSION}.txt"
  process.nextTick () ->  
    el = 
      time: timestamp()
      type: type
      from: frm
      message: msg.replace(_reg,"")
      object: obj 
    text = "#{el.time} [#{el.from}] [#{el.type}]  #{el.message}"
    if el.object
      text += "\n  " + util.inspect(
        object: el.object
      , true, 10, false)
    text += "\n\n"
    fs.appendFile fileName, text, (err) ->
      if err
        util.error util.inspect(
          "unable to add inspection": err
        , false, 10, true)

exports.init = (app) =>
  app.inspect_error = (frm, msg, err) ->
    add_inspection app, "ERROR", frm, msg, err
    console.log "#{timestamp()}".grey + " [#{frm}] ".red + get_message(msg,err,true) unless app.is_testing and false
  
  app.inspect_success = (frm, msg, obj) ->
    add_inspection app, "SUCCESS", frm, msg, obj
    console.log "#{timestamp()}".grey + " [#{frm}] ".bold.green + get_message(msg.green,obj,true) unless app.is_testing
  
  app.inspect_info = (frm, msg, err) ->
    add_inspection app, "INFO", frm, msg, err
    console.log "#{timestamp()}".grey + " [#{frm}] ".blue + get_message(msg,err,true) unless app.is_testing

  add_inspection app, "INFO", "LOG", "---------------------------------------------------- #{app.CURRENT_VERSION} ----------------------------------------------------"

exports.sendLog = (app,res) ->
  fileName = "Log_#{app.CURRENT_VERSION}.txt"
  fs.exists fileName, (exists) ->
    if exists
      fs.readFile fileName, (err, data)  ->
        if err
          res.write "ERROR\n"
          res.write util.inspect(err, false, 10, true)
          res.end "\n"
          return
        
        return res.end data 
    else 
      res.write "ERROR\nFile not found."
    res.write "LOG #{timestamp()}\n\n\n"