const path = require('path');
const glob = require('glob');
const TerserPlugin = require("terser-webpack-plugin");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const webpack = require('webpack');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';
  return {
    optimization: {
      minimize: devMode ? undefined : true,
      minimizer: [
        `...`,
        new TerserPlugin({  parallel: true }),
        new CssMinimizerPlugin(),
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
          test: /\.s?css$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                publicPath: '/',
              },
            },
            {
              loader: 'css-loader',
              options: {
                url: (url, resourcePath) => {
                  if (resourcePath.includes("assets/css")) {
                    return false;
                  }
                  return true;
                }
              }
            },
            'sass-loader',
          ]
        },
        {
          test: /\.svg$/i,
          type: 'asset/inline'
        },
        {
          test: /\.(png|jpg|jpeg|gif)$/i,
          type: 'asset/resource',
        },
        {
          test: /\.(woff|woff2|eot|ttf|otf)/i,
          use: [
            {
              loader: 'url-loader',
              options: {
                name: '../css/[name].[ext]',
                fallback: 'file-loader'
              }
            }
          ]
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
      new CopyWebpackPlugin({
        patterns: [
          { from: 'static/', to: '../' }
        ]
      }),
      new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery'
      })
    ]
  }
};
