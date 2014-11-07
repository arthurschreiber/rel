assert = require('chai').assert

UpdateManager = require '../lib/update-manager'
Table = require '../lib/table'
SqlLiteral = require('../lib/nodes/sql-literal')
Rel = require('../rel')
Nodes = require '../lib/nodes/nodes'

describe 'Updating stuff', ->
  describe 'An update manager', ->

    # TODO not sure how this would work, can't find limit in to_sql in ruby.
    # it 'handles limit properly' ->
    #   table = new Table 'users'
    #   um = new UpdateManager()
    #   um.take 10
    #   um.table table
    #   um.set [[table.column('name'), null]]
    #   assert.equal um.toSql(), 'UPDATE "users" SET "name" = NULL LIMIT 10'

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
        assert.equal um.set([[table.column('id'), 1], [table.column('name'), 'hello']]).constructor, UpdateManager

    describe 'table', ->
      it 'generates an update statement', ->
        um = new UpdateManager()
        um.table(new Table('users'))
        assert.equal um.toSql(), 'UPDATE "users"'

      it 'chains', ->
        um = new UpdateManager()
        assert.equal um.table(new Table('users')).constructor, UpdateManager

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
        assert.equal um.where(table.column('id').eq(1)).constructor, UpdateManager
