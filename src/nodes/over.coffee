Binary = require './binary'

class Over extends Binary
  constructor: (left, right = null) ->
    super(left, right)
    @operator = "OVER"

module.exports = Over
