// Generated by CoffeeScript 1.8.0
var Node, Window,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Node = require('./node');

Window = (function(_super) {
  __extends(Window, _super);

  function Window() {
    return Window.__super__.constructor.apply(this, arguments);
  }

  return Window;

})(Node);

module.exports = Window;