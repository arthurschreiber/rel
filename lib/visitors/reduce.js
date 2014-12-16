"use strict";

module.exports = Reduce;

var util = require('util');

var Visitor = require('./visitor');

function Reduce() {
  return Reduce.super_.constructor.apply(this, arguments);
}

util.inherits(Reduce, Visitor);

Reduce.prototype.accept = function(object, collector) {
  return this.visit(object, collector);
};

Reduce.prototype.visit = function(object, collector) {
  var type = object != null && object.constructor.name;

  if (!type) {
    throw new Error("Cannot visit " + util.inspect(object));
  }

  return this["visitRelNodes" + type](object, collector);
};
