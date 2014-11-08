u = require 'underscore'

Expressions = require('../expressions')
Predications = require('../predications')

class SqlLiteral
  constructor: (@value) ->
    u(@).extend(Expressions)
    u(@).extend(Predications)

  toString: ->
    @value

exports = module.exports = SqlLiteral
