"use strict";

var util = require('util');

module.exports = Visitor;

function Visitor() {}

Visitor.prototype.accept = function(object) {
  return this.visit(object);
};

Visitor.prototype.visit = function(object) {
  var type = object != null && object.constructor.name;

  if (!type) {
    throw new Error("Cannot visit " + util.inspect(object));
  }

  if (!this["visitRelNodes" + type]) {
    throw new Error("Cannot call #visitRelNodes" + type);
  }

  return this["visitRelNodes" + type](object);
};
