const path = require('path');
const glob = require('glob');
const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require("terser-webpack-plugin");
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin(),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    app: ['./js/app.js'],
    public: ['./js/public.js'],
    layout: ['./js/layout.js'],
    client: ['./client/src/index.js'],
    preview: ['./client/src/preview.js']
  },
  output: {
    path: path.resolve(__dirname, '../priv/static/js'),
    publicPath: ''
  },
  mode: 'none',
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'url-loader',
        options: {
          limit: 10000,
          name: '../css/[name].[ext]',
          mimetype: 'application/font-woff',
          fallback: 'file-loader'
        }
      },
      {
        test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'url-loader',
        options: {
          limit: 10000,
          name: '../css/[name].[ext]',
          mimetype: 'application/octet-stream',
          fallback: 'file-loader'
        }
      },
      {
        test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'file-loader',
        options: {
          name: '../css/[name].[ext]'
        }
      },
      {
        test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'url-loader',
        options: {
          limit: 10000,
          name: '../css/[name].[ext]',
          mimetype: 'application/image/svg+xml',
          fallback: 'file-loader'
        }
      },      
      {
        test: /\.png(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'url-loader',
        options: {
          limit: 10000,
          name: '../css/[name].[ext]',
          mimetype: 'image/png',
          fallback: 'file-loader'
        }
      },
      {
        test: /\.s?css$/,
        use: [MiniCssExtractPlugin.loader, 
          { 
            loader: 'css-loader',
            options: {
              url: false
            }
          },
          'sass-loader'
        ],
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
    new CopyWebpackPlugin({patterns: [{ from: 'node_modules/uswds/dist/img', to: '../assets/img/' },
    { from: 'node_modules/uswds/dist/fonts', to: '../fonts/' },
    { from: 'node_modules/@fortawesome/fontawesome-free/webfonts', to: '../fonts/webfonts' },
    { from: 'static/', to: '../' }]}),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery'
    })
  ],
  resolve: {
    extensions: [".js", ".jsx", ".json"]
  }
});