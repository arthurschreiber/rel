"use strict";

module.exports = UpdateManager;

var u = require('underscore');
var util = require('util');

var TreeManager = require('./tree-manager');
var UpdateStatement = require('./nodes/update-statement');
var Nodes = require('./nodes');

function UpdateManager() {
  UpdateManager.super_.call(this);
  this.ast = new UpdateStatement();
  this.ctx = this.ast;
}

util.inherits(UpdateManager, TreeManager);

UpdateManager.prototype.take = function(limit) {
  if (limit != null) {
    this.ast.limit = new Nodes.Limit(limit);
  }
  return this;
};

Object.defineProperty(UpdateManager.prototype, 'key', {
  get: function() {
    return this.ast.key;
  },

  set: function(key) {
    this.ast.key = key;
  }
});

UpdateManager.prototype.order = function() {
  var expr = new Array(arguments.length);
  for (var i = 0, len = arguments.length; i < len; i++) {
    expr[i] = arguments[i];
  }
  this.ast.orders = expr;
  return this;
};

UpdateManager.prototype.table = function(table) {
  this.ast.relation = table;
  return this;
};

UpdateManager.prototype.wheres = function() {
  var expr = new Array(arguments.length);
  for (var i = 0, len = arguments.length; i < len; i++) {
    expr[i] = arguments[i];
  }
  return this.ast.wheres = expr;
};

UpdateManager.prototype.where = function(expr) {
  this.ast.wheres.push(expr);
  return this;
};

UpdateManager.prototype.set = function(values) {
  if (values.constructor === String) {
    this.ast.values = [values];
  } else if (values.constructor === Nodes.SqlLiteral) {
    this.ast.values = [values];
  } else {
    this.ast.values = u.map(values, function(val) {
      var column = val[0], value = val[1];
      return new Nodes.Assignment(new Nodes.UnqualifiedColumn(column), value);
    });
  }
  return this;
};
