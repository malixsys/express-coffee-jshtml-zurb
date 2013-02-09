class DB
  constructor: () ->
    v = 1
  load_user: (app, login, done) ->
    process.nextTick ->
      done null,
        login: login

exports.DB = DB
exports.init = (app) ->
  app.DB = new DB()
