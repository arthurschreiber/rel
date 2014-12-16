"use strict";

var u = require('underscore');

var SelectManager = require('./select-manager');
var Attributes = require('./attributes');
var Nodes = require('./nodes');
var FactoryMethods = require('./factory-methods');
var Crud = require('./crud');

u.extend(Table.prototype, FactoryMethods, Crud);

function Table(name, opts) {
  this.name = name;
  if (opts == null) {
    opts = {};
  }
  this.columns = null;
  this.aliases = [];
  this.tableAlias = null;
  if (opts.as != null) {
    this.tableAlias = opts.as;
  }
}

Table.prototype.from = function() {
  return new SelectManager(this);
};

Table.prototype.project = function() {
  var args = new Array(arguments.length);
  for(var i = 0; i < arguments.length; i++) {
    args[i] = arguments[i];
  }

  var mgr = this.from();
  return mgr.project.apply(mgr, args);
};

Table.prototype.attribute = function(name) {
  return new Attributes.Attribute(this, name);
};

Table.prototype.alias = function(name) {
  if (name == null) {
    name = "" + this.name + "_2";
  }

  var alias = new Nodes.TableAlias(this, name);
  this.aliases.push(alias);
  return alias;
};

Table.prototype.column = function(name) {
  return new Attributes.Attribute(this, name);
};

Table.prototype.join = function(relation, klass) {
  if (klass == null) {
    klass = Nodes.InnerJoin;
  }
  if (relation == null) {
    return this.from();
  }
  switch (relation.constructor) {
    case String:
    case Nodes.SqlLiteral:
      klass = Nodes.StringJoin;
  }
  return this.from().join(relation, klass);
};

Table.prototype.skip = function(amount) {
  return this.from().skip(amount);
};

Table.prototype.having = function(expr) {
  return this.from().having(expr);
};

Table.prototype.group = function() {
  var args = new Array(arguments.length);
  for(var i = 0; i < arguments.length; i++) {
    args[i] = arguments[i];
  }

  var mgr = this.from();
  return mgr.group.apply(mgr, args);
};

Table.prototype.order = function() {
  var args = new Array(arguments.length);
  for(var i = 0; i < arguments.length; i++) {
    args[i] = arguments[i];
  }

  var mgr = this.from();
  return mgr.order.apply(mgr, args);
};

Table.prototype.take = function(amount) {
  return this.from().take(amount);
};

Table.prototype.where = function(condition) {
  return this.from().where(condition);
};

Table.prototype.star = function() {
  return this.column(new Nodes.SqlLiteral('*'));
};

module.exports = Table;
