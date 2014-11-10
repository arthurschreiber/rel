Join = require './join'

class StringJoin extends Join
  constructor: (left, right=null) ->
    super left, right

module.exports = StringJoin
