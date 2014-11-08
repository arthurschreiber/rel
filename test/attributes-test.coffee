describe.skip 'Attributes', ->
  it 'responds to lower', ->
    relation  = new Table('users')
    attribute = relation.column('foo')
    node      = attribute.lower()
    assert.equal 'LOWER', node.name
    assert.deepEqual [attribute], node.expressions

  describe 'equality', ->
    it 'is equal with equal properties', ->
      attr1 = new Attribute('foo', 'bar')
      attr2 = new Attribute('foo', 'bar')

      assert.isTrue attr1.equals(attr2)
      assert.isTrue attr2.equals(attr1)

    it 'is not equal with different properties', ->
      attr1 = new Attribute('foo', 'bar')
      attr2 = new Attribute('foo', 'baz')

      assert.isFalse attr1.equals(attr2)
      assert.isFalse attr2.equals(attr1)

  describe 'for', ->
    it 'deals with unknown column types', ->
      column = { type: 'crazy' }
      assert.equal Attributes.for(column), Attributes.Undefined

    it 'returns the correct constant for strings', ->
      ['string', 'text', 'binary'].each (type) -> 
        column = { type: type }
        assert.equal Attributes.for(column), Attributes.String

    it 'returns the correct constant for ints', ->
      column = { type: 'integer' }
      assert.equal Attributes.for(column), Attributes.Integer

    it 'returns the correct constant for floats', ->
      column = { type: 'float' }
      assert.equal Attributes.for(column), Attributes.Float

    it 'returns the correct constant for decimals', ->
      column = { type: 'decimal' }
      assert.equal Attributes.for(column), Attributes.Decimal

    it 'returns the correct constant for boolean', ->
      column = { type: 'boolean' }
      assert.equal Attributes.for(column), Attributes.Boolean

    it 'returns the correct constant for time', ->
      ['date', 'datetime', 'timestamp', 'time'].each (type) -> 
        column = { type: type }
        assert.equal Attributes.for(column), Attributes.Time
