class SQLString
  constructor: ->
    @value = ""

  append: (str) ->
    @value += str
    @

  addBind: (bv) ->
    @append(bind)

  compile: (bvs) ->
    @value

module.exports = SQLString