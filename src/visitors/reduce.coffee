Visitor = require './visitor'

class Reduce extends Visitor
  accept: (object, collector) ->
    @visit object, collector

  visit: (object, collector) ->
    type = object?.constructor.name ? 'Null'
    @["visitRelNodes#{type}"](object, collector)

module.exports = Reduce
