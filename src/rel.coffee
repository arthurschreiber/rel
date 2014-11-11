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

  Nodes: Nodes

  Table: Table

  Visitors: Visitors

  Collectors: require './collectors'

  SelectManager: SelectManager
  InsertManager: InsertManager
  UpdateManager: UpdateManager

exports = module.exports = Rel
