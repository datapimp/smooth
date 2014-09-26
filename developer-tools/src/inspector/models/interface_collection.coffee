_ = require "underscore"

InterfaceDocumentation = Backbone.Model.extend(url:->"/api/architects/interface/#{@resource_id}")

InterfaceCollection = Backbone.Collection.extend
  model: InterfaceDocumentation

  url: ->
    # TODO
    window.SmoothInterfaceEndpoint || "/api/architects/interface"

  parse:(response)->
    {api_meta} = response

    @meta = api_meta

    resourceObjects = @toResourceObjects(response)
    console.log("Resources", resourceObjects)
    resourceObjects

  toResourceObjects:(response)->
    {api_meta} = response
    resource_names = api_meta?.resource_names || []

    for resourceName in api_meta.resource_names
      resource = response[resourceName] || {}

      _.extend resource,
        resourceName: resourceName

module.exports = InterfaceCollection
