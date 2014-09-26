/**
 * @see http://webpack.github.io/docs/configuration.html
 * for webpack configuration options
 */
var webpack = require("webpack");

module.exports = {
  context: __dirname,

  node: {
      fs: "empty",
      child_process:"empty",
      net: "empty",
      hiredis: "empty",
      msgpack: "empty"
  },

  entry: {
    dev: "webpack-dev-server/client?http://localhost:4000",
    hot_dev: "webpack/hot/dev-server",
    client: "./src/client.coffee",
    inspector: "./src/inspector.cjsx"
  },

  output: {
    filename: "express-bundle.js",
    path: __dirname + "/dist"
  },

  resolve: {
    extensions: ["",".js",".coffee",".cjsx",".scss",".html"],
    modulesDirectories: [
      'node_modules', 
      'bower_components'
    ],
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.ProvidePlugin({
      "_": "underscore",
      "Backbone": "backbone",
      "React": "react",
      "Backbone.React.Component": "backbone-react-component"
    }) 
  ],

  externals:{
    "jquery": "var jQuery",
    "$"     : "var jQuery"
  },

  // The 'module' and 'loaders' options tell webpack to use loaders.
  // @see http://webpack.github.io/docs/using-loaders.html
  module: {
    loaders: [
      { test: /\.coffee$/, loaders: ["coffee-loader"] },
      { test: /\.cjsx$/, loaders: ["react-hot","coffee-loader","cjsx-loader"] },
      { test: /\.scss$/, loader: "style!css!sass?outputStyle=expanded"},
      { test: /\.css$/, loader: "style!css!sass?outputStyle=expanded"},
      {test: /\.(jpg|png|gif|svg)/, loader: 'file-loader?path=smooth-developer-tools'},
      {test: /\.(eot|ttf|woff)/, loader: 'file-loader?path=smooth-developer-tools'}
    ]
  }
};
