assert = require('chai').assert

Rel = require '../../src/rel'

describe 'Rel.Visitors.ToSql', ->
  beforeEach ->
    @visitor = new Rel.Visitors.ToSql
    @table = new Rel.Table('users')
    @attr = @table.column('id')

    @compile = (node) ->
      @visitor.accept(node)

  it 'works with BindParams', ->
    node = new Rel.Nodes.BindParam('?')
    sql = @compile(node)
    assert.equal(sql, '?')

  it 'should not quote sql literals', ->
    node = @table.star()
    sql = @compile(node)
    assert.equal(sql, '"users".*')

  it 'should visit named functions', ->
    func = new Rel.Nodes.NamedFunction('omg', [Rel.star()])
    assert.equal(@compile(func), 'omg(*)')

  it 'should chain predications on named functions', ->
    func = new Rel.Nodes.NamedFunction('omg', [Rel.star()])
    sql = @compile(func.eq(2))
    assert.equal sql, 'omg(*) = 2'

  it 'should visit built-in funcs', ->
    func = new Rel.Nodes.Count([Rel.star()])
    assert.equal 'COUNT(*)', @compile(func)

    func = new Rel.Nodes.Sum([Rel.star()])
    assert.equal 'SUM(*)', @compile(func)

    func = new Rel.Nodes.Max([Rel.star()])
    assert.equal 'MAX(*)', @compile(func)

    func = new Rel.Nodes.Min([Rel.star()])
    assert.equal 'MIN(*)', @compile(func)

    func = new Rel.Nodes.Avg([Rel.star()])
    assert.equal 'AVG(*)', @compile(func)

  it 'should visit built-in funcs operating on distinct values', ->
    func = new Rel.Nodes.Count([Rel.star()])
    func.distinct = true
    assert.equal 'COUNT(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Sum([Rel.star()])
    func.distinct = true
    assert.equal 'SUM(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Max([Rel.star()])
    func.distinct = true
    assert.equal 'MAX(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Min([Rel.star()])
    func.distinct = true
    assert.equal 'MIN(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Avg([Rel.star()])
    func.distinct = true
    assert.equal 'AVG(DISTINCT *)', @compile(func)
