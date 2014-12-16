"use strict";

module.exports = Attribute;

var u = require('underscore');

var Expressions = require('./expressions');
var Predications = require('./predications');

function Attribute(relation, name) {
  this.relation = relation;
  this.name = name;
}

u(Attribute.prototype).extend(Expressions, Predications);
