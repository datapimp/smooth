require("semantic/build/packaged/javascript/semantic.js")
require("semantic/build/packaged/css/semantic.css")
require("./styles/index.scss")

React         = require("react")
Backbone      = require("backbone"); require("backbone-react-component")

Router        = require('react-router-component')
Link          = Router.Link

Locations     = Router.Locations
Location      = Router.Location

Sidebar           = require("./inspector/views/sidebar")
IndexPage         = require("./inspector/pages/index")
ApisIndexPage     = require("./inspector/pages/apis")

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
            <Location path="/smooth-developer-tools" handler={IndexPage} />
            <Location path="/smooth-developer-tools/apis" handler={ApisIndexPage} />
          </Locations>
        </div>
      </div>
    </div>

$ ->
  React.renderComponent(Application(), document.getElementById('application'))
