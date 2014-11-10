Unary = require './unary'

class UnqualifiedColumn extends Unary
  attribute: (attr) ->
    if attr?
      @expr = attr
    else
      @expr

  relation: ->
    @expr.relation

  column: ->
    @expr.column

  name: ->
    @expr

module.exports = UnqualifiedColumn