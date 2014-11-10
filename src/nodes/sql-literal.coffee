u = require 'underscore'

Expressions = require('../expressions')
Predications = require('../predications')

class SqlLiteral
  u(@prototype).extend(Expressions, Predications)

  constructor: (@value) ->

  toString: -> "" + @value

exports = module.exports = SqlLiteral
