class Visitor
  accept: (object, collector) ->
    @visit object, collector

  visit: (object, collector) ->
    type = object?.constructor.name ? 'Null'
    @["visitRelNodes#{type}"](object)

exports = module.exports = Visitor
