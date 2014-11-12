assert = require('chai').assert

FakeEngine = require '../support/fake-engine'

Rel = require '../../lib/rel'

describe 'Rel.Visitors.MSSQL', ->
  beforeEach ->
    @engine = new FakeEngine()
    @visitor = new Rel.Visitors.MSSQL(@engine)
    @table = new Rel.Table("users", @engine)

    @compile = (node) =>
      collector = new Rel.Collectors.SQLString
      @visitor.accept(node, collector)
      collector.value

  it 'should not modify query if no offset or limit', ->
    stmt = new Rel.Nodes.SelectStatement
    assert.equal @compile(stmt), "SELECT"

  it 'should go over table PK if no .order() or .group()', ->
    stmt = new Rel.Nodes.SelectStatement
    stmt.cores[0].from(@table)
    stmt.limit = new Rel.Nodes.Limit(10)

    assert.equal @compile(stmt), "SELECT _t.* FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) as _row_num FROM \"users\") as _t WHERE _row_num BETWEEN 1 AND 10"

  it 'should go over query ORDER BY if .order()', ->
    stmt = new Rel.Nodes.SelectStatement
    stmt.cores[0].from(@table)
    stmt.limit = new Rel.Nodes.Limit(10)
    stmt.orders.push(new Rel.Nodes.SqlLiteral('order_by'))

    assert.equal @compile(stmt), "SELECT _t.* FROM (SELECT ROW_NUMBER() OVER (ORDER BY order_by) as _row_num FROM \"users\") as _t WHERE _row_num BETWEEN 1 AND 10"

  it 'should go over query GROUP BY if no .order() and there is .group()', ->
    stmt = new Rel.Nodes.SelectStatement
    stmt.cores[0].from(@table)
    stmt.cores[0].groups.push(new Rel.Nodes.SqlLiteral('group_by'))
    stmt.limit = new Rel.Nodes.Limit(10)

    assert.equal @compile(stmt), "SELECT _t.* FROM (SELECT ROW_NUMBER() OVER (ORDER BY group_by) as _row_num FROM \"users\" GROUP BY group_by) as _t WHERE _row_num BETWEEN 1 AND 10"

  it 'should use BETWEEN if both .limit() and .offset', ->
    stmt = new Rel.Nodes.SelectStatement
    stmt.cores[0].from(@table)
    stmt.limit = new Rel.Nodes.Limit(10)
    stmt.offset = new Rel.Nodes.Offset(20)

    assert.equal @compile(stmt), "SELECT _t.* FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) as _row_num FROM \"users\") as _t WHERE _row_num BETWEEN 21 AND 30"

  it 'should use >= if only .offset', ->
    stmt = new Rel.Nodes.SelectStatement
    stmt.cores[0].from(@table)
    stmt.offset = new Rel.Nodes.Offset(20)

    assert.equal @compile(stmt), "SELECT _t.* FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) as _row_num FROM \"users\") as _t WHERE _row_num >= 21"

  it 'should generate subquery for .count', ->
    stmt = new Rel.Nodes.SelectStatement
    stmt.cores[0].from(@table)
    stmt.limit = new Rel.Nodes.Limit(10)
    stmt.cores[0].projections.push(new Rel.Nodes.Count('*'))

    assert.equal @compile(stmt), "SELECT COUNT(1) as count_id FROM (SELECT _t.* FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) as _row_num FROM \"users\") as _t WHERE _row_num BETWEEN 1 AND 10) AS subquery"
