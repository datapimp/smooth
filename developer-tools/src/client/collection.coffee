_         = require("underscore")
util      = require("../util")
Backbone  = require("backbone")

module.exports = Collection = Backbone.Collection.extend
  initialize: (models=[], options={})->

    if @bootstrap && window?.BootstrappedCollections?[@boostrap]
      models = window.BootstrappedCollections[@bootstrap]

    Backbone.Collection::initialize.apply(@, arguments)

  inChunksOf: (size)->
    util.chunk(@models, size)
