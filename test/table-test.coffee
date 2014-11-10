assert = require('chai').assert

Table = require '../src/table'
SelectManager = require '../src/select-manager'
InsertManager = require '../src/insert-manager'
SqlLiteral = require('../src/nodes/sql-literal')
Nodes = require '../src/nodes/nodes'

describe 'Table stuff', ->
  describe 'A table', ->
    beforeEach ->
      @table = new Table('users')

    it 'has a from method', ->
      assert.isNotNull @table.from('user')

    it 'can project things', ->
      assert.isNotNull @table.project(new require('../src/nodes/sql-literal')('*'))

    it 'should return sql', ->
      assert.equal @table.project(new SqlLiteral('*')).toSql(), "SELECT * FROM \"users\""

    it 'should create string join nodes', ->
      join = @table.createStringJoin('foo')
      assert.equal join.constructor, Nodes.StringJoin

    it 'should create join nodes', ->
      join = @table.createJoin 'foo', 'bar'
      assert.equal join.constructor, Nodes.InnerJoin
      assert.equal join.left, 'foo'
      assert.equal join.right, 'bar'

    it 'should create join nodes with a class', ->
      join = @table.createJoin 'foo', 'bar', Nodes.LeftOuterJoin
      assert.equal join.constructor, Nodes.LeftOuterJoin
      assert.equal join.left, 'foo'
      assert.equal join.right, 'bar'

    it 'should return an insert manager', ->
      im = @table.compileInsert 'VALUES(NULL)'
      assert.equal InsertManager, im.constructor
      assert.equal im.toSql(), 'INSERT INTO NULL VALUES(NULL)'

    it 'should return IM from insertManager', ->
      im = @table.insertManager()
      assert.equal InsertManager, im.constructor

    it 'skip: should add an offset', ->
      sm = @table.skip 2
      assert.equal sm.toSql(), 'SELECT FROM "users" OFFSET 2'

    it 'selectManager: should return a select manager', ->
      sm = @table.selectManager()
      assert.equal sm.toSql(), 'SELECT'

    it 'having: adds a having clause', ->
      mgr = @table.having @table.column('id').eq(10)
      assert.equal mgr.toSql(), 'SELECT FROM "users" HAVING "users"."id" = 10'

    it 'group: should create a group', ->
      mgr = @table.group @table.column('id')
      assert.equal mgr.toSql(), 'SELECT FROM "users" GROUP BY "users"."id"'

    it 'alias: should create a node that proxies a table', ->
      assert.equal @table.aliases.length, 0

      node = @table.alias()
      assert.equal @table.aliases.length, 1
      assert.equal node.name, 'users_2'
      assert.equal node.column('id').relation, node

    it 'new: takes a hash', ->
      rel = new Table 'users', as: 'users'
      assert.isNotNull rel.tableAlias

    it 'order: should take an order', ->
      mgr = @table.order 'foo'
      assert.equal mgr.toSql(), 'SELECT FROM "users" ORDER BY foo'

    it 'take: should add a limit', ->
      mgr = @table.take 1
      mgr.project new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT * FROM "users" LIMIT 1'

    it 'project: can project', ->
      mgr = @table.project new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT * FROM "users"'

    it 'project: takes multiple parameters', ->
      mgr = @table.project new SqlLiteral('*'), new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT *, * FROM "users"'

    it 'where: returns a tree manager', ->
      mgr = @table.where @table.column('id').eq(1)
      mgr.project @table.column('id')
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1'

    it 'should have a name', ->
      assert.equal @table.name, 'users'

    it 'column', ->
      column = @table.column 'id'
      assert.equal column.name, 'id'

    it 'star', ->
      assert.equal @table.project(@table.star()).toSql(),
        'SELECT "users".* FROM "users"'
