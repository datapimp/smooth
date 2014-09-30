Link          = require('react-router-component').Link
IconHeading   = require("../views/icon_heading")
GridSort      = require("../views/grid_sort")
ResourceCard  = require("../views/resource_card")
Toolbar       = require("../views/toolbar")

module.exports = IndexPage = React.createClass
  componentWillMount: ->
    @props.collection.fetch().then ()=> @forceUpdate()
  
  getResourceNames: ->
    names = @state?.interface?.api_meta?.resource_names || []
    names 

  prepareResourceCard: (resource)->
    <ResourceCard key={resource.cid} resource={resource} />

  render: ->
    <div className="page-container">
      <IconHeading title="Smooth API Documentation" />
      
      <div className="ui vertical segment">
        <div className="ui right floated basic segment">
          <Toolbar resourceGroups={@props.collection.pluck('resource_group')}/>
        </div>
      </div>

      <div className="grid-sort-wrapper" style={clear:"both"}>
        <GridSort prepare={@prepareResourceCard} items={@props.collection.models} perRow=3 /> 
      </div>
    </div>
