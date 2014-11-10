Unary = require './unary'

class Extract extends Unary
  constructor: (expr, @field) ->
    super(expr)

  equals: (other) ->
    # TODO

module.exports = Extract