assert = require('chai').assert

Rel = require '../../src/rel'

Table = Rel.Table
As = Rel.Nodes.As

describe 'As', ->
  describe '#as', ->
    it 'makes an AS node', ->
      attr = new Table('users').column('id')
      as = attr.as(Rel.sql('foo'))

      assert.strictEqual attr, as.left
      assert.equal 'foo', as.right

    it 'converts right to SqlLiteral if a string', ->
      attr = new Table('users').column('id')
      as = attr.as('foo')

      assert.instanceOf as.right, Rel.Nodes.SqlLiteral

  describe '#equals', ->
    it 'is equal with equal contents', ->
      nodes = [ new As('foo', 'bar'), new As('foo', 'bar') ]

      assert.isTrue nodes[0].equals(nodes[1])
      assert.isTrue nodes[1].equals(nodes[0])


    it 'is not equal with different contents', ->
      nodes = [ new As('foo', 'bar'), new As('foo', 'baz') ]

      assert.isFalse nodes[0].equals(nodes[1])
      assert.isFalse nodes[1].equals(nodes[0])
