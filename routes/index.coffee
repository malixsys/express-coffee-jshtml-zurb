util = require("util")
form    = require("express-form")
field   = form.field

form.configure
  autoLocals: false

class Portal
  @form: form
  @field: field

  @valid_profile: (req, res, next) ->
    if req.url.substr(0,7) is "/error/"
      return next()

    if req.user
      if req.user.confirmation_token and req.user.confirmation_token.length
        req.session.error = req.session.error or "Message_Error_Not_confirmed"
        return res.redirect "/confirmation"

      unless req.user.profile.attestation or req.url is '/profil'
        req.session.error = "Message_Error_Profile_Incomplete"
        return res.redirect "/profil"
    next()

  @logged_in: (req, res, next) ->
    if req.url.substr(0,7) is "/error/"
      return next()
    if req.user
      unless req.url isnt '/confirmation' and req.url.substr(0,8) isnt '/confirm' and req.url isnt '/connexion'
        return next()
      if req.user.confirmation_token and req.user.confirmation_token.length
        req.session.error = "Message_Error_Not_confirmed"
        return res.redirect "/confirmation"

      unless req.user.profile.attestation or req.url is '/profil'
        req.session.error = "Message_Error_Profile_Incomplete"
        return res.redirect "/profil"

      next()
    else
      req.session.error = "Message_Error_Not_logged_in"
      res.redirect "/connexion?returnUrl=" + encodeURIComponent(req.url)


exports.Portal = Portal
exports.init = (app) ->
  require('./home.coffee').init(app)
