Binary = require './binary'

class JoinSource extends Binary
  constructor: (singleSource, joinop=[]) ->
    super(singleSource, joinop)
  
  isEmpty: ->
    !@left && !@right?.length

exports = module.exports = JoinSource
