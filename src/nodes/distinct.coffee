Node = require './node'

class Distinct extends Node
  equals: (other) ->
    other && @constructor == other.constructor