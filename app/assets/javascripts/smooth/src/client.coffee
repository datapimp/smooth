_ = require("underscore")
$ = require("jquery")

Smooth = {
  version: '0.0.1',
  config: { },

  Util:       require("./util"),
  Model:      require("./client/model"),
  Collection: require("./client/collection"),
  Resource:   require("./client/resource")
}

Smooth.resource = Smooth.Resource.define

Smooth.configure = (options)->
  _.extend(Smooth.config, options)

module.exports = Smooth

window.Smooth = Smooth if typeof(window) isnt "undefined"
