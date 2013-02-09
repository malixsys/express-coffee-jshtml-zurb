bytes = require('bytes')

exports.init = (app) ->
  app.use (req, res, next) ->
    console.log "STL: #{req.url}"
    if req.url is "/SmokeTest/MeaningOfLife"
      return res.end "42"
    if req.url is "/SmokeTest/version"
      return res.end app.CURRENT_VERSION

    req._startTime = new Date unless req._startTime

    res.on "header", -> 
      status = res.statusCode
      
      if (status >= 500) 
        color = " #{status} ".red
      else if (status >= 400) 
        color = " #{status} ".yellow
      else if (status >= 300) 
        color = " #{status} ".cyan
      else
        color = " #{status} ".green
      
      len = parseInt(res.getHeader('Content-Length'), 10)
      len = if isNaN(len) then '' else ' - ' + bytes(len);
  
      console.log "#{req.connection.remoteAddress} #{req.method} #{req.originalUrl or req.url}".grey + color + "#{(new Date - req._startTime)}ms#{len}".grey unless app.is_testing
    
    next()

    #app.use express.logger('dev')
  
