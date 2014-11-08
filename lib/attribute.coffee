u = require 'underscore'

Expressions = require './expressions'
Predications = require './predications'

class Attribute
  u(@prototype).extend Expressions, Predications

  constructor: (@relation, @name) ->

exports = module.exports = Attribute
