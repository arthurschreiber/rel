Node = require './node'

class And extends Node
  constructor: (children, right=null) ->
    unless Array == children.constructor
      children = [children, right]

    @children = children

  left: ->
    @children.first

  right: ->
    @children[1]

  equals: (other) ->
    return false unless other
    return false unless other.constructor == @constructor
    return false unless @children.length == other.children.length

    for i in [0..@children.length]
      if @children[i] instanceof Node && other.children[i] instanceof Node
        if !@children[i].equals(other.children[i])
          return false
      else if @children[i] != other.children[i]
        return false

    true

exports = module.exports = And
