const environment = require('./environment')
const erb =  require('./development/loaders/erb')

environment.loaders.append('erb', erb)
module.exports = environment.toWebpackConfig()
