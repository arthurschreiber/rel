assert = require('chai').assert

FakeEngine = require './support/fake-engine'

SelectManager = require '../lib/select-manager'
InsertManager = require '../lib/insert-manager'
Table = require '../lib/table'
SqlLiteral = require('../lib/nodes/sql-literal')
Rel = require('../lib/rel')
Nodes = require '../lib/nodes'

describe 'Inserting stuff', ->
  beforeEach ->
    @engine = new FakeEngine

  describe 'An insert manager', ->
    it 'can create a Values node', ->
      table = new Table 'users'
      manager = new InsertManager()
      values = manager.createValues ['a', 'b'], ['c', 'd']

      assert.equal values.left.length, ['a', 'b'].length
      assert.equal values.right.length, ['c', 'd'].length

    it 'allows sql literals', ->
      manager = new InsertManager()
      manager.into new Table 'users'
      manager.values(manager.createValues [Rel.star()], ['a'])
      assert.equal manager.toSql(@engine), 'INSERT INTO "users" VALUES (*)'

    it 'inserts false', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('bool'), false]]
      assert.equal manager.toSql(@engine), 'INSERT INTO "users" ("bool") VALUES (\'f\')'

    it 'inserts null', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('id'), null]]
      assert.equal manager.toSql(@engine), 'INSERT INTO "users" ("id") VALUES (NULL)'

    it 'inserts time', ->
      table = new Table 'users'
      manager = new InsertManager()

      time = new Date('2014-11-11 18:13:06')
      attribute = table.column('created_at')

      manager.insert [[attribute, time]]
      assert.equal manager.toSql(@engine), "INSERT INTO \"users\" (\"created_at\") VALUES (\'2014-11-11 17:13:06\')"

    it 'takes a list of lists', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.into table
      manager.insert [[table.column('id'), 1], [table.column('name'), 'carl']]
      assert.equal manager.toSql(@engine), 'INSERT INTO "users" ("id", "name") VALUES (1, \'carl\')'

    it 'defaults the table', ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('id'), 1], [table.column('name'), 'carl']]
      assert.equal manager.toSql(@engine), 'INSERT INTO "users" ("id", "name") VALUES (1, \'carl\')'

    it 'it takes an empty list', ->
      manager = new InsertManager()
      manager.insert []
      assert.strictEqual manager.ast.values, null

    describe 'into', ->
      it 'converts to sql', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table
        assert.equal manager.toSql(@engine), 'INSERT INTO "users"'

    describe 'columns', ->
      it 'converts to sql', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table
        manager.columns().push table.column('id')
        assert.equal manager.toSql(@engine), 'INSERT INTO "users" ("id")'

    describe 'values', ->
      it 'converts to sql', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table

        manager.values(new Nodes.Values([1]))
        assert.equal manager.toSql(@engine), 'INSERT INTO "users" VALUES (1)'

    describe 'combo', ->
      it 'puts shit together', ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table

        manager.values(new Nodes.Values([1, 'carl']))
        manager.columns().push table.column('id')
        manager.columns().push table.column('name')

        assert.equal manager.toSql(@engine), 'INSERT INTO "users" ("id", "name") VALUES (1, \'carl\')'
