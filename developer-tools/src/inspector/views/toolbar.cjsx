module.exports = Toolbar = React.createClass
  render: ->
    options = @props.resourceGroups.map (groupName)->
      <option>{groupName}</option>

    <div className="ui my-toolbar">
      <div className="ui icon input">
        <input type="text" name="search" placeholder="Search..."/>
        <i className="search icon" />
      </div>
      <div className="ui dropdown">
        <select>
          {options}
        </select>
      </div>
    </div>

