colors = require('colors')
nodemailer = require("nodemailer")
path    = require("path")

send_message = (app, fakemails, message, done) ->
  app.inspect_info "MAIL","Sending Mail to #{message.to}"

  unless app.is_production
    fakemails.push message
    app.inspect_success "MAIL", "Fake message sent successfully!", message
    process.nextTick () ->
      done(null)
    return
  
    transport = nodemailer.createTransport("SMTP",
      service: 'Gmail', #use well known service
      auth:
        user: "admin@yoursite.com",
        pass: "password"
    )
    message.forceEmbeddedImages = true
    message.from = "Admin <admin@yoursite.com>"


  transport.sendMail message, (error) ->
    if error
      app.inspect_error "MAIL","Error sending mail!", error
    else
      app.inspect_success "MAIL", "Message sent successfully!", message.to
    transport.close()
    done(error)

class Mailer

  constructor: (app) ->
    @app = app
    @fakemails = []

  sendView: (subject, recipient, view, ctx, done) ->
    app = @app
    fakemails = @fakemails
    
    view_engine = require("../lib/view_engine.coffee")
    htmlFile = path.join(__dirname, "../views/mailer_#{view}.html")
    txtFile = path.join(__dirname, "../views/mailer_#{view}_txt.html")

    app.inspect_info "MAIL", "Rendering #{view} html..."
    view_engine.render htmlFile, ctx, (err, str) ->
      if(err)
        return done(err)
      app.inspect_info "MAIL", "Rendering #{view} text..."
      view_engine.render txtFile, ctx, (err2, str2) ->
        if(err2)
          return done(err2)
        mailOptions =
          to: recipient
          subject: app.utils.say(subject)
          text: str2
          html: str

        send_message(app, fakemails, mailOptions, done)

  send: (mailOptions, done) ->
    send_message(@app, @fakemails, mailOptions, done)

exports.init = (app) ->
  return new Mailer(app)
