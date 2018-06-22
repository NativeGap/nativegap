const environment = require('./environment')
const erb =  require('./production/loaders/erb')

environment.loaders.append('erb', erb)
module.exports = environment.toWebpackConfig()
