/**
 * @see http://webpack.github.io/docs/configuration.html
 * for webpack configuration options
 */
var webpack = require("webpack");

module.exports = {
  context: __dirname,

  entry: {
    client: "./src/client.coffee",
    inspector: "./src/inspector.coffee"
  },

  output: {
    path: __dirname,
    filename: "[name].js",
    library: ["Smooth","[name]"],
    libraryTarget: "umd" 
  },

  resolve: {
    extensions: ["",".js",".coffee",".cjsx"],
    modulesDirectories: [
      'node_modules', 
      'bower_components'
    ],
  },

  plugins: [
    new webpack.ProvidePlugin({
      "_": "underscore",
      "Backbone": "backbone",
      "React": "react"
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
      { test: /\.cjsx$/, loaders: ["coffee-loader","cjsx-loader"] }
    ]
  }
};
