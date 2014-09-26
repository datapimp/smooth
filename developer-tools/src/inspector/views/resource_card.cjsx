module.exports = ResourceCard = React.createClass
  prepareRouteItem: (description, pattern)->
    <div className="ui item">
      <div className="content">
        <div className="header">{description}</div>
        <div className="description">{pattern}</div>
      </div>
    </div>

  render: ->
    resource = @props.resource
    
    routeItems = _(resource.get("routes")).map(@prepareRouteItem)

    <div key={resource.cid} className="column">
      <div className="ui segment stacked">
        <h3>{resource.get('resourceName')}</h3>
        <div className="ui very relaxed divided list">
          {routeItems}
        </div>
      </div>
    </div>

