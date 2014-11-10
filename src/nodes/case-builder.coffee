u = require 'underscore'

Node = require './node'
Expressions = require '../expressions'
Predications = require '../predications'

class CaseBuilder
  constructor: (@_base) ->
    @_cases = []
    @_else = undefined
  when: (cond, res) ->
    @_cases.push([cond, res])
    @
  else: (res) ->
    @_else = res
    @
  end: -> new Case(@_base, @_cases, @_else)

class Case extends Node
  u(@prototype).extend Expressions, Predications

  constructor: (@_base, @_cases, @_else) ->

exports = module.exports = CaseBuilder
