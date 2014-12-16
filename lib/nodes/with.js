module.exports = With;

var util = require('util');

var Unary = require('./unary');

util.inherits(With, Unary);

function With() {
  return With.super_.apply(this, arguments);
}

Object.defineProperty(With.prototype, 'children', {
  get: function() {
    return this.expr;
  },
  set: function(expr) {
    this.expr = expr;
  }
});
