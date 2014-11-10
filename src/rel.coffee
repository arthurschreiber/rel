Nodes = require './nodes'
Range = require './range'
Table = require './table'
Visitors = require './visitors'
SelectManager = require './select-manager'
InsertManager = require './select-manager'
UpdateManager = require './select-manager'
CaseBuilder = require './nodes/case-builder'

Rel =
  VERSION: '0.0.1'

  sql: (rawSql) ->
    new Nodes.SqlLiteral rawSql

  star: ->
    @sql '*'

  range: (start, finish) ->
    new Range(start, finish)

  func: (name) -> (args...) =>
    new Nodes.FunctionNode(args, @sql(name))

  lit: (value) -> new Nodes.ConstLit(value)

  Nodes: Nodes

  Table: Table

  Visitors: Visitors

  table: (args...) -> new Table(args...)
  select: -> new SelectManager()
  insert: -> new InsertManager()
  update: -> new UpdateManager()
  case: (args...) -> new CaseBuilder(args...)

exports = module.exports = Rel
