u = require 'underscore'

SelectManager = require './select-manager'
Range = require './range'
Nodes = require './nodes'

u.extend module.exports,
  as: (other) ->
    lit = new Nodes.UnqualifiedColumn(other)
    new Nodes.As @, lit
    
  notEq: (other) ->
    new Nodes.NotEqual @, other
  
  notEqAny: (others) ->
    @groupingAny 'notEq', others
    
  notEqAll: (others) ->
    @groupingAll 'notEq', others

  isNull: -> new (Nodes).IsNull(@)
  notNull: -> new (Nodes).NotNull(@)
    
  eq: (other) ->
    new Nodes.Equality @, other
    
  eqAny: (others) ->
    @groupingAny 'eq', others
    
  eqAll: (others) ->
    @groupingAll 'eq', others
    
  # TODO Ranges won't work here. Should support an array.
  in: (other) ->
    switch other.constructor
      when SelectManager
        new Nodes.In(@, other.ast)
      when Range
        new Nodes.Between(@, new Nodes.And([other.start, other.finish])) # Start and finish from range.
      else
        new Nodes.In @, other
    
  inAny: (others) ->
    @groupingAny 'in', others
    
  inAll: (others) ->
    @groupingAll 'in', others
    
  # TODO Ranges won't work here. Should support an array.
  notIn: (other) ->
    switch other.constructor
      when SelectManager
        new Nodes.NotIn(@, other.ast)
      else
        new Nodes.NotIn(@, other)
  
  notInAny: (others) ->
    @groupingAny 'notIn', others
    
  notInAll: (others) ->
    @groupingAll 'notIn', others
    
  matches: (other) ->
    new Nodes.Matches @, other
    
  matchesAny: (others) ->
    @groupingAny 'matches', others
    
  matchesAll: (others) ->
    @groupingAll 'matches', others
    
  doesNotMatch: (other) ->
    new Nodes.DoesNotMatch @, other
    
  doesNotMatchAny: (others) ->
    @groupingAny 'doesNotMatch', others
    
  doesNotMatchAll: (others) ->
    @groupingAll 'doesNotMatch', others
    
  # Greater than
  gteq: (right) ->
    new Nodes.GreaterThanOrEqual @, right
    
  gteqAny: (others) ->
    @groupingAny 'gteq', others
    
  gteqAll: (others) ->
    @groupingAll 'gteq', others
    
  gt: (right) ->
    new Nodes.GreaterThan @, right
    
  gtAny: (others) ->
    @groupingAny 'gt', others
    
  gtAll: (others) ->
    @groupingAll 'gt', others
    
  # Less than
  lteq: (right) ->
    new Nodes.LessThanOrEqual @, right
    
  lteqAny: (others) ->
    @groupingAny 'lteq', others
    
  lteqAll: (others) ->
    @groupingAll 'lteq', others
    
  lt: (right) ->
    new Nodes.LessThan(@, right)
    
  ltAny: (others) ->
    @groupingAny 'lt', others
    
  ltAll: (others) ->
    @groupingAll 'lt', others

  like: (right) -> new (Nodes).Like(@, right)
  ilike: (right) -> new (Nodes).ILike(@, right)
    
  asc: ->
    new Nodes.Ascending @
    
  desc: ->
    new Nodes.Descending @
    
  groupingAny: (methodId, others) ->
    nodes = u.map(others, (expr) => @[methodId](expr))
    
    new Nodes.Grouping(u.reduce(nodes, (memo, node) ->
      new Nodes.Or(memo, node)
    ))
    
  groupingAll: (methodId, others) ->
    nodes = u.map(others, (expr) => @[methodId](expr))
    
    new Nodes.Grouping(u.reduce(nodes, (memo, node) ->
      new Nodes.And(memo, node)
    ))
