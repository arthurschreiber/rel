assert = require('chai').assert

Table = require '../lib/table'
DeleteManager = require '../lib/delete-manager'
SqlLiteral = require('../lib/nodes/sql-literal')
Nodes = require '../lib/nodes/nodes'

describe 'Delete manager', ->
  describe 'from', ->
    it 'uses from', ->
      table = new Table 'users'
      dm = new DeleteManager()
      dm.from table
      assert.equal dm.toSql(), 'DELETE FROM "users"'

    it 'chains', ->
      table = new Table 'users'
      dm = new DeleteManager()
      assert.equal dm.from(table).constructor, DeleteManager

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
      assert.equal dm.where(table.column('id').eq(10)).constructor, DeleteManager
