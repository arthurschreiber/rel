FunctionNode = require './function-node'

class Count extends FunctionNode
  constructor: (expr, @distinct = false, aliaz) ->
    super(expr, aliaz)

module.exports = Count
