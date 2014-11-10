assert = require('chai').assert

Table = require '../src/table'
DeleteManager = require '../src/delete-manager'
SqlLiteral = require('../src/nodes/sql-literal')
Nodes = require '../src/nodes'

describe 'DeleteManager', ->
  describe 'from', ->
    it 'uses from', ->
      table = new Table 'users'
      dm = new DeleteManager()
      dm.from table
      assert.equal dm.toSql(), 'DELETE FROM "users"'

    it 'chains', ->
      table = new Table 'users'
      dm = new DeleteManager()
      assert.strictEqual dm.from(table), dm

  describe 'where', ->
    it 'uses where values', ->
      table = new Table 'users'
      dm = new DeleteManager()
      dm.from table
      dm.where table.column('id').eq(10)
      assert.equal dm.toSql(), 'DELETE FROM "users" WHERE "users"."id" = 10'

    it 'chains', ->
      table = new Table 'users'
      dm = new DeleteManager()
      assert.strictEqual dm.where(table.column('id').eq(10)), dm
