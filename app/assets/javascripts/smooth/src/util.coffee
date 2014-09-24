_ = require "underscore"

module.exports = util = {}

_.extend(util, inflections: require("inflection"), string:require("underscore.string"))

util.chunk = (data, size)->
  _.chain(data).groupBy((element, index)-> Math.floor(index/size)).toArray().value()

util.classify = (string, forceSingular = true)->
  string = util.singularize(string) if forceSingular
  classified = util.string.capitalize(util.string.camelize(string))
  classified

# A safe way of arriving at a value from a string
# that does not use eval
util.resolve = (string, root)->
  parts = string.split('.')
  _(parts).reduce (memo,part)->
    memo[part]
  , root

util.read = (value)->
  if _.isFunction(value) then value() else value
