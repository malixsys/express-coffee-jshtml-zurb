fs = require('fs')
path = require("path")
util = require("util")

exports.start = (app, done) ->
  app.is_secure = false

  on_server_started = (err) ->
    if err
      app.inspect_error "SERVER", "Unable to start server", err
    else 
      app.inspect_info "SERVER", "Server started".grey
    
    done(err)
    
      
  if process.is_production or process.env.is_jitsu
    app.server_port = process.env.PORT or 5000
    app.server_host = "INADDR_ANY"
    app.base = "://ecjz.jit.su"
    app.use_secure = false
  else if process.env.C9_PORT
    app.server_port = process.env.PORT
    app.server_host = process.env.IP or 4500
    app.base = "://ecjz.malix.c9.io"
    app.use_secure = false
  else if app.is_testing
    app.server_port = 7777
    app.server_host = 'INADDR_ANY'
    app.base = "://localhost:7777"
    app.use_secure = false
  else
    app.server_port = process.env.PORT or process.argv[3] or 3000
    app.server_host = process.env.IP or process.argv[2] or "localhost"

    if app.server_port is "3443"
      app.use_secure = true
    else
      app.use_secure = false

    if app.server_host is 'INADDR_ANY'
      if app.server_port is "3001"
        app.base = "://localhost:3001"
      else
        app.base = "://localhost:#{app.server_port}"
    else
      app.base = "://#{app.server_host}:#{app.server_port}"


  after_started = (is_secure_started) ->
    if is_secure_started
      app.base = "https" + app.base
      app.is_secure = true
      on_server_started null
    else
      app.base = "http" + app.base
      app.is_secure = false

      app.server = require('http').createServer(app)

      if app.server_host is 'INADDR_ANY'
        return app.server.listen app.server_port, on_server_started
      else
        return app.server.listen app.server_port, app.server_host, on_server_started
    
    
  
  if app.use_secure
    try 
      files_dir = path.join(__dirname, "../files/")
      
      privateKey = fs.readFileSync(path.join(files_dir, '/ecjz.key')).toString();
      certificate = fs.readFileSync(path.join(files_dir, '/ecjz.crt')).toString();
      dad1 = fs.readFileSync(path.join(files_dir, '/gd_bundle.crt')).toString();
      dad2 = dad1
      #throw new Error("disabled")
      app.server = require('https').createServer({key: privateKey, cert: certificate, ca: [dad1, dad2] }, app);
      
      if app.server_host is 'INADDR_ANY'
        return app.server.listen app.server_port, (err) ->
          if err
            after_started false
          else
            after_started true
      else
        return app.server.listen app.server_port, app.server_host, (err) ->
          if err
            after_started false
          else
            after_started true
    catch err
      on_server_started err
      
  process.nextTick () ->
    after_started false
