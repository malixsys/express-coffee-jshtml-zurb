optimizer = require("./optimizer")
util         =  require("util")
deaccenter = require("./deaccenter")
utils = require("../lib/app_utils.coffee")

exports.init = (app, options) ->
  options = utils.merge options,
    title: "ecjz"

  app.use (req, res, next) ->
    # --------- flash --------- #
    err = req.session.error
    msg = req.session.success
    form_info = req.session.form_info
    delete req.session.error
    delete req.session.success
    delete req.session.form_info

    if msg
      res.locals.flash =
        type: 'success',
        message: msg     
    if err
      res.locals.flash =
        type: 'error'
        message: err
    if form_info and form_info.errors
      app.inspect_error "LOCALS", err, form_info


    # --------- i18n --------- #
    res.locals.language_link = (if utils.i18n.__("login") is "connexion" then "<a class='language_link' href='/en?returnUrl=" + encodeURIComponent(req.url) + "'><i class='icon-globe icon-white'></i>&nbsp;english</a>" else "<a class='language_link' href='/fr?returnUrl=" + encodeURIComponent(req.url) + "'><i class='icon-globe icon-white'></i>&nbsp;français</a>")
    res.locals.say = utils.say
    res.locals.say_array = (values) ->
      values.map( (v) -> utils.say(v) ).join(",&nbsp;")

    # --------- forms --------- #
    res.locals.csrf = () ->
      return "<input type='hidden' name='_csrf' value='#{req.session._csrf}' />"
    
    res.locals.errorClass = (f) ->
        if form_info and form_info.errors and form_info.errors[f]
          return "error"
        else
          return ""
    
    res.locals.errorFor = (f) ->
      if form_info and form_info.errors and form_info.errors[f]
        return "<span class='help-block error'>#{utils.say(form_info.errors[f][0])}.</span>"
      else
        return "<span class='help-block pull-right'></span>"
      
    res.locals.lastValue = (f) ->
      form_info = form_info or res.current_values
      return "" unless form_info and form_info[f]
      return form_info[f]

    res.locals.list_options = (f, list) ->
      val = res.locals.lastValue(f)
      ret = "<option value=''></option>"
      for k,v of list
        key = deaccenter.to_key("" + if list.length then v else k)
        
        if val and val is key
          ret += "<option selected value='#{key}'>#{res.locals.say(v)}</option>"
        else
          ret += "<option value='#{key}'>#{res.locals.say(v)}</option>"
          
      return ret

    # --------- site --------- #
    res.locals.user = req.user

    res.locals.getTitle = (title) ->
      if title
        return "#{res.locals.say(title)} | #{options.title}"
      else
        return  #{options.title}

    optimizer.optimize(app,req, res, next)
    
