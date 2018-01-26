const path = require("path")
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

const config = {
  entry: {
    "common": [
      "./js/common.ts"
    ],
    "main": [
      "./js/app.ts",
    ],
    "style": [
      "./css/app.less",
    ]
  },
  output: {
    path: path.resolve(__dirname, path.join("..", "priv", "static", "bundles")),
    filename: "[name].js"
  },
  resolve: {
    extensions: [".ts", ".js"],
    modules: ["deps", "node_modules"]
  },
  module: {
    rules: [
      {
        test: /\.ts?$/,
        loaders: ["awesome-typescript-loader", "angular2-template-loader"]
      },
      {
        test: /\.css(\?v=\d+\.\d+\.\d+)?$/,
        loaders: ["style-loader", "css-loader"]
      },
      {
        test: /\.less(\?v=\d+\.\d+\.\d+)?$/,
        loaders: ["style-loader", "css-loader", "less-loader"]
      },
      {
        test: /\.(ttf|otf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
        loader: 'file-loader?name=fonts/[name].[ext]'
      },
      {
        test: /\.html$/,
        loader: 'raw-loader'
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin("css/style.css"),
    new CopyWebpackPlugin([{ from: "./static" }])
  ]
};

module.exports = config;
