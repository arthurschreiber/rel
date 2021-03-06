assert = require('chai').assert

SelectManager = require '../src/select-manager'
Table = require '../src/table'
SqlLiteral = require('../src/nodes/sql-literal')
Rel = require('../src/rel')
Nodes = require '../src/nodes/nodes'

describe 'Querying stuff', ->
  describe 'A select manager', ->
    describe 'projects', ->
      it 'accepts sql literals', ->
        selectManager = new SelectManager(new Table('users'))
        selectManager.project Rel.sql('id')
        assert.equal selectManager.toSql(), "SELECT id FROM \"users\""
      it 'accepts string constants', ->
        selectManager = new SelectManager(new Table('users'))
        selectManager.project 'foo'
        assert.equal selectManager.toSql(), "SELECT 'foo' FROM \"users\""

    describe 'order', ->
      beforeEach ->
        @selectManager = new SelectManager(new Table('users'))

      it 'accepts strings', ->
        @selectManager.project new SqlLiteral('*')
        @selectManager.order 'foo'
        assert.equal @selectManager.toSql(), "SELECT * FROM \"users\" ORDER BY foo"

    describe 'group', ->
      beforeEach ->
        @selectManager = new SelectManager(new Table('users'))

      it 'accepts strings', ->
        @selectManager.project new SqlLiteral('*')
        @selectManager.group 'foo'
        assert.equal @selectManager.toSql(), "SELECT * FROM \"users\" GROUP BY foo"

    describe 'as', ->
      beforeEach ->
        @selectManager = new SelectManager(new Table('users'))

      it 'makes an AS node by grouping the AST', ->
        as = @selectManager.as Rel.sql('foo')
        assert.equal 'Grouping', as.left.constructor.name
        assert.equal @selectManager.ast, as.left.expr
        assert.equal 'foo', as.right.toString()

      it 'converts right to SqlLiteral if string', ->
        as = @selectManager.as 'foo'
        assert.equal as.right.constructor.name, 'SqlLiteral'

      it 'renders to correct AS SQL', ->
        sub = Rel.select().project(1)
        outer = Rel.select().from(sub.as('x')).project(Rel.star())
        assert.equal outer.toSql(), 'SELECT * FROM (SELECT 1) "x"'

    describe 'As', ->
      it 'supports SqlLiteral', ->
        select = Rel.select()
          .project(new Nodes.As(1, new Nodes.SqlLiteral('x')))
        assert.equal select.toSql(), 'SELECT 1 AS x'

      it 'supports UnqualifiedName', ->
        select = Rel.select()
          .project(new Nodes.As(1, new Nodes.UnqualifiedName('x')))
        assert.equal select.toSql(), 'SELECT 1 AS "x"'

    describe 'from', ->
      it 'ignores string when table of same name exists', ->
        table = new Table('users')
        manager = new SelectManager(table)

        manager.from table
        manager.from 'users'
        manager.project table.attribute('id')
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM users'

      it 'can have multiple items together', ->
        table = new Table('users')
        manager = table.from table
        manager.having 'foo', 'bar'
        assert.equal manager.toSql(), 'SELECT FROM "users" HAVING foo AND bar'

    describe 'on', ->
      it 'converts to sql literals', ->
        table = new Table('users')
        right = table.alias()
        manager = table.from table
        manager.join(right).on('omg')
        assert.equal manager.toSql(), 'SELECT FROM "users" INNER JOIN "users" "users_2" ON omg'

      it 'converts to sql literals', ->
        table = new Table('users')
        right = table.alias()
        manager = table.from table
        manager.join(right).on('omg', "123")
        assert.equal manager.toSql(), 'SELECT FROM "users" INNER JOIN "users" "users_2" ON omg AND 123'

    # TODO Clone not implemented
    # 'clone':
    #   'creates new cores', ->
    #     table = new Table('users')
    #     table.as 'foo'
    #     mgr = table.from table
    #     m2 = mgr.clone()
    #     m2.project 'foo'
    #     assert.notEqual mgr.toSql(), m2.toSql()

    # TODO Test initialize

    describe 'skip', ->
      it 'should add an offest', ->
        table = new Table 'users'
        mgr = table.from table
        mgr.skip 10
        assert.equal mgr.toSql(), 'SELECT FROM "users" OFFSET 10'
      it 'should chain', ->
        table = new Table 'users'
        mgr = table.from table
        assert.equal mgr.skip(10).toSql(), 'SELECT FROM "users" OFFSET 10'
      it 'should handle removing a skip', ->
        table = new Table 'users'
        mgr = table.from table
        assert.equal mgr.skip(10).toSql(), 'SELECT FROM "users" OFFSET 10'
        assert.equal mgr.skip(null).toSql(), 'SELECT FROM "users"'

    describe 'exists', ->
      it 'should create an exists clause', ->
        table = new Table 'users'
        mgr = new SelectManager table
        mgr.project(new SqlLiteral('*'))
        m2 = new SelectManager
        m2.project mgr.exists()
        assert.equal m2.toSql(), "SELECT EXISTS (#{mgr.toSql()})"
      it 'can be aliased', ->
        table = new Table 'users'
        mgr = new SelectManager table
        mgr.project(new SqlLiteral('*'))
        m2 = new SelectManager()
        m2.project mgr.exists().as('foo')
        assert.equal m2.toSql(), "SELECT EXISTS (#{mgr.toSql()}) AS \"foo\""

    describe 'union', ->
      beforeEach ->
        table = new Table 'users'
        m1 = new SelectManager table
        m1.project Rel.star()
        m1.where(table.column('age').lt(18))

        m2 = new SelectManager table
        m2.project Rel.star()
        m2.where(table.column('age').gt(99))

        @topics = [m1, m2]

      it 'should union two managers', ->
        m1 = @topics[0] 
        m2 = @topics[1]
        node = m1.union m2
        assert.equal node.toSql(), 
          '(SELECT * FROM "users" WHERE "users"."age" < 18) UNION (SELECT * FROM "users" WHERE "users"."age" > 99)'

      it 'should union two managers', ->
        m1 = @topics[0] 
        m2 = @topics[1]
        node = m1.union 'all', m2
        assert.equal node.toSql(), 
          '(SELECT * FROM "users" WHERE "users"."age" < 18) UNION ALL (SELECT * FROM "users" WHERE "users"."age" > 99)'

    describe 'except', ->
      beforeEach ->
        table = new Table 'users'
        m1 = new SelectManager table
        m1.project Rel.star()
        m1.where(table.column('age').in(Rel.range(18,60)))

        m2 = new SelectManager table
        m2.project Rel.star()
        m2.where(table.column('age').in(Rel.range(40,99)))

        @topics = [m1, m2]

      it 'should except two managers', ->
        m1 = @topics[0] 
        m2 = @topics[1]
        node = m1.except m2
        assert.equal node.toSql(), 
          '(SELECT * FROM "users" WHERE "users"."age" BETWEEN (18 AND 60)) EXCEPT (SELECT * FROM "users" WHERE "users"."age" BETWEEN (40 AND 99))'

    describe 'intersect', ->
      beforeEach ->
        table = new Table 'users'
        m1 = new SelectManager table
        m1.project Rel.star()
        m1.where(table.column('age').gt(18))

        m2 = new SelectManager table
        m2.project Rel.star()
        m2.where(table.column('age').lt(99))

        @topics = [m1, m2]

      it 'should intersect two managers', ->
        m1 = @topics[0] 
        m2 = @topics[1]
        node = m1.intersect m2

        assert.equal node.toSql(),
          '(SELECT * FROM "users" WHERE "users"."age" > 18) INTERSECT (SELECT * FROM "users" WHERE "users"."age" < 99)'

    describe 'with', ->
      it 'should support WITH RECURSIVE', ->
        comments = new Table 'comments'
        commentsId = comments.column 'id'
        commentsParentId = comments.column 'parent_id'

        replies = new Table 'replies'
        repliedId = replies.column 'id'

        recursiveTerm = new SelectManager()
        recursiveTerm.from(comments).project(commentsId, commentsParentId).where(commentsId.eq(42))

        nonRecursiveTerm = new SelectManager()
        nonRecursiveTerm.from(comments).project(commentsId, commentsParentId).join(replies).on(commentsParentId.eq(repliedId))

        union = recursiveTerm.union(nonRecursiveTerm)

        asStatement = new Nodes.As replies, union

        manager = new SelectManager()
        manager.with('recursive', asStatement).from(replies).project(Rel.star())

        string = 'WITH RECURSIVE "replies" AS ((SELECT "comments"."id", "comments"."parent_id" FROM "comments" WHERE "comments"."id" = 42) UNION (SELECT "comments"."id", "comments"."parent_id" FROM "comments" INNER JOIN "replies" ON "comments"."parent_id" = "replies"."id")) SELECT * FROM "replies"'
        assert.equal manager.toSql(), string

    describe 'ast', ->
      it 'it should return the ast', ->
        table = new Table 'users'
        mgr = table.from table
        ast = mgr.ast
        assert.equal mgr.visitor.accept(ast), mgr.toSql()

    describe 'taken', ->
      it 'should return limit', ->
        manager = new SelectManager()
        manager.take(10)
        assert.equal manager.taken(), 10

    describe 'lock', ->
      it 'adds a lock', ->
        table = new Table 'users'
        mgr = table.from table
        assert.equal mgr.lock().toSql(), 'SELECT FROM "users"'

    describe 'orders', ->
      it 'returns order clauses', ->
        table = new Table 'users'
        manager = new SelectManager
        order = table.column 'id'
        manager.order table.column('id')
        assert.equal manager.orders()[0].name, order.name

    describe 'order', ->
      it 'generates order clauses', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.project Rel.star()
        manager.from table
        manager.order table.column('id')
        assert.equal manager.toSql(), 'SELECT * FROM "users" ORDER BY "users"."id"'

      it 'it takes args...', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.project Rel.star()
        manager.from table
        manager.order table.column('id'), table.column('name')
        assert.equal manager.toSql(), 'SELECT * FROM "users" ORDER BY "users"."id", "users"."name"'

      it 'chains', ->
        table = new Table 'users'
        manager = new SelectManager()
        assert.equal manager.order(table.column('id')), manager

      it 'supports asc/desc', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.project Rel.star()
        manager.from table
        manager.order table.column('id').asc(), table.column('name').desc()
        assert.equal manager.toSql(),
          'SELECT * FROM "users" ORDER BY "users"."id" ASC, "users"."name" DESC'

    describe 'on', ->
      it 'takes two params', ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right).on(predicate, predicate)
        assert.equal manager.toSql(), 
          'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id" AND "users"."id" = "users_2"."id"'

      it 'takes two params', ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right).on(predicate, predicate, left.column('name').eq(right.column('name')))
        assert.equal manager.toSql(), 
          'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id" AND "users"."id" = "users_2"."id" AND "users"."name" = "users_2"."name"'

    describe 'froms', ->
      it 'it should hand back froms', ->
        relation = new SelectManager()
        assert.equal [].length, relation.froms().length

    describe 'nodes', ->
      it 'it should create AND nodes', ->
        relation = new SelectManager()
        children = ['foo', 'bar', 'baz']
        clause = relation.createAnd children
        assert.equal clause.constructor, Nodes.And
        assert.equal clause.children, children

      it 'it should create JOIN nodes', ->
        relation = new SelectManager()
        join = relation.createJoin 'foo', 'bar'
        assert.equal join.constructor, Nodes.InnerJoin
        assert.equal 'foo', join.left
        assert.equal 'bar', join.right

      it 'it should create JOIN nodes with a class', ->
        relation = new SelectManager()
        join = relation.createJoin 'foo', 'bar', Nodes.LeftOuterJoin
        assert.equal join.constructor, Nodes.LeftOuterJoin
        assert.equal 'foo', join.left
        assert.equal 'bar', join.right

    # TODO put in insert manager, see ruby tests.

    describe 'join', ->
      it 'responds to join', ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right).on(predicate)
        assert.equal manager.toSql(), 'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"'

      it 'it takes a class', ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right, Nodes.LeftOuterJoin).on(predicate)
        assert.equal manager.toSql(), 'SELECT FROM "users" LEFT OUTER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"'

      it 'it noops on null', ->
        manager = new SelectManager()
        assert.equal manager.join(null), manager

    describe 'joins', ->
      it 'returns join sql', ->
        table = new Table 'users'
        alias = table.alias()
        manager = new SelectManager()
        manager.from(new Nodes.InnerJoin(alias, table.column('id').eq(alias.column('id'))))
        assert.equal manager.joinSql().toString(), 'INNER JOIN "users" "users_2" "users"."id" = "users_2"."id"'

      it 'returns outer join sql', ->
        table = new Table 'users'
        alias = table.alias()
        manager = new SelectManager()
        manager.from(new Nodes.LeftOuterJoin(alias, table.column('id').eq(alias.column('id'))))
        assert.equal manager.joinSql().toString(), 'LEFT OUTER JOIN "users" "users_2" "users"."id" = "users_2"."id"'

      it 'return string join sql', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from new Nodes.StringJoin('hello')
        assert.equal manager.joinSql().toString(), "'hello'" # TODO not sure if this should get quoted. It isn't in ruby tests.

      it 'returns nil join sql', ->
        manager = new SelectManager()
        assert.isNull manager.joinSql()

    describe 'order clauses', ->
      it 'returns order clauses as a list', ->
        table = new Table('users')
        manager = new SelectManager()
        manager.from table
        manager.order table.column('id')
        assert.equal manager.orderClauses()[0], '"users"."id"'

    describe 'group', ->
      it 'takes an attribute', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.group table.column('id')
        assert.equal manager.toSql(), 'SELECT FROM "users" GROUP BY "users"."id"'

      it 'chaining', ->
        table = new Table 'users'
        manager = new SelectManager()
        assert.equal manager.group(table.column('id')).constructor.name, manager.constructor.name

      it 'takes multiple args', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.group table.column('id'), table.column('name')
        assert.equal manager.toSql(), 'SELECT FROM "users" GROUP BY "users"."id", "users"."name"'

      it 'it makes strings literals', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.group 'foo'
        assert.equal manager.toSql(), 'SELECT FROM "users" GROUP BY foo'

    # TODO Implement delete

    describe 'where sql', ->
      it 'gives me back the where sql', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.where table.column('id').eq(10)
        assert.equal manager.whereSql(), 'WHERE "users"."id" = 10'
      it 'returns null when there are no wheres', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        assert.equal manager.whereSql(), null

    # TODO Implement Update

    describe 'project', ->
      it 'takes multiple args', ->
        manager = new SelectManager()
        manager.project(new Nodes.SqlLiteral('foo'), new Nodes.SqlLiteral('bar'))
        assert.equal manager.toSql(), 'SELECT foo, bar'

      it 'takes strings', ->
        manager = new SelectManager()
        manager.project(Rel.sql('*'))
        assert.equal manager.toSql(), 'SELECT *'

      it 'takes sql literals', ->
        manager = new SelectManager()
        manager.project(new Nodes.SqlLiteral('*'))
        assert.equal manager.toSql(), 'SELECT *'

    describe 'take', ->
      it 'knows take', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from(table).project(table.column('id'))
        manager.where(table.column('id').eq(1))
        manager.take 1

        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1 LIMIT 1'

      it 'chains', ->
        manager = new SelectManager()
        assert.equal manager.take(1).constructor, SelectManager

      it 'removes limit when null is passed to take only (not limit)', ->
        manager = new SelectManager()
        manager.limit(10)
        manager.take(null)
        assert.equal manager.toSql(), 'SELECT'

    describe 'join', ->
      it 'joins itself', ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))

        mgr = left.join right
        mgr.project(new SqlLiteral('*'))
        assert.equal mgr.on(predicate).constructor, SelectManager

        assert.equal mgr.toSql(), 'SELECT * FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"'

    describe 'from', ->
      it 'makes sql', ->
        table = new Table 'users'
        manager = new SelectManager()

        manager.from table
        manager.project table.column('id')
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users"'

      it 'chains', ->
        table = new Table 'users'
        manager = new SelectManager()
        assert.equal manager.from(table).project(table.column('id')).constructor, SelectManager
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users"'

    describe 'bools', ->
      it 'work', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.project table.column('id')
        manager.where table.column('underage').eq(true)
        assert.equal manager.toSql(),
          'SELECT "users"."id" FROM "users" WHERE "users"."underage" = true'

    describe 'not', ->
      it 'works', ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.project table.column('id')
        manager.where table.column('age').gt(18).not()
        assert.equal manager.toSql(),
          'SELECT "users"."id" FROM "users" WHERE NOT ("users"."age" > 18)'

    describe 'subqueries', ->
      it 'work in from', ->
        a = Rel.select().project(new Nodes.As(1, new Nodes.UnqualifiedName('x'))).as('a')
        b = Rel.select().project(new Nodes.As(1, new Nodes.UnqualifiedName('x'))).as('b')
        q = Rel.select()
          .from(a).join(b, Nodes.LeftOuterJoin)
          .on(a.column('x').eq(b.column('x')))
          .project(Rel.star())
        assert.equal q.toSql(),
          'SELECT * FROM (SELECT 1 AS "x") "a" LEFT OUTER JOIN (SELECT 1 AS "x") "b" ON "a"."x" = "b"."x"'
      it 'work in project', ->
        a = Rel.select().project(1)
        b = Rel.select().project(1)
        q = Rel.select().project(a.eq(b))
        assert.equal q.toSql(), 'SELECT (SELECT 1) = (SELECT 1)'

    it 'all comparators work', ->
      tab = Rel.table('x')
      q = Rel.select().project(
        tab.column('x').lt(2)
        tab.column('x').lteq(2)
        tab.column('x').gt(2)
        tab.column('x').gteq(2)
        tab.column('x').notEq(2)
        tab.column('x').isNull()
        tab.column('x').notNull()
        tab.column('x').like('%John%')
        tab.column('x').ilike('%john%')
      ).toSql()
      assert.equal q, """SELECT "x"."x" < 2, "x"."x" <= 2, "x"."x" > 2, "x"."x" >= 2, "x"."x" <> 2, "x"."x" IS NULL, "x"."x" IS NOT NULL, "x"."x" LIKE '%John%', "x"."x" ILIKE '%john%'"""

    it 'nulls', ->
      assert.equal Rel.select().project(null).toSql(), 'SELECT NULL'

    describe 'case', ->
      it 'works', ->
        u = Rel.table('users')
        q = Rel.select()
          .from(u)
          .project(
            Rel.case()
              .when(u.column('age').lt(18), 'underage')
              .when(u.column('age').gteq(18), 'OK')
              .else(null)
              .end()
            Rel.case(u.column('protection'))
              .when('private', true)
              .when('public', false)
              .end().as('private')
          )
        assert.equal q.toSql(),
          """
          SELECT
          CASE
          WHEN "users"."age" < 18 THEN 'underage'
          WHEN "users"."age" >= 18 THEN 'OK'
          ELSE NULL
          END,
          CASE "users"."protection"
          WHEN 'private' THEN true
          WHEN 'public' THEN false
          END AS "private"
          FROM "users"
          """.replace(/\s+/g, ' ').trim()

    it 'constant literals', ->
      assert.equal Rel.select().project(Rel.lit(false).not()).toSql(),
        "SELECT NOT (false)"
      assert.equal Rel.select().project(Rel.lit(3).eq(Rel.lit(3))).toSql(),
        "SELECT 3 = 3"
      assert.equal Rel.select().project(Rel.lit('a').in(Rel.lit(['a']))).toSql(),
        "SELECT 'a' IN ('a')"
