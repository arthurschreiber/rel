Ordering = require './ordering'
Descending = require './descending'

class Ascending extends Ordering
  reverse: ->
    new Descending(@expr)

  direction: ->
    'asc'

  isAscending: ->
    true

  isDescending: ->
    false

module.exports = Ascending
