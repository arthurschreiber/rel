assert = require('chai').assert

Rel =
  Nodes: require '../../lib/nodes/nodes'
  Table: require '../../lib/table'
  Visitors:
    ToSql: require '../../lib/visitors/to-sql'

describe 'Rel.Visitors.ToSql', ->
  beforeEach ->
    @visitor = new Rel.Visitors.ToSql
    @table = new Rel.Table('users')
    @attr = @table.column('id')

    @compile = (node) ->
      @visitor.accept(node)

  it.skip 'works with BindParams', ->
    node = Rel.Nodes.BindParams('?')
    sql = @compile(node)
    assert.equal(sql, '?')

  it 'should not quote sql literals', ->
    node = @table.star()
    sql = @compile(node)
    assert.equal(sql, '"users".*')

  it.skip 'should visit named functions', ->
    func = new Rel.Nodes.NamedFunction('omg', @table.star())
    assert.equal(@compile(func), 'omg(*)')

  it 'should chain predications on named functions', ->
    func = new Rel.Nodes.NamedFunction('omg', [@table.star()])
    sql = @compile(func.eq(2))
    assert.equal sql, 'omg(*) = 2'

  it 'should visit built-in funcs', ->
    func = new Rel.Nodes.Count([@table.star()])
    assert.equal 'COUNT(*)', @compile(func)

    func = new Rel.Nodes.Sum([@table.star()])
    assert.equal 'SUM(*)', @compile(func)

    func = new Rel.Nodes.Max([@table.star()])
    assert.equal 'MAX(*)', @compile(func)

    func = new Rel.Nodes.Min([@table.star()])
    assert.equal 'MIN(*)', @compile(func)

    func = new Rel.Nodes.Avg([@table.star()])
    assert.equal 'AVG(*)', @compile(func)

  it 'should visit built-in funcs operating on distinct values', ->
    func = new Rel.Nodes.Count([@table.star()])
    func.distinct = true
    assert.equal 'COUNT(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Sum([@table.star()])
    func.distinct = true
    assert.equal 'SUM(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Max([@table.star()])
    func.distinct = true
    assert.equal 'MAX(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Min([@table.star()])
    func.distinct = true
    assert.equal 'MIN(DISTINCT *)', @compile(func)

    func = new Rel.Nodes.Avg([@table.star()])
    func.distinct = true
    assert.equal 'AVG(DISTINCT *)', @compile(func)
