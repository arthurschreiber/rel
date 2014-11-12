Nodes = require './index'
Visitors = require '../visitors'
SQLString = require '../collectors/sql-string'

class Node
  not: ->
    new Nodes.Not(@)
    
  or: (right) ->
    new Nodes.Grouping(new Nodes.Or(@, right))
    
  and: (right) ->
    new Nodes.And([@, right])
    
  # TODO Implement each and toSql
  toSql: (engine) ->
    throw new Error("Node#toSql: missing engine") unless engine?

    collector = new SQLString
    engine.visitor().accept @, collector
    collector.value
  
exports = module.exports = Node
