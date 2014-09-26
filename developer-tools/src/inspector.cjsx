require("semantic/build/packaged/javascript/semantic.js")
require("semantic/build/packaged/css/semantic.css")
require("./styles/index.scss")

React         = require("react")
Backbone      = require("backbone"); require("backbone-react-component")

Router        = require('react-router-component')
Link          = Router.Link

Locations     = Router.Locations
Location      = Router.Location

Sidebar                 = require("./inspector/views/sidebar")
IndexPage               = require("./inspector/pages/index")
ResourcesIndexPage      = require("./inspector/pages/resources")

InterfaceCollection     = require("./inspector/models/interface_collection")


Application = React.createClass
  onBeforeNavigation: ->
    console.log("App on Before Navigation")

  onNavigation: ->
    console.log("App on Navigation")
  
  getInterface: ->
    return @_interface if @_interface
    @_interface = new InterfaceCollection()
    @_interface

  render: ->
    <div className="wrapper">
      <Sidebar style="inverted thin vertical floating menu" />
      <div className="ui page grid">
        <div className="column">
          <Locations onBeforeNavigation={@onBeforeNavigation} onNavigation={@onNavigation}>
            <Location path="/smooth-developer-tools" handler={IndexPage} collection={@getInterface()}/>
            <Location path="/smooth-developer-tools" handler={IndexPage} collection={@getInterface()}/>
            <Location path="/smooth-developer-tools/resources" handler={ResourcesIndexPage} />
          </Locations>
        </div>
      </div>
    </div>

$ ->
  prefix = if window.location.port == "4000" then "" else "/smooth-developer-tools"
  React.renderComponent(Application(prefix: prefix), document.getElementById('application'))
