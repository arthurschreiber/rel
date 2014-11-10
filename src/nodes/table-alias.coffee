Attribute = require '../attribute'
Binary = require './binary'

class TableAlias extends Binary
  constructor: (@left, @right) ->
    super(@left, @right)
    @name = @right
    @relation = @left
    @tableAlias = @name
    @tableName = @relation.name

  column: (name) ->
    new Attribute(@, name)

module.exports = TableAlias
