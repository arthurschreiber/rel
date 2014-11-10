assert = require('chai').assert

SelectManager = require '../src/select-manager'
InsertManager = require '../src/insert-manager'
Table = require '../src/table'
SqlLiteral = require('../src/nodes/sql-literal')
Rel = require('../src/rel')
Nodes = require '../src/nodes'

describe 'Inserting stuff', ->
  describe 'An insert manager', ->
    it 'can create a Values node', ->
      table = new Table 'users'
      manager = new InsertManager()
      values = manager.createValues ['a', 'b'], ['c', 'd']

      assert.equal values.left.length, ['a', 'b'].length
      assert.equal values.right.length, ['c', 'd'].length

    it 'allows sql literals', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.values(manager.createValues [Rel.star()], ['a'])
      assert.equal manager.toSql(), 'INSERT INTO NULL VALUES (*)'

    it 'inserts false', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('bool'), false]]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("bool") VALUES (false)'

    it 'inserts null', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('id'), null]]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("id") VALUES (NULL)'

    it 'inserts time', ->
      table = new Table 'users'
      manager = new InsertManager()

      time = new Date()
      attribute = table.column('created_at')

      manager.insert [[attribute, time]]
      assert.equal manager.toSql(), "INSERT INTO \"users\" (\"created_at\") VALUES ('#{time.toISOString()}')"

    it 'takes a list of lists', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.into table
      manager.insert [[table.column('id'), 1], [table.column('name'), 'carl']]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("id", "name") VALUES (1, \'carl\')'

    it 'defaults the table', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('id'), 1], [table.column('name'), 'carl']]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("id", "name") VALUES (1, \'carl\')'

    it 'it takes an empty list', ->
      manager = new InsertManager()
      manager.insert []
      assert.strictEqual manager.ast.values, null

    describe 'into', ->
      it 'converts to sql', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table
        assert.equal manager.toSql(), 'INSERT INTO "users"'

    describe 'columns', ->
      it 'converts to sql', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table
        manager.columns().push table.column('id')
        assert.equal manager.toSql(), 'INSERT INTO "users" ("id")'

    describe 'values', ->
      it 'converts to sql', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table

        manager.values(new Nodes.Values([1]))
        assert.equal manager.toSql(), 'INSERT INTO "users" VALUES (1)'

    describe 'combo', ->
      it 'puts shit together', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table

        manager.values(new Nodes.Values([1, 'carl']))
        manager.columns().push table.column('id')
        manager.columns().push table.column('name')

        assert.equal manager.toSql(), 'INSERT INTO "users" ("id", "name") VALUES (1, \'carl\')'
