util = require("util")
inspect = (obj) ->
  util.log util.inspect obj

fs      = require("fs")
path    = require("path")
jsHtml  = require('jshtml');

exports.render = (file, ctx, done) ->
  try
    str = render file, ctx
    process.nextTick () ->
      done(null, str)
  catch exc
    process.nextTick () ->
      done(exc)

render = (view, ctx) ->
  str = fs.readFileSync(view, "utf8")
  fn = jsHtml.compile str, {}
  html = fn(ctx)
  return html


exports.init = (app) ->

  get_engine = (ext) ->

    return (file, ctx, callback) ->
      context = ctx or {}
      dir = path.dirname(file)
      layout = path.join(dir, ('_layout' + ext))

      try
        str = render file, context
        html = ""

        if fs.existsSync(layout) and file.indexOf("_nolayout") is -1
          html = render layout, app.utils.merge(context,{body: str})
        else
          html = str
        callback(null, html)
      catch err
        html = util.inspect
          error: err
          file: file
          , true,4,false
        callback(null, "<pre>#{html}</pre>")

  app.engine('html', get_engine('.html'))
  app.set('view engine', 'html')
  app.set('views', path.join(__dirname, "../views"))

  return app
