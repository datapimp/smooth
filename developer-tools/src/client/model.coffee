_         = require("underscore")
util      = require("../util")
Backbone  = require("backbone")

module.exports = Model = Backbone.Model.extend
  read: (attr)->
    if _.isFunction(@[attr])
      @[attr].call(@)
    else
      @get(attr) || @[attr]

