Node = require './node'

class False extends Node
  equals: (other) ->
    other && @constructor == other.constructor

module.exports = False
