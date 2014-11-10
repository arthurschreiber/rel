Node = require './node'

class Unary extends Node
  constructor: (@expr) ->
    @value = @expr

  equals: (other) ->
    return false unless other && @constructor == other.constructor

    if @expr instanceof Node && other.expr instanceof Node
      return false if !@expr.equals(other.expr)
    else
      return false if @expr != other.expr

    true

exports = module.exports = Unary
