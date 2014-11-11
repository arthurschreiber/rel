u = require 'underscore'

FactoryMethods = require './factory-methods'
Visitors = require('./visitors')
Collectors = require './collectors'

class TreeManager
  u.extend(@prototype, FactoryMethods)

  constructor: (@engine) ->
    # TODO need to implement engines with a factory.
    @visitor = @engine.visitor()
    @ast = null
    @ctx = null

  toDot: ->
    new Visitors.Dot().accept @ast

  toSql: ->
    collector = new Collectors.SQLString
    @visitor.accept @ast, collector
    collector.value

  initializeCopy: (other) ->
    super()
    @ast = u(@ast).clone()

  where: (expr) ->
    if TreeManager == expr.constructor
      expr = expr.ast
    @ctx.wheres.push expr
    @

exports = module.exports = TreeManager
