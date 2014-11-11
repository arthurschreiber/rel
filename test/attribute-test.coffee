assert = require('chai').assert

FakeEngine = require './support/fake-engine'

Rel = require '../src/rel'
{ Table, Nodes } = Rel

describe 'Attribute', ->
  beforeEach ->
    @engine = new FakeEngine

  describe '#notEq', ->
    it 'should create a NotEqual node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').notEq(10), Nodes.NotEqual

    it 'should generate != in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').notEq(10)
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" != 10'

    it 'should handle null', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').notEq(null)
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" IS NOT NULL'

  describe '#notEqAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').notEqAny([1, 2]), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').notEqAny([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" != 1 OR "users"."id" != 2)'

  describe '#notEqAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').notEqAll([1, 2]), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').notEqAll([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" != 1 AND "users"."id" != 2)'

  describe '#gt', ->
    it 'should create a GreaterThan node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').gt(10), Nodes.GreaterThan

    it 'should generate > in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').gt(10)
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" > 10'

    it 'should handle comparing with a subquery', ->
      users = new Table('users', @engine)

      avg = users.project users.column('karma').average()
      mgr = users.project(new Nodes.SqlLiteral('*')).where(users.column('karma').gt(avg))
      
      assert.equal mgr.toSql(), 'SELECT * FROM "users" WHERE "users"."karma" > (SELECT AVG("users"."karma") FROM "users")'

    it 'should accept various data types', ->

  describe '#gtAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').gtAny([1, 2]), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').gtAny([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" > 1 OR "users"."id" > 2)'

  describe '#gtAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').gtAll([1, 2]), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').gtAll([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" > 1 AND "users"."id" > 2)'


  describe '#average', ->
    it 'should create a Avg node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').average(), Nodes.Avg

    it 'should generate proper sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id').average())
      assert.equal mgr.toSql(), 'SELECT AVG("users"."id") FROM "users"'

  describe '#maximum', ->
    it 'should create a Max node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').maximum(), Nodes.Max

    it 'should generate proper sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id').maximum())
      assert.equal mgr.toSql(), 'SELECT MAX("users"."id") FROM "users"'

  describe '#minimum', ->
    it 'should create a Min node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').minimum(), Nodes.Min

    it 'should generate proper sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id').minimum())
      assert.equal mgr.toSql(), 'SELECT MIN("users"."id") FROM "users"'

  describe '#sum', ->
    it 'should create a Sum node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').sum(), Nodes.Sum

    it 'should generate proper sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id').sum())
      assert.equal mgr.toSql(), 'SELECT SUM("users"."id") FROM "users"'

  describe '#count', ->
    it 'should create a Count node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').count(), Nodes.Count

    it 'should generate proper sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id').count())
      assert.equal mgr.toSql(), 'SELECT COUNT("users"."id") FROM "users"'

  describe '#eq', ->
    it 'should create a Equality node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').eq(10), Nodes.Equality

    it 'should generate = in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').eq(10)
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 10'

    it 'should handle null', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').eq(null)
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" IS NULL'

  describe '#eqAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').eqAny([1, 2]), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').eqAny([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" = 1 OR "users"."id" = 2)'

  describe '#eqAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').eqAll([1, 2]), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').eqAll([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" = 1 AND "users"."id" = 2)'

  describe '#matches', ->
    it 'should create a Matches node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('name').matches('%bacon'), Nodes.Matches

    it 'should generate LIKE in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('name').matches('%bacon%')
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."name" LIKE \'%bacon%\''

  describe '#matchesAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').matchesAny(['%chunky%', '%bacon%']), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('name').matchesAny(['%chunky%', '%bacon%'])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."name" LIKE \'%chunky%\' OR "users"."name" LIKE \'%bacon%\')'

  describe '#matchesAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').matchesAll(['%chunky%', '%bacon%']), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('name').matchesAll(['%chunky%', '%bacon%'])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."name" LIKE \'%chunky%\' AND "users"."name" LIKE \'%bacon%\')'

  describe '#doesNotMatch', ->
    it 'should create a DoesNotMatch node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('name').doesNotMatch('%bacon'), Nodes.DoesNotMatch

    it 'should generate LIKE in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('name').doesNotMatch('%bacon%')
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."name" NOT LIKE \'%bacon%\''

  describe '#doesNotMatchAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').doesNotMatchAny(['%chunky%', '%bacon%']), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('name').doesNotMatchAny(['%chunky%', '%bacon%'])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."name" NOT LIKE \'%chunky%\' OR "users"."name" NOT LIKE \'%bacon%\')'

  describe '#doesNotMatchAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').doesNotMatchAll(['%chunky%', '%bacon%']), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('name').doesNotMatchAll(['%chunky%', '%bacon%'])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."name" NOT LIKE \'%chunky%\' AND "users"."name" NOT LIKE \'%bacon%\')'

  describe.skip '#between', ->
    # TODO

  describe '#in', ->
    it.skip 'can be constructed with a subquery', ->
      # TODO

    it.skip 'can be constructed with a list', ->
      # TODO

    it.skip 'can be constructed with a random object', ->
      # TODO

    it 'should generate IN sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id'))
      mgr.where(relation.column('id').in([1, 2, 3]))
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" IN (1, 2, 3)'

  describe '#inAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').inAny([[1,2], [3,4]]), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').inAny([[1,2], [3,4]])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" IN (1, 2) OR "users"."id" IN (3, 4))'

  describe '#inAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').inAll([[1,2], [3,4]]), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').inAll([[1,2], [3,4]])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" IN (1, 2) AND "users"."id" IN (3, 4))'

  describe.skip '#notBetween', ->
    # TODO

  describe '#notIn', ->
    it.skip 'can be constructed with a subquery', ->
      # TODO

    it.skip 'can be constructed with a list', ->
      # TODO

    it.skip 'can be constructed with a random object', ->
      # TODO

    it 'should generate IN sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project(relation.column('id'))
      mgr.where(relation.column('id').notIn([1, 2, 3]))
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" NOT IN (1, 2, 3)'

  describe '#notInAny', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').notInAny([[1,2], [3,4]]), Nodes.Grouping

    it 'should generate ORs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').notInAny([[1,2], [3,4]])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" NOT IN (1, 2) OR "users"."id" NOT IN (3, 4))'

  describe '#notInAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').notInAll([[1,2], [3,4]]), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').notInAll([[1,2], [3,4]])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" NOT IN (1, 2) AND "users"."id" NOT IN (3, 4))'

  describe '#eqAll', ->
    it 'should create a Grouping node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').eqAll([1, 2]), Nodes.Grouping

    it 'should generate ANDs in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.where relation.column('id').eqAll([1, 2])
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE ("users"."id" = 1 AND "users"."id" = 2)'

  describe '#asc', ->
    it 'should create a Ascending node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').asc(), Nodes.Ascending

    it 'should generate ASC in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.order relation.column('id').asc()
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" ORDER BY "users"."id" ASC'

  describe '#desc', ->
    it 'should create a Descending node', ->
      relation = new Table('users', @engine)
      assert.instanceOf relation.column('id').desc(), Nodes.Descending

    it 'should generate DESC in sql', ->
      relation = new Table('users', @engine)
      mgr = relation.project relation.column('id')
      mgr.order relation.column('id').desc()
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" ORDER BY "users"."id" DESC'
