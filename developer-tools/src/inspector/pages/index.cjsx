Router        = require('react-router-component')
Link          = Router.Link

module.exports = IndexPage = React.createClass
  render: ->
    <div>
      <h1>Index Page</h1>
      <Link href="/smooth-developer-tools/apis">APIS</Link>
    </div>
