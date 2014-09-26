module.exports = IconHeading = React.createClass
  getDefaultProps: ->
    icon: "cloud"
    iconSize: "large"
    title: ""
    subheading: ""

  render: ->
    <div className="ui large header">
      <i className="icon #{@props.icon} #{@props.iconSize}" />
      <div className="content">
        {@props.title}
        <div className="sub header">{@props.subheading}</div>
      </div>
    </div>
