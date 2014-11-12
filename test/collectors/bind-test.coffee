assert = require('chai').assert

FakeEngine = require '../support/fake-engine'
Rel = require '../../src/rel'

describe 'Rel.Collectors.Bind', ->
  beforeEach ->
    @engine = new FakeEngine
    @visitor = new Rel.Visitors.ToSql(@engine)

    @collect = (node) =>
      collector = new Rel.Collectors.Bind
      @visitor.accept(node, collector)
      collector

    @compile = (node) =>
      @collect(node).value

    @astWithBinds = (bv) ->
      table = new Rel.Table('users', @engine)
      manager = new Rel.SelectManager(@engine, table)
      manager.where(table.column('age').eq(bv))
      manager.where(table.column('name').eq(bv))
      manager.ast

  it 'leaves binds', ->
    bv = new Rel.Nodes.BindParam('?')
    list = @compile(bv)
    assert.strictEqual bv, list[0]

  it 'adds strings', ->
    bv = new Rel.Nodes.BindParam('?')
    list = @compile(@astWithBinds(bv))
    assert.isTrue(list.length > 0)

  it 'compiles', ->
    bv = new Rel.Nodes.BindParam('?')
    collector = @collect(@astWithBinds(bv))

    sql = collector.compile ["hello", "world"]
    assert.equal sql, 'SELECT FROM "users" WHERE "users"."age" = hello AND "users"."name" = world'
