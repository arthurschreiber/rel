// Generated by CoffeeScript 1.8.0
var FullOuterJoin, Join,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Join = require('./join');

FullOuterJoin = (function(_super) {
  __extends(FullOuterJoin, _super);

  function FullOuterJoin() {
    return FullOuterJoin.__super__.constructor.apply(this, arguments);
  }

  return FullOuterJoin;

})(Join);

module.exports = FullOuterJoin;