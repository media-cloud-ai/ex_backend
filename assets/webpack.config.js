const path = require("path")
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const webpack = require("webpack");

const config = {
  mode: 'production',
  entry: {
    "common": [
      "./src/common.ts"
    ],
    "main": [
      "./src/app.ts",
    ],
    "style": [
      "./src/style.css"
    ],
    "theme": [
      "./src/theme.scss",
    ]
  },
  output: {
    path: path.resolve(__dirname, path.join("..", "priv", "static", "bundles")),
    filename: "[name].js"
  },
  resolve: {
    extensions: [".ts", ".js", ".scss"],
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
        loaders: ["to-string-loader", "css-loader", "less-loader"]
      },
      {
        test: /\.scss(\?v=\d+\.\d+\.\d+)?$/,
        loaders: ["style-loader", "css-loader", "sass-loader"]
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
    new CopyWebpackPlugin([{ from: "./static" }]),
    new webpack.ContextReplacementPlugin(
      /\@angular(\\|\/)core(\\|\/)esm5/,
      path.join(__dirname, './assets')
    ),
  ]
};

module.exports = config;
