Node = require './node'

class Binary extends Node
  constructor: (@left, @right) ->

  equals: (other) ->
    return false unless other
    return false unless other.constructor == @constructor

    if @left instanceof Node && other.left instanceof Node
      return false if !@left.equals(other.left)
    else
      return false if @left != other.left

    if @right instanceof Node && other.right instanceof Node
      return false if !@right.equals(other.right)
    else
      return false if @right != other.right

    true

exports = module.exports = Binary
