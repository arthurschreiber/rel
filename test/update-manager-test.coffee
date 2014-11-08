assert = require('chai').assert

UpdateManager = require '../lib/update-manager'
Table = require '../lib/table'
SqlLiteral = require('../lib/nodes/sql-literal')
Rel = require('../rel')
Nodes = require '../lib/nodes/nodes'

describe 'UpdateManager', ->
  it.skip 'should not quote sql literals', ->
    table = new Table('users')
    um = new UpdateManager
    um.table table
    um.set [[table.column('name'), new Nodes.BindParam('?')]]
    assert.equal um.toSql(), 'UPDATE "users" SET "name" = ?'

  it.skip 'handles limit properly', ->
    table = new Table 'users'
    um = new UpdateManager()
    um.take 10
    um.table table
    um.set [[table.column('name'), null]]
    assert.equal um.toSql(), 'UPDATE "users" SET "name" = NULL LIMIT 10'

  describe 'set', ->
    it 'updates with null', ->
      table = new Table 'users'
      um = new UpdateManager()
      um.table table
      um.set [[table.column('name'), null]]
      assert.equal um.toSql(), 'UPDATE "users" SET "name" = NULL'

    it 'takes a string', ->
      table = new Table 'users'
      um = new UpdateManager()
      um.table table
      um.set new Nodes.SqlLiteral("foo = bar")
      assert.equal um.toSql(), 'UPDATE "users" SET foo = bar'

    it 'takes a list of lists', ->
      table = new Table 'users'
      um = new UpdateManager()
      um.table table
      um.set [[table.column('id'), 1], [table.column('name'), 'hello']]
      assert.equal um.toSql(), 'UPDATE "users" SET "id" = 1, "name" = \'hello\''

    it 'chains', ->
      table = new Table 'users'
      um = new UpdateManager()
      assert.strictEqual um.set([[table.column('id'), 1], [table.column('name'), 'hello']]), um

  describe 'table', ->
    it 'generates an update statement', ->
      um = new UpdateManager()
      um.table(new Table('users'))
      assert.equal um.toSql(), 'UPDATE "users"'

    it 'chains', ->
      um = new UpdateManager()
      assert.strictEqual um.table(new Table('users')), um

    it.skip 'generates an update statement with joins', ->
      um = new UpdateManager

      table = new Table('users')
      joinSource = new Nodes.JoinSource(
        table,
        [table.createJoin(new Table('posts'))]
      )

      um.table joinSource
      assert.equal um.toSql(), 'UPDATE "users" INNER JOIN "posts"'

  describe 'where', ->
    it 'generates a where clause', ->
      table = new Table 'users'
      um = new UpdateManager()
      um.table table
      um.where table.column('id').eq(1)
      assert.equal um.toSql(), 'UPDATE "users" WHERE "users"."id" = 1'

    it 'chains', ->
      table = new Table 'users'
      um = new UpdateManager()
      um.table table
      assert.strictEqual um.where(table.column('id').eq(1)), um
