assert = require('chai').assert

FakeEngine = require './support/fake-engine'

Rel = require '../src/rel'

describe 'Integrating rel', ->
  beforeEach ->
    @engine = new FakeEngine

  it 'should perform a users find', ->
    users = new Rel.Table 'users', @engine
    assert.equal users.where(users.column('name').eq('amy')).toSql(), 'SELECT FROM "users" WHERE "users"."name" = \'amy\''

  it 'should run through the first example on the readme', ->
    users = new Rel.Table 'users', @engine
    assert.equal users.project(Rel.star()).toSql(), 'SELECT * FROM "users"'

  it 'testing the or example', ->
    users = new Rel.Table 'users', @engine
    users.where(users.column('name').eq('bob').or(users.column('age').lt(25)))
