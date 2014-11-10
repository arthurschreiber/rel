Ordering = require './ordering'
Ascending = require './ascending'

class Descending extends Ordering
  reverse: ->
    new Ascending(@expr)

  direction: ->
    'desc'

  isAscending: ->
    false

  isDescending: ->
    true

module.exports = Descending
