require("coffee-script")
require("source-map-support")

express = require("express")
app = express()
app.CURRENT_VERSION = '0.0.1'

colors = require('colors')
helmet = require('helmet')

util = require("util")


app.is_production = process.env.is_production or process.env.is_jitsu
if app.is_production
  util.log   "---------------------------------------------------- #{app.CURRENT_VERSION} ----------------------------------------------------"
  util.error "---------------------------------------------------- #{app.CURRENT_VERSION} ----------------------------------------------------"
else
  util.log   "---------------------------------------------------- #{app.CURRENT_VERSION} ----------------------------------------------------"

app.utils = require("./lib/app_utils.coffee")

inspector = require("./lib/app_inspector")
inspector.init(app)

database = require("./models/db.coffee")
database.init(app)

app.configure ->
  view_engine = require("./lib/view_engine.coffee")
  view_engine.init(app)

  app.use express.favicon()

  smoke_test_and_log = require("./lib/smoke_test_and_log")
  smoke_test_and_log.init(app)

  app.use express.bodyParser()
  app.use express.methodOverride()

  app.use helmet.xframe()
  app.use helmet.iexss()

  sessions = require("./lib/sessions")
  sessions.init(app, express)

  csrf = express.csrf()
  app.use (req, res, next) ->
    csrf req, res, (err) ->
      if err and app.is_production
        app.inspect_error "SERVER","ERROR 403",
          err.stack
        res.redirect "/error/403?returnUrl=" + encodeURIComponent(req.url)
      else
        next()


  view_locals = require("./lib/view_locals")
  view_locals.init(app)

  assets_dir = require("path").join(__dirname, "assets")
  #gzippo = require('gzippo')

  if app.is_production
    app.use express.compress()
    app.use express["static"](assets_dir)
    #app.use gzippo.staticGzip(assets_dir)
    #app.use gzippo.compress()
  else
    app.use express["static"](assets_dir)
  ###
  app.use gzippo.staticGzip assets_dir,
      maxAge: 15000
    contentTypeMatch: /text|javascript|json/
  clientMaxAge: 15000
  ###

  app.use app.router


  if app.is_production
    app.use (err, req, res, next) ->
      if err
        app.inspect_error "SERVER", "ERROR 500",
          req: req
          error: err.stack
        delete req.user_id
        res.redirect "/error/500"
      else
        next()
  else
    app.use (err, req, res, next) ->
      if err
        app.inspect_error "SERVER","ERROR 500",
          err.stack
        res.redirect "/error/500"
      else
        next()

  routes = require("./routes")
  routes.init(app)


  app.all "*", (req, res) ->
    app.inspect_error "SERVER", "ERROR 404",
      user: if req.user then req.user.login else "anonymous"
      url: req.originalUrl or req.url
      body: req.body
    res.redirect "/error/404"

exports.start = (is_testing, done) ->
  app.is_testing = is_testing
  testing = if is_testing then "TEST ".yellow else ""
  app.inspect_info "APP", "starting #{testing}version #{app.CURRENT_VERSION.blue}", process.argv

  on_server_started = (err) ->
    if err
      done(err) if done
      return

    done(null, app) if done


  require("./lib/server").start(app, on_server_started)

if process.argv[0] is 'coffee'
  exports.start false, (err, server) ->
    if err
      app.inspect_error "APP","Error starting", err
      return

    app.inspect_info "APP","started by process #{process.pid} at #{app.base.blue}"

