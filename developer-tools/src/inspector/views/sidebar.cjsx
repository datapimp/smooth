Link        = require('react-router-component').Link

module.exports = Sidebar = React.createClass
  componentDidMount: ->
    $(@getDOMNode()).sidebar()

  render: ->
    <div className="ui sidebar #{ @props.style }">
      <Link className="item" href="/resources">
        <i className="icon lab" />
      </Link>
    </div>
