Link          = require('react-router-component').Link
IconHeading   = require("../views/icon_heading")
GridSort      = require("../views/grid_sort")
ResourceCard  = require("../views/resource_card")

module.exports = IndexPage = React.createClass
  componentWillMount: ->
    @props.collection.fetch().then ()=> @forceUpdate()
  
  getResourceNames: ->
    names = @state?.interface?.api_meta?.resource_names || []
    names 

  prepareResourceCard: (resource)->
    <ResourceCard key={resource.cid} resource={resource} />

  render: ->
    <div className="">
      <IconHeading title="Smooth API Documentation" />
      <GridSort prepare={@prepareResourceCard} items={@props.collection.models} perRow=3 /> 
    </div>
