require("semantic/build/packaged/css/semantic.css")
require("./styles/index.scss")
require("semantic/build/packaged/javascript/semantic")

React         = require("react")
Backbone      = require("backbone"); require("backbone-react-component")

Router        = require('react-router-component')
Link          = Router.Link

Locations     = Router.Locations
Location      = Router.Location

Sidebar       = require("./inspector/views/sidebar")
IndexPage     = require("./inspector/pages/index")

Application = React.createClass
  onBeforeNavigation: ->
    console.log("App on Before Navigation")

  onNavigation: ->
    console.log("App on Navigation")

  render: ->
    <div className="wrapper">
      <Sidebar style="inverted thin vertical floating menu" />
      <div className="ui page grid">
        <div className="column">
          <Locations onBeforeNavigation={@onBeforeNavigation} onNavigation={@onNavigation}>
            <Location path="/smooth/interface" handler={IndexPage} />
          </Locations>
        </div>
      </div>
    </div>

$ ->
  React.renderComponent(Application(), document.getElementById('application'))
