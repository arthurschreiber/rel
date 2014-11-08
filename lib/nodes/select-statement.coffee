u = require 'underscore'

Nodes = require './nodes'

class SelectStatement
  constructor: (@cores) ->
    @cores = [new Nodes.SelectCore()] unless @cores?
    @orders = []
    @limit = null
    @lock = null
    @offset = null
    @with = null
    
  initializeCopy: (other) ->
    super()
    # TODO Not sure if this will work as expected.
    @cores = u(@cores).map (x) -> 
      u(x).clone()
    @orders = u(@orders).map (x) -> 
      u(x).clone()

exports = module.exports = SelectStatement
