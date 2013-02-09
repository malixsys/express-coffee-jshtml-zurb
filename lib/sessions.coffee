ONE_MINUTE = 60 * 1000
ONE_HOUR   = 60 * ONE_MINUTE
TIME_OUT   = 5 * ONE_MINUTE

USER_COOKIE_NAME = "ecjz.user"
util = require("util")

sessions = (app) ->
  
  (req, res, next) ->
    res.on "header", -> 
      if req.user
        res.cookie USER_COOKIE_NAME, req.user,
          signed: true
          maxAge: 8 * ONE_HOUR
      else
        res.clearCookie(USER_COOKIE_NAME)

    req.user = req.signedCookies[USER_COOKIE_NAME] or false
    unless req.user
      return next()
      
    loaded = new Date(req.user.loaded)
    now = new Date
    unless (now - loaded) > TIME_OUT
      return next()
    
    app.inspect_info "SESSIONS","Reloading #{req.user.login}"
    start = new Date;
    app.DB.load_user app, req.user.login, (err, user) ->
      if err
        app.inspect_error "SESSIONS","Unable to reload!", 
          error:err
          user:user
        req.user = false
      else
        app.inspect_info "SESSIONS","Reloaded #{req.user.login} in #{new Date - start} ms"
        req.user = user
      next()
        
exports.init = (app, express) ->
  app.use express.cookieParser("6d238d1e-e548-4dff-9413-7652f86b6d99")
  app.use sessions(app)
  app.use express.session()
