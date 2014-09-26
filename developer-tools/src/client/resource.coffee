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

  getCollection: (options={})->
    models = options.models
    delete(options.models)

    if options.private is true
      return @newCollection(models, options)
    else
      @collection ||= @newCollection(models, options)

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

  registry: (resourceName, guess=false)->
    result = if resourceName then _resources[resourceName] else _resources
    return result if result

    if result = @registry(util.string.underscored(resourceName), guess)
      return result

    @registry("#{util.string.underscored(resourceName)}".toLowerCase(), true) unless guess

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

  belongsTo: ->
    # TODO
    # Implement

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
