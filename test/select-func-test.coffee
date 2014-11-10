Rel = require '../src/rel'
assert = require('chai').assert

describe 'A sum function', ->
  beforeEach ->
    @sum = Rel.func('sum')

  it 'works', ->
    user = new Rel.Table 'user'
    q = user.where(@sum(@sum(user.column('age')).eq(1)))
    assert.equal q.toSql(), 'SELECT FROM "user" WHERE sum(sum("user"."age") = 1)'
