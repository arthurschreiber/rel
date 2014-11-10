assert = require('chai').assert

Rel = require '../../src/rel'

{ And } = Rel.Nodes

describe 'And', ->
  describe '#equals', ->
    it 'is equal with equal contents', ->
      nodes = [ new And(['foo', 'bar']), new And(['foo', 'bar']) ]

      assert.isTrue nodes[0].equals(nodes[1])
      assert.isTrue nodes[1].equals(nodes[0])


    it 'is not equal with different contents', ->
      nodes = [ new And(['foo', 'bar']), new And(['foo', 'baz']) ]

      assert.isFalse nodes[0].equals(nodes[1])
      assert.isFalse nodes[1].equals(nodes[0])