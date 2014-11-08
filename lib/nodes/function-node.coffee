u = require 'underscore'

Node = require './node'
SqlLiteral = require './sql-literal'
Expressions = require '../expressions'
Predications = require '../predications'

class FunctionNode extends Node
  u(@prototype).extend Expressions, Predications

  constructor: (expr, aliaz=null) ->
    @expressions = expr
    @alias = aliaz
    @distinct = false

  as: (aliaz) ->
    @alias = new SqlLiteral(aliaz)
    @

exports = module.exports = FunctionNode
