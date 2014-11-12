require "date-utils"

Rel = require "../../lib/rel"

class FakeEngine
  visitor: ->
    new Rel.Visitors.ToSql(@)

  columnFor: (table, name) ->

  quote: (thing, column) ->
    if column?
      if column.type == "integer"
        thing = Number(thing)
      else if column.type == "string"
        thing = String(thing)

    if thing == null
      'NULL'
    else if thing.constructor == Boolean
      if thing then "'t'" else "'f'"
    else if thing.constructor == Date
      "'#{thing.toDBString()}'"
    else if thing.constructor == Number
      thing
    else
      "'" + String(thing).replace("'", "\\'") + "'"

  quoteColumnName: (name) ->
    "\"#{name}\""

  quoteTableName: (name) ->
    "\"#{name}\""

module.exports = FakeEngine
