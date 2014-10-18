_             = require("underscore")
util          = require("../util")
Model         = require("./model")
Collection    = require("./collection")

definitions = {}

_resources = {}

module.exports = class Resource
  constructor: (options={})->
    _.extend(@, options)

  getDefinition: ->
    @definition

  getModelClass: ->
    return @definition.modelClass

  newModel:(attributes={}, options={})->
    new @getModelClass()(attributes, options)

  fetch: (options)->
    @getCollection(options).fetch(options)

  find: (id)->
    @getCollection().get(id)

  getCollection: (options={})->
    models = options.models
    delete(options.models)

    if options.private is true
      return @newCollection(models, options)
    else
      @singleton ||= @newCollection(models, options)

  newCollection:(models=[], options={})->
    new @definition.collectionClass(models, options)

_.extend Resource,
  define: (resourceName, options={}, fn=->)->
    if _.isFunction(options)
      fn = options
      options = {}

    resourceName = "#{util.string.underscored(resourceName)}".toLowerCase()

    definition = definitions[resourceName] ||= new ResourceDefinition(resourceName, options)

    fn?.call(definition, resourceName, options)

    _resources[resourceName] = definition.build()

    definition

  reopen: (resourceDefinition)->
    definitions[resourceDefinition]

  registry: (resourceName, thisIsAGuess=false)->
    # correct guess, first try. great champ.
    if result = _resources[resourceName]
      return result

    # try an underscored version of whatever was passed.
    if result = @registry(util.string.underscored(resourceName), isAGuess)
      return result

    # Try one guess, maybe they should lowercase and underscore it
    unless thisIsAGuess
      @registry("#{util.string.underscored(resourceName)}".toLowerCase(), true)

class ModelDslAdapter
  constructor: (definition={})->
    @definition = definition

  url: (url)->
    @definition.url = url

  public: (extensions)->
    # TODO
    # Build the meta table
    _.extend(@definition, extensions)

  private: (extensions)->
    # TODO
    # Build the meta table
    _.extend(@definition, extensions)

  belongsTo: (relation, options={})->

  hasMany: ->
    # TODO
    # Implement

class CollectionDslAdapter extends ModelDslAdapter
  name: "CollectionDslAdapter"

class ResourceDefinition
  constructor: (resourceName, options={})->
    @resourceName = resourceName
    @options      = options

    @_collection_interface = {
      public: []
      private: []
    }

    @_model_interface = {
      public: [],
      private: []
    }

    @_collection_definition = {}
    @_model_definition = {}

    @model = new ModelDslAdapter(@_model_definition)

    @collection = new CollectionDslAdapter(@_collection_definition)

  build: ->
    @defineModelClass()
    @defineCollectionClass()
    new Resource(definition: @)

  defineModelClass: ->
    @modelClass ||= Model.extend(@model.definition || {})

  defineCollectionClass: ->
    definition = @collection.definition || {}
    definition.model = @modelClass || @defineModelClass()
    @collectionClass = Collection.extend(definition)
