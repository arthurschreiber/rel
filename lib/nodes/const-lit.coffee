u = require 'underscore'

Unary = require './unary'
SqlLiteral = require './sql-literal'
Expressions = require '../expressions'
Predications = require '../predications'

class ConstLit extends Unary
  u(@prototype).extend Expressions, Predications

  constructor: (args...) ->
    super(args...)

exports = module.exports = ConstLit
