Node = require './node'

class True extends Node
  equals: (other) ->
    other && @constructor == other.constructor

module.exports = True
