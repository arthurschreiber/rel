class SQLString
  constructor: ->
    @value = ""

  append: (str) ->
    @value += str
    @

  addBind: (bv) ->
    @append(bv)

  compile: (bvs) ->
    @value

module.exports = SQLString