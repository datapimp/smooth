var webpack = require("webpack"),
    WebpackDevServer = require("webpack-dev-server"),
    config = require("./webpack.hot.config");


var server = new WebpackDevServer(webpack(config), {
  publicPath: config.output.publicPath,
  hot: true,
  stats: {
    colors: true
  }
});

server.listen(4000,'localhost');
