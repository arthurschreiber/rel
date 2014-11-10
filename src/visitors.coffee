u = require 'underscore'

Dot = require './visitors/dot'
Postgresql = require './visitors/postgresql'
ToSql = require './visitors/to-sql'

u.extend module.exports,
  Dot: Dot
  visitor: ->
    # TODO figure out a factory way of returning the
    new Postgresql()
  ToSql: ToSql
  JoinSql:
    visitRelNodesSelectCore: (o) ->
      (o.source.right.map (j) => @visit(j)).join ' '
  OrderClauses: class OrderClauses extends ToSql
    visitRelNodesSelectStatement: (o) ->
      o.orders.map (x) => @visit(x)
  WhereSql: class WhereSql extends ToSql
    visitRelNodesSelectCore: (o) ->
      "WHERE #{(o.wheres.map (x) => @visit x).join ' AND ' }"
