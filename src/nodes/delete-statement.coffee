u = require 'underscore'

Binary = require './node'

class DeleteStatement extends Binary
  constructor: (@relation, @wheres = []) ->
    super(@relation, @wheres)

exports = module.exports = DeleteStatement
