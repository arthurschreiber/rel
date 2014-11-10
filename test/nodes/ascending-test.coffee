assert = require('chai').assert

Rel = require '../../src/rel'

{ Ascending, Descending } = Rel.Nodes

describe 'Ascending', ->
  beforeEach ->
    @ascending = new Ascending('zomg')

  it 'takes an expression on construction', ->
    assert.equal @ascending.expr, 'zomg'

  it 'can be reversed', ->
    descending = @ascending.reverse()

    assert.instanceOf descending, Descending
    assert.strictEqual @ascending.expr, descending.expr

  it 'has a direction', ->
    assert.equal @ascending.direction(), 'asc'

  it 'is ascending', ->
    assert.isTrue @ascending.isAscending()

  it 'is not descending', ->
    assert.isFalse @ascending.isDescending()

  it 'is equal with equal contents', ->
    nodes = [ new Ascending('zomg'), new Ascending('zomg') ]

    assert.isTrue nodes[0].equals(nodes[1])
    assert.isTrue nodes[1].equals(nodes[0])

  it 'is not equal with different contents', ->
    nodes = [ new Ascending('zomg'), new Ascending('zomg!') ]

    assert.isFalse nodes[0].equals(nodes[1])
    assert.isFalse nodes[1].equals(nodes[0])
