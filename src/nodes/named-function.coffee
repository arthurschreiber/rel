FunctionNode = require './function-node'

class NamedFunction extends FunctionNode
  constructor: (@name, expr, alias) ->
    super(expr, alias)

  equals: (other) ->
    super(other) && @name == other.name

module.exports = NamedFunction