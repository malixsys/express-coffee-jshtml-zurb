util         =  require("util")
Portal = require('./index').Portal

get_root = (app) ->
  (req,res) =>
    return res.render 'home_index',
      title: "ECJZ"
      flash:
        type: 'success',
        message: 'Welcome!'

get_error = (app) ->
  (req,res) =>
    res.send "<html><body><h1>Error #{req.params.num}</h1><a href='/'>Home</a></body></html>"

get_profile = (app) ->
  (req,res) =>
    return res.render 'home_profile',
      title: "ECJZ"


class Home extends Portal
  @init: (app) =>
    app.get "/"
      , get_root(app)

    app.get "/stack" , (req, res) ->
      throw new Error("BOOM!")

    app.get "/profile"
      , get_profile(app)

    app.get "/error/:num"
      , get_error(app)

exports.init = (app) ->
  Home.init(app)
