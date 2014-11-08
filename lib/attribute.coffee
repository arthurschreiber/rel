u = require 'underscore'

Expressions = require './expressions'
Predications = require './predications'

class Attribute
  constructor: (@relation, @name) ->
    u(@).extend Expressions
    u(@).extend Predications

exports = module.exports = Attribute
