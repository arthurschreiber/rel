u = require 'underscore'

BindParam = require '../nodes/bind-param'

class Bind
  constructor: ->
    @value = []

  append: (str) ->
    @value.push(str)
    @

  addBind: (bind) ->
    @value.push(bind)
    @

  substituteBinds: (bvs) ->
    # Clone the bind values array so we don't perform any
    # modifications
    bvs = bvs.slice(0)

    u.map @value, (val) ->
      if val.constructor == BindParam
        return bvs.shift()
      else
        return val

  compile: (bvs) ->
    @substituteBinds(bvs).join('')

module.exports = Bind
