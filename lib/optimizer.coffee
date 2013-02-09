util = require("util")

ONE_HOUR = 60 * 60
ONE_DAY = ONE_HOUR * 24
ONE_WEEK = ONE_DAY * 7
ONE_MONTH = ONE_WEEK * 4
ONE_YEAR = ONE_MONTH * 12

mimeTypes =
  js: "application/javascript"
  jsonp: "application/javascript"
  json: "application/json"
  css: "text/css"
  oga: "audio/ogg"
  ogg: "audio/ogg"
  m4a: "audio/mp4"
  f4a: "audio/mp4"
  f4b: "audio/mp4"
  ogv: "video/ogg"
  mp4: "video/mp4"
  m4v: "video/mp4"
  f4v: "video/mp4"
  f4p: "video/mp4"
  webm: "video/webm"
  flv: "video/x-flv"
  eot: "application/vnd.ms-fontobject"
  ttf: "application/x-font-ttf"
  ttc: "application/x-font-ttf"
  otf: "font/opentype"
  woff: "application/x-font-woff"
  webp: "image/webp"
  appcache: "text/cache-manifest"
  manifest: "text/cache-manifest"
  htc: "text/x-component"
  rss: "application/rss+xml"
  atom: "application/atom+xml"
  xml: "application/xml"
  rdf: "application/xml"
  crx: "application/x-chrome-extension"
  oex: "application/x-opera-extension"
  xpi: "application/x-xpinstall"
  safariextz: "application/octet-stream"
  webapp: "application/x-web-app-manifest+json"
  vcf: "text/x-vcard"
  swf: "application/x-shockwave-flash"
  vtt: "text/vtt"
  html: "text/html"
  htm: "text/html"
  bmp: "image/bmp"
  gif: "image/gif"
  jpeg: "image/jpeg"
  jpg: "image/jpeg"
  jpe: "image/jpeg"
  png: "image/png"
  svg: "image/svg+xml"
  svgz: "image/svg+xml"
  tiff: "image/tiff"
  tif: "image/tiff"
  ico: "image/x-icon"
  txt: "text/plain"


path = require ("path")
mime = lookup: (file) ->
  
  # instead of using the . in the regex we should specify what we want to match
  re =  /(?:\.([^.]+))?$/
  ext = re.exec(file)[1]
  unless ext and ext.toLowerCase
    return "text/html"
    
  if mimeTypes[ext.toLowerCase()] 
    return mimeTypes[ext.toLowerCase()]
  else
    return "text/plain"

exports.optimize = (app, req, res, next) ->

  ua  = req.headers['user-agent']
  type = mime.lookup(req.url)
  res.setHeader "Content-Type", type
  res.setHeader "X-UA-Compatible", "IE=Edge,chrome=1"  if /MSIE/.test(ua) and "text/html" is type

  if app.is_production
    if /(text\/(cache-manifest|html|xml)|application\/(xml|json))/.test(type)
      cc = "public,max-age=0"

    # Feed
    else if /application\/(rss\+xml|atom\+xml)/.test(type)
      cc = "public,max-age=" + ONE_HOUR

    # Favicon (cannot be renamed)
    else if /image\/x-icon/.test(type)
      cc = "public,max-age=" + ONE_WEEK

    # Media: images, video, audio
    # HTC files  (css3pie)
    # Webfonts
    # (we should probably put these regexs in a variable)
    else if /(image|video|audio|text\/x-component|application\/x-font-(ttf|woff)|vnd\.ms-fontobject|font\/opentype)/.test(type)
      cc = "public,max-age=" + ONE_MONTH

    # CSS and JavaScript
    else if /(text\/(css|x-component)|application\/javascript)/.test(type)
      cc = "public,max-age=" + ONE_HOUR

    # Misc
    else
      cc = "public,max-age=" + ONE_MONTH
  else
    cc = "public,max-age=0"
  
  if /(\/raw\/)/.test(req.url) 
    cc = "public,max-age=" + ONE_YEAR
    
  # Prevent mobile network providers from modifying your site
  # The following header prevents modification of your code over 3G on some
  # European providers.
  # This is the official 'bypass' suggested by O2 in the UK.
  cc += ((if cc then "," else "")) + "no-transform"
  res.setHeader "cache-control", ""

  # ETag removal
  # Since we're sending far-future expires, we don't need ETags for
  # static content.
  # developer.yahoo.com/performance/rules.html#etags
  # hack: send does not compute ETag if header is already set, this save us ETag generation
  res.setHeader "etag", ""

  # handle headers correctly after connect.static
  res.on "header", ->
    res.setHeader "cache-control", cc
    val = 
      url: req.url
      type: type
      cc: cc
    #util.log "[OPTIMIZE] #{util.inspect(val, false, 5, true).replace("\n", " ")}"

    # remote empty etag header
    res.removeHeader "etag"


  # Set Keep-Alive Header
  # Keep-Alive allows the server to send multiple requests through one
  # TCP-connection. Be aware of possible disadvantages of this setting. Turn on
  # if you serve a lot of static content.
  res.setHeader "connection", "keep-alive"

  # Built-in filename-based cache busting
  # If you're not using the build script to manage your filename version revving,
  # you might want to consider enabling this, which will route requests for
  # /css/style.20110203.css to /css/style.css
  # To understand why this is important and a better idea than all.css?v1231,
  # read: github.com/h5bp/html5-boilerplate/wiki/cachebusting
  # (again the . here should be replaced by allowed caracter ranges)
  req.url = req.url.replace(/^(.+)\.(\d+)\.(js|css|png|jpg|gif)$/, "$1.$3")

  # A little more security
  # Block access to "hidden" directories or files whose names begin with a
  # period. This includes directories used by version control systems such as
  # Subversion or Git.
  if /(^|\/)\./.test(req.url) # 403, forbidden
    app.inspect_error "OPTIMIZER", "Insecure url", req.url
    throw 403  

  # Block access to backup and source files. These files may be left by some
  # text/html editors and pose a great security danger, when anyone can access
  # them.
  if /\.(md|coffee|bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)|~/.test(req.url) # 403, forbidden
    app.inspect_error "OPTIMIZER", "Insecure path", req.url
    throw 403  

  # do we want to advertise what kind of server we're running?
  res.removeHeader "X-Powered-By"

  next()
