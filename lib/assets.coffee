Pound   = require('pound')
path = require("path")

exports.init = (app, express) ->

  assets_dir = path.join(__dirname, "../assets")

  pound = Pound.create(
    publicDir: assets_dir
    staticUrlRoot: "/"
    isProduction: false
  )
  
  bundle = pound.defineAsset
  
  pound.resolve.js       = (filename) ->
    return path.join(assets_dir, "/javascripts/#{filename}")

  pound.resolve.css       = (filename) ->
    return path.join(assets_dir,   "/stylesheets/#{filename}")
  
  bundle "home",
    
    # Css assets
    css: ["http://fonts.googleapis.com/css?family=Special+Elite|Raleway:400,600|Open+Sans:400,700", "$css/bootstrap.css", "$css/font-awesome.min.css", "$css/jquery.noty.css", "$css/app.css"]
    
    # JS assets
    js: ["http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js","http://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/js/bootstrap.min.js","$js/plugins.js","js$/jquery.noty.js","js$/jquery.iphone.toggle.js","js$/jquery.uploadify-3.1.min.js","js$/custom.js"]

  pound.configure(app)
  
  pound.precompile()
  
  if app.is_production
    app.use gzippo.staticGzip(assets_dir)
    app.use gzippo.compress()
  else
    app.use express.static(assets_dir)
  
  #app.use express["static"](assets_dir)
