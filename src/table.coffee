u = require 'underscore'

SelectManager = require './select-manager'
InsertManager = require './insert-manager'
UpdateManager = require './update-manager'
DeleteManager = require './delete-manager'
Attributes = require './attributes'
Nodes = require './nodes'
FactoryMethods = require './factory-methods'
Crud = require './crud'

class Table
  u.extend(@prototype, FactoryMethods, Crud)

  # TODO I think table alias does nothing.
  constructor: (@name, @engine, opts = {}) ->
    @columns = null
    @aliases = []
    @tableAlias = null
    @tableAlias = opts['as'] if opts['as']?

  from: (table) ->
    new SelectManager(@engine, table)

  project: (things...) ->
    @from(@).project things...

  attribute: (name) ->
    new Attributes.Attribute(@, name)

  alias: (name) ->
    name = "#{@name}_2" unless name?

    u(new Nodes.TableAlias(@, name)).tap (node) =>
      @aliases.push node

  column: (name) ->
    new Attributes.Attribute @, name

  join: (relation, klass=Nodes.InnerJoin) ->
    return @from(@) unless relation?

    switch relation.constructor
      when String, Nodes.SqlLiteral
        klass = Nodes.StringJoin
    @from(@).join(relation, klass)

  insertManager: ->
    new InsertManager(@engine)

  skip: (amount) ->
    @from(@).skip amount

  selectManager: ->
    new SelectManager(@engine)

  updateManager: ->
    new UpdateManager(@engine)

  deleteManager: ->
    new DeleteManager(@engine)

  having: (expr) ->
    @from(@).having expr

  group: (columns...) ->
    @from(@).group columns...

  order: (expr...) ->
    @from(@).order expr...

  take: (amount) ->
    @from(@).take amount

  where: (condition) ->
    @from(@).where condition

  star: ->
    @column(new Nodes.SqlLiteral('*'))

module.exports = Table
