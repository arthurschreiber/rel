u = require 'underscore'

Reduce = require './reduce'
Nodes = require '../nodes'
SqlLiteral = require '../nodes/sql-literal'
Attributes = require '../attributes'

class ToSql extends Reduce
  constructor: (@engine) ->
    super()

  visitRelNodesDeleteStatement: (o, collector) ->
    collector.append "DELETE FROM "
    @visit o.relation, collector

    if o.wheres?.length
      collector.append " WHERE "
      @injectJoin o.wheres, collector, " AND "

  buildSubselect: (key, o) ->
    stmt = new Nodes.SelectStatement()
    core = stmt.cores[0]
    core.froms = o.relation
    core.wheres = o.wheres
    core.projections = [key]
    stmt.limit = o.limit
    stmt.orders = o.orders
    stmt

  visitRelNodesUpdateStatement: (o, collector) ->
    wheres = if !u.orders?.length && !o.limit?
      o.wheres
    else
      [ new Nodes.In(o.key, [@buildSubselect(o.key, o)]) ]
    
    collector.append "UPDATE "
    @visit o.relation, collector

    if o.values?.length
      collector.append " SET "
      @injectJoin o.values, collector, ", "

    if wheres?.length
      collector.append " WHERE "
      @injectJoin wheres, collector, " AND "

  visitRelNodesInsertStatement: (o, collector) ->
    collector.append "INSERT INTO "
    @visit o.relation, collector

    if o.columns?.length
      collector.append " ("
      collector.append u.map(o.columns, (x) => @quoteColumnName(x.name)).join(', ')
      collector.append ")"

    if o.values
      collector.append " "
      @visit o.values, collector
    else if o.select
      collector.append " "
      @visit o.select, collector

  visitRelNodesExists: (o, collector) ->
    collector.append "EXISTS ("
    @visit o.expressions, collector
    collector.append ")"

    if o.alias
      collector.append " AS "
      @visit o.alias, collector

  # visitRelNodesCasted: (o, collector) ->

  # visitRelNodesQuoted: (o, collector) ->

  # visitRelNodesTrue: (o, collector) ->

  # visitRelNodesFalse: (o, collector) ->

  # TODO implement table exists
  tableExists: (name) ->
    return unless name?

  columnFor: (attr) ->
    return unless attr?

    name = attr.name.toString()
    table = attr.relation.tableName

    @engine.columnFor(table, name)

  visitRelNodesValues: (o, collector) ->
    collector.append "VALUES ("

    expressions = o.expressions()
    last = expressions.length - 1

    for expr, i in expressions
      if expr == null
        collector.append @quote(expr, null)
      else if expr.constructor == SqlLiteral
        @visit expr, collector
      else
        collector.append @quote(expr, null)

      collector.append ", " unless i == last

    collector.append ")"

  visitRelNodesSelectStatement: (o, collector) ->
    if o.with?
      @visit o.with, collector
      collector.append " "

    for core in o.cores
      @visit core, collector

    if o.orders?.length
      collector.append " ORDER BY "
      @injectJoin o.orders, collector, ", "

    @maybeVisit o.limit, collector
    @maybeVisit o.offset, collector
    @maybeVisit o.lock, collector

  visitRelNodesSelectCore: (o, collector) ->
    collector.append "SELECT"

    @maybeVisit(o.top, collector)
    @maybeVisit(o.setQuantifier, collector)

    if o.projections?.length
      collector.append " "
      @injectJoin o.projections, collector, ', '

    if !o.source.isEmpty()
      collector.append " FROM "
      @visit(o.source, collector)

    if o.wheres?.length
      collector.append " WHERE "
      @injectJoin o.wheres, collector, " AND "

    if o.groups?.length
      collector.append " GROUP BY "
      @injectJoin o.groups, collector, ", "

    @maybeVisit(o.having, collector)

  # visitRelNodesBin: (o, collector) ->

  # visitRelNodesDistinct: (o, collector) ->

  # visitRelNodesDistinctOn: (o, collector) ->

  visitRelNodesWith: (o, collector) ->
    collector.append "WITH "
    @injectJoin o.children, collector, ', '

  visitRelNodesWithRecursive: (o, collector) ->
    collector.append "WITH RECURSIVE "
    @injectJoin o.children, collector, ', '

  visitRelNodesUnion: (o, collector) ->
    collector.append "("
    @visit o.left, collector
    collector.append " UNION "
    @visit o.right, collector
    collector.append ")"

  visitRelNodesUnionAll: (o, collector) ->
    collector.append "("
    @visit o.left, collector
    collector.append " UNION ALL "
    @visit o.right, collector
    collector.append ")"

  visitRelNodesIntersect: (o, collector) ->
    collector.append "("
    @visit o.left, collector
    collector.append " INTERSECT "
    @visit o.right, collector
    collector.append ")"

  visitRelNodesExcept: (o, collector) ->
    collector.append "("
    @visit o.left, collector
    collector.append " EXCEPT "
    @visit o.right, collector
    collector.append ")"

  # visitRelNodesNamedWindow: (o, collector) ->

  # visitRelNodesWindow: (o, collector) ->

  # visitRelNodesRows: (o, collector) ->

  # visitRelNodesRange: (o, collector) ->

  # visitRelNodesPreceding: (o, collector) ->

  # visitRelNodesFollowing: (o, collector) ->

  # visitRelNodesCurrentRow: (o, collector) ->

  # visitRelNodesOver: (o, collector) ->

  visitRelNodesHaving: (o, collector) ->
    collector.append "HAVING "
    @visit o.expr, collector

  visitRelNodesOffset: (o, collector) ->
    collector.append "OFFSET "
    @visit o.expr, collector

  visitRelNodesLimit: (o, collector) ->
    collector.append "LIMIT "
    @visit o.expr, collector

  visitRelNodesTop: (o, collector) ->
    # Do nothing

  visitRelNodesLock: (o, collector) ->
    @visit o.expr, collector

  visitRelNodesGrouping: (o, collector) ->
    if o.expr instanceof Nodes.Grouping
      @visit o.expr, collector
    else
      collector.append "("
      @visit o.expr, collector
      collector.append ")"

  visitRelNodesSelectManager: (o, collector) ->
    collector.append "("
    @visit o.ast, collector
    collector.append ")"

  visitRelNodesAscending: (o, collector) ->
    @visit o.expr, collector
    collector.append " ASC"

  visitRelNodesDescending: (o, collector) ->
    @visit o.expr, collector
    collector.append " DESC"

  visitRelNodesGroup: (o, collector) ->
    @visit o.expr, collector

  visitRelNodesNamedFunction: (o, collector) ->
    @aggregate(o.name, o, collector)

  # visitRelNodesExtract: (o, collector) ->

  visitRelNodesCount: (o, collector) ->
    @aggregate "COUNT", o, collector

  visitRelNodesSum: (o, collector) ->
    @aggregate "SUM", o, collector

  visitRelNodesMax: (o, collector) ->
    @aggregate "MAX", o, collector

  visitRelNodesMin: (o, collector) ->
    @aggregate "MIN", o, collector

  visitRelNodesAvg: (o, collector) ->
    @aggregate "AVG", o, collector

  visitRelNodesTableAlias: (o, collector) ->
    @visit o.relation, collector
    collector.append " #{@quoteTableName o.name.toString()}"

  visitRelNodesBetween: (o, collector) ->
    @visit o.left, collector
    collector.append " BETWEEN "
    @visit o.right, collector

  visitRelNodesGreaterThan: (o, collector) ->
    @visit o.left, collector
    collector.append " > "
    @visit o.right, collector

  visitRelNodesGreaterThanOrEqual: (o, collector) ->
    @visit o.left, collector
    collector.append " >= "
    @visit o.right, collector

  visitRelNodesLessThan: (o, collector) ->
    @visit o.left, collector
    collector.append " < "
    @visit o.right, collector

  visitRelNodesLessThanOrEqual: (o, collector) ->
    @visit o.left, collector
    collector.append " <= "
    @visit o.right, collector

  visitRelNodesMatches: (o, collector) ->
    @visit o.left, collector
    collector.append " LIKE "
    @visit o.right, collector

  visitRelNodesDoesNotMatch: (o, collector) ->
    @visit o.left, collector
    collector.append " NOT LIKE "
    @visit o.right, collector

  visitRelNodesJoinSource: (o, collector) ->
    @visit o.left, collector if o.left?

    if o.right?.length
      collector.append " " if o.left?
      @injectJoin o.right, collector, " "

  # visitRelNodesRegexp: (o, collector) ->

  # visitRelNodesNotRegexp: (o, collector) ->

  visitRelNodesStringJoin: (o, collector) ->
    @visit o.left, collector

  visitRelNodesFullOuterJoin: (o, collector) -> @_visitOuterJoin(o, collector, 'FULL')

  visitRelNodesOuterJoin: (o, collector) -> @_visitOuterJoin(o, collector, 'LEFT')

  visitRelNodesRightOuterJoin: (o, collector) -> @_visitOuterJoin(o, collector, 'RIGHT')

  visitRelNodesInnerJoin: (o, collector) ->
    collector.append "INNER JOIN "
    @visit o.left, collector

    if o.right?
      collector.append " "
      @visit o.right, collector

  visitRelNodesOn: (o, collector) ->
    collector.append "ON "
    @visit o.expr, collector

  visitRelNodesNot: (o, collector) ->
    collector.append "NOT ("
    @visit o.expr, collector
    collector.append ")"

  visitRelNodesTable: (o, collector) ->
    collector.append if o.tableAlias?
      "#{@quoteTableName o.name} #{quoteTableName o.tableAlias}"
    else
      @quoteTableName o.name

  visitRelNodesIn: (o, collector) ->
    if u.isArray(o.right) && !o.right.length
      collector.append "1=0"
    else
      @visit o.left, collector
      collector.append " IN ("
      @visit o.right, collector
      collector.append ")"

  visitRelNodesNotIn: (o, collector) ->
    if u.isArray(o.right) && !o.right.length
      collector.append "1=1"
    else
      @visit o.left, collector
      collector.append " NOT IN ("
      @visit o.right, collector
      collector.append ")"

  visitRelNodesAnd: (o, collector) ->
    @injectJoin o.children, collector, ' AND '

  visitRelNodesOr: (o, collector) ->
    @visit o.left, collector
    collector.append " OR "
    @visit o.right, collector

  visitRelNodesAssignment: (o, collector) ->
    if o.right?.constructor in [Nodes.UnqualifiedColumn, Attributes.Attribute, Nodes.BindParam]
      @visit o.left, collector
      collector.append " = "
      @visit o.right, collector
    else
      @visit o.left, collector
      collector.append " = #{@quote(o.right, @columnFor(o.left))}"

  visitRelNodesEquality: (o, collector) ->
    if o.right?
      @visit o.left, collector
      collector.append " = "
      @visit o.right, collector
    else
      @visit o.left, collector
      collector.append " IS NULL"

  visitRelNodesNotEqual: (o, collector) ->
    if o.right?
      @visit o.left, collector
      collector.append " != "
      @visit o.right, collector
    else
      @visit o.left, collector
      collector.append " IS NOT NULL"

  visitRelNodesAs: (o, collector) ->
      @visit o.left, collector
      collector.append " AS "
      @visit o.right, collector

  visitRelNodesUnqualifiedColumn: (o, collector) ->
    collector.append @quoteColumnName o.name() # TODO This probably shouldn't be a function.

  visitRelNodesAttribute: (o, collector) ->
    joinName = (o.relation.tableAlias || o.relation.name).toString()
    collector.append "#{@quoteTableName(joinName)}.#{@quoteColumnName(o.name)}"

  visitRelNodesAttrInteger: (o, collector) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrFloat: (o, collector) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrString: (o, collector) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrTime: (o, collector) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrBoolean: (o, collector) -> @visitRelNodesAttribute(o)

  literal: (o, collector) ->
    collector.append o

  visitRelNodesBindParam: (o, collector) ->
    collector.addBind(o)

  visitRelNodesSqlLiteral: (o, collector) -> @literal(o, collector)

  visitRelNodesNumber: (o, collector) -> @literal(o, collector)

  quoted: (o) ->
    @quote(o, @last_column)

  unsupported: (o, collector) ->
    throw new Error "unsupported #{o}"

  visitRelNodesString: (o, collector) -> collector.append @quoted(o)
  visitRelNodesDate: (o, collector) -> collector.append @quoted(o)
  visitRelNodesBoolean: (o, collector) -> collector.append @quoted(o)

  # visitRelNodesInfixOperation: (o, collector) ->

  # visitRelNodesInfixOperation: (o, collector) ->

  # visitRelNodesAddition: (o, collector) ->

  # visitRelNodesSubstraction: (o, collector) ->

  # visitRelNodesMultiplication: (o, collector) ->

  # visitRelNodesDivision: (o, collector) ->

  visitRelNodesArray: (o, collector) ->
    @injectJoin o, collector, ', '

  quote: (value, column=null) ->
    if value?.constructor == Nodes.SqlLiteral
      value
    else
      @engine.quote(value, column)

  quoteTableName: (name) ->
    if name?.constructor == Nodes.SqlLiteral
      name
    else
      @engine.quoteTableName(name)

  quoteColumnName: (name) ->
    if name?.constructor == Nodes.SqlLiteral
      name
    else
      @engine.quoteColumnName(name)

  maybeVisit: (thing, collector) ->
    if thing?
      collector.append " "
      @visit thing, collector

  injectJoin: (list, collector, joinStr) ->
    last = list.length - 1

    for x, i in list
      @visit(x, collector)
      collector.append(joinStr) unless i == last

    collector

  aggregate: (name, o, collector) ->
    collector.append "#{name}("

    collector.append 'DISTINCT ' if o.distinct
    @injectJoin o.expressions, collector, ", "

    if o.alias
      collector.append " AS "
      @visit o.alias, collector

    collector.append ")"

  # TODO: Review and Remove?

  visitRelNodesTableStar: (o, collector) ->
    rel = o.expr
    joinName = rel.tableAlias || rel.name
    "#{@quoteTableName(joinName)}.*"

  visitRelNodesConstLit: (o, collector) ->
    @visit o.expr, collector

  visitRelNodesLike: (o, collector) ->
    @visit o.left, collector
    collector.append " LIKE "
    @visit o.right, collector

  visitRelNodesILike: (o, collector) ->
    @visit o.left, collector
    collector.append " ILIKE "
    @visit o.right, collector

  _visitOuterJoin: (o, collector, joinType) ->
    collector.append "#{joinType} OUTER JOIN "
    @visit o.left, collector
    collector.append " "
    @visit o.right, collector

  visitRelNodesFunctionNode: (o, collector) ->
    @visit o.alias, collector
    collector.append "("
    @visit(x, collector) for x in o.expressions
    collector.append ")"

  visitRelNodesCase: (o, collector) ->
    collector.append "CASE"

    if o._base != undefined
      collector.append " "
      @visit o._base, collector

    for [cond, res] in o._cases
      collector.append " WHEN "
      @visit cond, collector
      collector.append " THEN "
      @visit res, collector

    if o._else != undefined
      collector.append " ELSE "
      @visit o._else, collector

    collector.append " END"

  visitRelNodesNull: (o, collector) ->
    collector.append 'NULL'

  visitRelNodesIsNull: (o, collector) ->
    @visit o.expr, collector
    collector.append " IS NULL"

  visitRelNodesNotNull: (o, collector) ->
    @visit o.expr, collector
    collector.append " IS NOT NULL"

exports = module.exports = ToSql
