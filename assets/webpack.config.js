const AngularWebpackPlugin = require('@ngtools/webpack').AngularWebpackPlugin
const path = require('path')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const webpack = require('webpack')

const config = {
  mode: 'production',
  entry: {
    main: ['./src/app.ts'],
    style: ['./src/style.css'],
    theme: ['./src/theme.scss'],
  },
  output: {
    path: path.resolve(__dirname, path.join('..', 'priv', 'static', 'bundles')),
    filename: '[name].js',
    chunkFilename: '[name]-chunk.js',
  },
  resolve: {
    extensions: ['.ts', '.js', '.scss'],
    modules: ['src', 'node_modules'],
  },
  module: {
    rules: [
      {
        test: /(?:\.ngfactory\.js|\.ngstyle\.js|\.ts)$/,
        use: [{loader: '@ngtools/webpack'}],
      },
      {
        test: /\.css(\?v=\d+\.\d+\.\d+)?$/,
        use: [{ loader: 'style-loader' }, { loader: 'css-loader' }],
      },
      {
        test: /\.less(\?v=\d+\.\d+\.\d+)?$/,
        use: [
          { loader: 'to-string-loader' },
          { loader: 'css-loader' },
          { loader: 'less-loader' },
        ],
      },
      {
        test: /\.scss(\?v=\d+\.\d+\.\d+)?$/,
        use: [
          { loader: 'style-loader' },
          { loader: 'css-loader' },
          { loader: 'sass-loader' },
        ],
      },
      {
        test: /\.(ttf|otf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
        use: [{ loader: 'file-loader?name=fonts/[name].[ext]' }],
      },
      {
        test: /\.html$/,
        use: [{ loader: 'raw-loader' }],
      },
    ],
  },
  optimization: {
    splitChunks: {
      chunks: 'all',
    },
  },
  plugins: [
    new AngularWebpackPlugin({
      tsConfigPath: './tsconfig.json',
      entryModule: './src/app/app.ts#AppModule'
    }),
    new CopyWebpackPlugin({
      patterns: [{ from: './static', to: '.' }],
    }),
    new webpack.ContextReplacementPlugin(
      /@angular(\\|\/)core(\\|\/)esm5/,
      path.join(__dirname, './assets'),
    ),
  ],
}

module.exports = config
