Binary = require './binary'

class Values extends Binary
  constructor: (exprs, columns=[]) ->
    super exprs, columns

  expressions: (e=null) ->
    if e?
      @left = e
    else
      @left

  columns: (c=null) ->
    if c?
      @right = c
    else
      @right

module.exports = Values
