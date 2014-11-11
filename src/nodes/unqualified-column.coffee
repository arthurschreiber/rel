Unary = require './unary'

class UnqualifiedColumn extends Unary
  attribute: (attr) ->
    if attr?
      @expr = attr
    else
      @expr

  Object.defineProperty @prototype, 'relation',
    get: ->
      @expr.relation

  Object.defineProperty @prototype, 'column',
    get: ->
      @expr.column

  Object.defineProperty @prototype, 'name',
    get: ->
      @expr.name

module.exports = UnqualifiedColumn