Nodes = require '../nodes'
ToSql = require './to-sql'

class RowNumber
  constructor: (@children) ->

class MSSQL extends ToSql
  visitRelNodesRowNumber: (o, collector) ->
    collector.append "ROW_NUMBER() OVER ("
    if o.children?.length
      collector.append "ORDER BY "
      @injectJoin o.children, collector, ", "
    else
      collector.append "SELECT 0"
    collector.append ") as _row_num"

  visitRelNodesSelectStatement: (o, collector) ->
    return super(o, collector) if !o.limit && !o.offset

    isSelectCount = false
    for x in o.cores
      coreOrderBy = @rowNumLiteral(@determineOrderBy(o.orders, x))
      if @isSelectCount(x)
        x.projections = [ coreOrderBy ]
        isSelectCount = true
      else
        x.projections.push(coreOrderBy)

    if isSelectCount
      # fixme count distinct wouldn't work with limit or offset
      collector.append "SELECT COUNT(1) as count_id FROM ("

    collector.append "SELECT _t.* FROM ("

    for core in o.cores
      @visit core, collector

    collector.append ") as _t WHERE #{@getOffsetLimitClause(o)}"

    if isSelectCount
      collector.append(") AS subquery")

  getOffsetLimitClause: (o) ->
    firstRow = if o.offset? then o.offset.expr + 1 else 1
    lastRow = if o.limit? then o.limit.expr - 1 + firstRow

    if lastRow
      "_row_num BETWEEN #{firstRow} AND #{lastRow}"
    else
      "_row_num >= #{firstRow}"

  determineOrderBy: (orders, x) ->
    if orders?.length
      orders
    else if x.groups?.length
      x.groups
    else
      []

  rowNumLiteral: (orderBy) ->
    new RowNumber(orderBy)

  isSelectCount: (x) ->
    x.projections.length == 1 && x.projections[0].constructor == Nodes.Count

module.exports = MSSQL
