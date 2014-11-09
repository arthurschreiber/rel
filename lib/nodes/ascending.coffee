Ordering = require './ordering'

class Ascending extends Ordering
  reverse: ->
    new Descending(expr)

  direction: ->
    'asc'

  isAscending: ->
    true

  isDescending: ->
    false

module.exports = Ascending
