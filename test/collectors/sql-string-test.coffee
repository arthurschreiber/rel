assert = require('chai').assert

Rel =
  Nodes: require '../../lib/nodes'
  Table: require '../../lib/table'
  SelectManager: require '../../lib/select-manager'
  Visitors:
    ToSql: require '../../lib/visitors/to-sql'

describe.skip 'Rel.Collectors.SQLString', ->
  beforeEach ->
    @visitor = new Rel.Visitors.ToSql

    @collect = (node) ->
      @visitor.accept(node, new Rel.Collectors.SQLString)

    @compile = (node) ->
      @collect(node).value

    @astWithBinds = (bv) ->
      table = new Rel.Table('users')
      manager = new Rel.SelectManager(table)
      manager.where(table.column('age').eq(bv))
      manager.where(table.column('name').eq(bv))
      manager.ast

  it 'should compile', ->
    bv = new Rel.Nodes.BindParam('?')
    collector = @collect(@ast_with_binds(bv))

    sql = collector.compile(["hello", "world"])
    assert.equal sql, 'SELECT FROM "users" WHERE "users"."age" = ? AND "users"."name" = ?'
