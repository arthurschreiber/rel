u = require 'underscore'

Nodes = require './nodes'

u.extend module.exports,
  count: (distinct = false) ->
    new Nodes.Count [@], distinct

  sum: ->
    new Nodes.Sum [@]

  maximum: ->
    new Nodes.Max [@]

  minimum: ->
    new Nodes.Min [@]

  average: ->
    new Nodes.Avg [@]
