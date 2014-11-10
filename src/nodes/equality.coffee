Binary = require './binary'

class Equality extends Binary
  constructor: (@left, @right) ->
    super @left, @right
    @operator = '=='
    @operand1 = @left
    @operand2 = @right

module.exports = Equality
