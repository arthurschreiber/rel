assert = require('chai').assert

FakeEngine = require '../support/fake-engine'

Rel = require '../../lib/rel'

describe 'Rel.Visitors.DepthFirst', ->
  beforeEach ->
    @calls = []
    @visitor = new Rel.Visitors.DepthFirst (obj) =>
      @calls.push(obj)

  it 'raises an error with a normal object', ->
    assert.throws =>
      @visitor.accept({})

  [
    Rel.Nodes.Not,
    Rel.Nodes.Group,
    Rel.Nodes.On,
    Rel.Nodes.Offset,
    Rel.Nodes.Ordering,
    Rel.Nodes.Having,
    Rel.Nodes.StringJoin,
    Rel.Nodes.UnqualifiedColumn,
    Rel.Nodes.Top,
    Rel.Nodes.Limit
  ].forEach (klass) ->
    it "can visit #{klass.name}", ->
      op = new klass("a")
      @visitor.accept(op)

      assert.lengthOf @calls, 2
      assert.equal @calls[0], "a"
      assert.strictEqual @calls[1], op