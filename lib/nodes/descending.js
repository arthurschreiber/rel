// Generated by CoffeeScript 1.8.0
var Ascending, Descending, Ordering,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Ordering = require('./ordering');

Ascending = require('./ascending');

Descending = (function(_super) {
  __extends(Descending, _super);

  function Descending() {
    return Descending.__super__.constructor.apply(this, arguments);
  }

  Descending.prototype.reverse = function() {
    return new Ascending(this.expr);
  };

  Descending.prototype.direction = function() {
    return 'desc';
  };

  Descending.prototype.isAscending = function() {
    return false;
  };

  Descending.prototype.isDescending = function() {
    return true;
  };

  return Descending;

})(Ordering);

module.exports = Descending;