module.exports = ResourceCard = React.createClass
  prepareRouteItem: (description, pattern)->
    <div className="ui item">
      <div className="content">
        <div className="header">{description}</div>
        <div className="description">{pattern}</div>
      </div>
    </div>
  
  prepareCommandItem: (item, key)->
    key = "#{item.class}-#{key}"
    console.log(key, item.class)
    <span key={key} className="ui item">{item.class}</span>

  render: ->
    resource = @props.resource
    
    routeItems        = _(resource.get("routes")).map(@prepareRouteItem)
    #commandItems      = _(resource.get("commands")).map(@prepareCommandItem)
    #serializerItems   = _(resource.get("commands")).map(@prepareCommandItem)
    #exampleItems      = _(resource.get("commands")).map(@prepareCommandItem)
    #queryItems        = _(resource.get("commands")).map(@prepareCommandItem)
    
    <div key={resource.cid} className="column resource-card">
      <div className="ui segment raised">
        <h2>{resource.get('resourceName')}</h2>
        <p>{resource.get("group_description")}</p> 
        <div className="ui ribbon label">Routes</div>
        <div className="ui route-table very relaxed divided list">
          {routeItems}
        </div>
      </div>
    </div>

