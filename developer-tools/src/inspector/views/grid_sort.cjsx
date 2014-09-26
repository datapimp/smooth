util = require("../../util.coffee")

module.exports = GridSort = React.createClass
  propTypes:
    prepare: React.PropTypes.func.isRequired
    perRow: React.PropTypes.number.isRequired

  prepareRow: (row, rowIndex)->
    items = _(row).map(@props.prepare)

    <div className="row" key={rowIndex}>
      {items}
    </div>

  render: ->
    groups = util.chunk(@props.items, @props.perRow)
    
    rowIndex = 0
    stackable = "stackable" if @props.stackable

    <div className="ui #{ stackable } grid column #{util.wordsForNumber(@props.perRow)}">
      {@prepareRow(row, rowIndex += 1) for row in groups}
    </div>
