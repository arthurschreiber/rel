assert = require('chai').assert

Rel =
  Nodes: require '../../src/nodes'
  Table: require '../../src/table'
  SelectManager: require '../../src/select-manager'
  Visitors:
    ToSql: require '../../src/visitors/to-sql'

describe.skip 'Rel.Collectors.Bind', ->
  beforeEach ->
    @visitor = new Rel.Visitors.ToSql

    @collect = (node) ->
      @visitor.accept(node, new Rel.Collectors.Bind)

    @compile = (node) ->
      @collect(node).value

    @astWithBinds = (bv) ->
      table = new Rel.Table('users')
      manager = new Rel.SelectManager(table)
      manager.where(table.column('age').eq(bv))
      manager.where(table.column('name').eq(bv))
      manager.ast

  it 'leaves binds', ->
    node = new Rel.Nodes.BindParam('?')
    list = @compile(node)
    assert.strictEqual node, list[0]

  it 'adds strings', ->
    node = new Rel.Nodes.BindParam('?')
    list = @compile(@ast_with_binds(bv))
    assert.isTrue(list.length > 0)

  it 'substitutes binds', ->
    # bv = Nodes::BindParam.new('?')
    # collector = collect ast_with_binds bv
    # 
    # values = collector.value
    # 
    # offsets = values.map.with_index { |v,i|
    #   [v,i]
    # }.find_all { |(v,_)| Nodes::BindParam === v }.map(&:last)
    # 
    # list = collector.substitute_binds ["hello", "world"]
    # assert_equal "hello", list[offsets[0]]
    # assert_equal "world", list[offsets[1]]
    # 
    # assert_equal 'SELECT FROM "users" WHERE "users"."age" = hello AND "users"."name" = world', list.join

  it 'compiles', ->
    bv = new Rel.Nodes.BindParam('?')
    collector = @collect(@ast_with_binds(bv))

    sql = collector.compile ["hello", "world"]
    assert.equal sql, 'SELECT FROM "users" WHERE "users"."age" = hello AND "users"."name" = world'
