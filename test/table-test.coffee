assert = require('chai').assert

Table = require '../lib/table'
SelectManager = require '../lib/select-manager'
InsertManager = require '../lib/insert-manager'
TreeManager = require '../lib/tree-manager'
SqlLiteral = require('../lib/nodes/sql-literal')
Nodes = require '../lib/nodes/nodes'

describe 'Table', ->
  beforeEach ->
    @relation = new Table('users')

  it 'should create string join nodes', ->
    join = @relation.createStringJoin('foo')
    assert.instanceOf join, Nodes.StringJoin
    assert.equal join.left, 'foo'

  it 'should create join nodes', ->
    join = @relation.createJoin 'foo', 'bar'
    assert.instanceOf join, Nodes.InnerJoin
    assert.equal join.left, 'foo'
    assert.equal join.right, 'bar'

  it 'should create join nodes with a class (FullOuterJoin)', ->
    join = @relation.createJoin 'foo', 'bar', Nodes.FullOuterJoin
    assert.instanceOf join, Nodes.FullOuterJoin
    assert.equal join.left, 'foo'
    assert.equal join.right, 'bar'

  it.skip 'should create join nodes with a class (OuterJoin)', ->
    join = @relation.createJoin 'foo', 'bar', Nodes.OuterJoin
    assert.instanceOf join, Nodes.OuterJoin
    assert.equal join.left, 'foo'
    assert.equal join.right, 'bar'

  it 'should create join nodes with a class (RightOuterJoin)', ->
    join = @relation.createJoin 'foo', 'bar', Nodes.RightOuterJoin
    assert.instanceOf join, Nodes.RightOuterJoin
    assert.equal join.left, 'foo'
    assert.equal join.right, 'bar'

  it 'should return an insert manager', ->
    im = @relation.compileInsert 'VALUES(NULL)'
    assert.instanceOf im, InsertManager
    im.into new Table('users')
    assert.equal im.toSql(), 'INSERT INTO "users" VALUES(NULL)'

  it 'should return IM from insertManager', ->
    im = @relation.insertManager()
    assert.instanceOf im, InsertManager

  describe 'skip', ->
    it 'should add an offset', ->
      sm = @relation.skip 2
      assert.equal sm.toSql(), 'SELECT FROM "users" OFFSET 2'

  describe 'selectManager', ->
    it 'should return an empty select manager', ->
      sm = @relation.selectManager()
      assert.instanceOf sm, SelectManager
      assert.equal sm.toSql(), 'SELECT'

  describe.skip 'updateManager', ->
    it 'should return an update manager', ->
      um = @relation.updateManager()
      assert.instanceOf um, UpdateManager
      assert.equal um.toSql(), 'SELECT'

  describe.skip 'deleteManager', ->
    it 'should return an update manager', ->
      dm = @relation.deleteManager()
      assert.instanceOf dm, DeleteManager
      assert.equal dm.toSql(), 'SELECT'

  describe 'having', ->
    it 'adds a having clause', ->
      mgr = @relation.having @relation.column('id').eq(10)
      assert.equal mgr.toSql(), 'SELECT FROM "users" HAVING "users"."id" = 10'

  describe 'backwards compat', ->
    # TODO?

  describe 'group', ->
    it 'should create a group', ->
      mgr = @relation.group @relation.column('id')
      assert.equal mgr.toSql(), 'SELECT FROM "users" GROUP BY "users"."id"'

  describe 'alias', ->
    it 'should create a node that proxies a table', ->
      assert.deepEqual @relation.aliases, []

      node = @relation.alias()
      assert.deepEqual @relation.aliases, [node]
      assert.equal node.name, 'users_2'
      assert.strictEqual node.column('id').relation, node

  describe 'new', ->
    it 'should accept a hash', ->
      rel = new Table 'users', as: 'foo'
      assert.equal rel.tableAlias, 'foo'

    it.skip 'ignores as if it equals name', ->
      rel = new Table 'users', as: 'users'
      assert.isNull rel.tableAlias


  describe 'order', ->
    it 'should take an order', ->
      mgr = @relation.order 'foo'
      assert.equal mgr.toSql(), 'SELECT FROM "users" ORDER BY foo'

  describe 'take', ->
    it 'should add a limit', ->
      mgr = @relation.take 1
      mgr.project new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT * FROM "users" LIMIT 1'

  describe 'project', ->
    it 'can project', ->
      mgr = @relation.project new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT * FROM "users"'

    it 'takes multiple parameters', ->
      mgr = @relation.project new SqlLiteral('*'), new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT *, * FROM "users"'

  describe 'where', ->
    it 'returns a tree manager', ->
      mgr = @relation.where @relation.column('id').eq(1)
      mgr.project @relation.column('id')
      assert.instanceOf mgr, TreeManager
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1'

  it 'should have a name', ->
    assert.equal @relation.name, 'users'

  it.skip 'should have a table name', ->
    assert.equal @relation.tableName, 'users'

  describe 'column', ->
    it "manufactures an attribute if the string names an attribute within the relation", ->
      column = @relation.column 'id'
      assert.equal column.name, 'id'

  describe.skip 'equality', ->
    it 'is equal with equal ivars', ->
      relation1 = new Table('users', 'vroom')
      relation1.aliases     = ['a', 'b', 'c']      
      relation1.tableAlias  = 'zomg'

      relation2 = new Table('users', 'vroom')
      relation2.aliases     = ['a', 'b', 'c']
      relation2.tableAlias  = 'zomg'

      assert.isTrue relation1.equals(relation2)
      assert.isTrue relation2.equals(relation1)

    it 'is not equal with different ivars', ->
      relation1 = new Table('users', 'vroom')
      relation1.aliases     = ['a', 'b', 'c']
      relation1.tableAlias  = 'zomg'

      relation2 = new Table('users', 'vroom')
      relation2.aliases     = ['x', 'y', 'z']
      relation2.tableAlias  = 'zomg'

      assert.isFalse relation1.equals(relation2)
      assert.isFalse relation2.equals(relation1)
