const { generateWebpackConfig, merge } = require("shakapacker")

const webpackConfig = generateWebpackConfig()

const options = {
  resolve: {
    extensions: [".mjs", ".js", ".sass",".scss", ".css", ".module.sass", ".module.scss", ".module.css", ".png", ".svg", ".gif", ".jpeg", ".jpg", ".eot", ".ttf", ".woff"]
  }
}

const OFNwebpackConfig = merge(webpackConfig, options) 

// This results in a new object copied from the mutable global
module.exports = OFNwebpackConfig
