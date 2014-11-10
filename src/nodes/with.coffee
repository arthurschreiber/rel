Unary = require './unary'

class With extends Unary
  Object.defineProperty @prototype, 'children',
    get: () -> @expr
    set: (@expr) ->

module.exports = With
