assert = require('chai').assert

Rel =
  Nodes: require '../../lib/nodes'
  Table: require '../../lib/table'
  SelectManager: require '../../lib/select-manager'
  Visitors:
    ToSql: require '../../lib/visitors/to-sql'
  Collectors: require '../../lib/collectors'

describe.skip 'Rel.Collectors.SQLString', ->
  beforeEach ->
    @visitor = new Rel.Visitors.ToSql
    @collector = new Rel.Collectors.SQLString

    @collect = (node) =>
      @visitor.accept(node, @collector)

    @compile = (node) =>
      @collect(node).value

    @astWithBinds = (bv) ->
      table = new Rel.Table('users')
      manager = new Rel.SelectManager(table)
      manager.where(table.column('age').eq(bv))
      manager.where(table.column('name').eq(bv))
      manager.ast

  it 'should compile', ->
    bv = new Rel.Nodes.BindParam()
    @collect(@astWithBinds(bv))

    sql = @collector.compile(["hello", "world"])
    assert.equal sql, 'SELECT FROM "users" WHERE "users"."age" = ? AND "users"."name" = ?'
