"use strict";

module.exports = TreeManager;

var u = require('underscore');

var FactoryMethods = require('./factory-methods');
var Visitors = require('./visitors');
var SQLString = require('./collectors/sql-string');

function TreeManager() {
  this.ast = null;
  this.ctx = null;
}

u.extend(TreeManager.prototype, FactoryMethods);

TreeManager.prototype.toDot = function() {
  return new Visitors.Dot().accept(this.ast);
};

TreeManager.prototype.toSql = function(engine) {
  var collector = new SQLString();
  engine.visitor().accept(this.ast, collector);
  return collector.value;
};

TreeManager.prototype.where = function(expr) {
  if (TreeManager === expr.constructor) {
    expr = expr.ast;
  }
  this.ctx.wheres.push(expr);
  return this;
};
