// Generated by CoffeeScript 1.8.0
var Extract, Unary,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Unary = require('./unary');

Extract = (function(_super) {
  __extends(Extract, _super);

  function Extract(expr, field) {
    this.field = field;
    Extract.__super__.constructor.call(this, expr);
  }

  Extract.prototype.equals = function(other) {};

  return Extract;

})(Unary);

module.exports = Extract;