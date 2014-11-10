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

  equals: (other) ->
    return false unless other
    return false unless other.constructor == @constructor

    if @expressions instanceof Node && other.expressions instanceof Node
      return false if !@expressions.equals(other.expressions)
    else
      return false if @expressions != other.expressions

    if @alias instanceof Node && other.alias instanceof Node
      return false if !@alias.equals(other.alias)
    else
      return false if @alias != other.alias

    return false if @distinct != other.distinct

    true

exports = module.exports = FunctionNode
