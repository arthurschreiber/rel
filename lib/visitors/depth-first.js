"use strict";

module.exports = DepthFirst;

var u = require('underscore');
var util = require('util');

var Visitor = require('./visitor');

function DepthFirst(callback) {
  DepthFirst.super_.apply(this, arguments);
  this.callback = callback || function() {};
}

util.inherits(DepthFirst, Visitor);

DepthFirst.prototype.visit = function(o) {
  DepthFirst.super_.prototype.visit.call(this, o);
  this.callback(o);
};

DepthFirst.prototype.visitRelNodesGroup =
DepthFirst.prototype.visitRelNodesGrouping =
DepthFirst.prototype.visitRelNodesHaving =
DepthFirst.prototype.visitRelNodesLimit =
DepthFirst.prototype.visitRelNodesNot =
DepthFirst.prototype.visitRelNodesOffset =
DepthFirst.prototype.visitRelNodesOn =
DepthFirst.prototype.visitRelNodesOrdering =
DepthFirst.prototype.visitRelNodesAscending =
DepthFirst.prototype.visitRelNodesDescending =
DepthFirst.prototype.visitRelNodesTop =
DepthFirst.prototype.visitRelNodesUnqualifiedColumn = function(o) {
  this.visit(o.expr);
};

DepthFirst.prototype.visitRelNodesAvg =
DepthFirst.prototype.visitRelNodesExists =
DepthFirst.prototype.visitRelNodesMax =
DepthFirst.prototype.visitRelNodesMin =
DepthFirst.prototype.visitRelNodesSum =
DepthFirst.prototype.visitRelNodesCount = function(o) {
  this.visit(o.expressions);
  this.visit(o.alias);
  this.visit(o.distinct);
};

DepthFirst.prototype.visitRelNodesNamedFunction = function(o) {
  this.visit(o.name);
  this.visit(o.expressions);
  this.visit(o.distinct);
  this.visit(o.alias);
};

DepthFirst.prototype.visitRelNodesAnd = function(o) {
  u.each(o.children, this.visit, this);
};

DepthFirst.prototype.visitRelNodesAs =
DepthFirst.prototype.visitRelNodesAssignment =
DepthFirst.prototype.visitRelNodesBetween =
DepthFirst.prototype.visitRelNodesDeleteStatement =
DepthFirst.prototype.visitRelNodesDoesNotMatch =
DepthFirst.prototype.visitRelNodesEquality =
DepthFirst.prototype.visitRelNodesFullOuterJoin =
DepthFirst.prototype.visitRelNodesGreaterThan =
DepthFirst.prototype.visitRelNodesGreaterThanOrEqual =
DepthFirst.prototype.visitRelNodesIn =
DepthFirst.prototype.visitRelNodesInfixOperation =
DepthFirst.prototype.visitRelNodesJoinSource =
DepthFirst.prototype.visitRelNodesInnerJoin =
DepthFirst.prototype.visitRelNodesLessThan =
DepthFirst.prototype.visitRelNodesLessThanOrEqual =
DepthFirst.prototype.visitRelNodesMatches =
DepthFirst.prototype.visitRelNodesNotEqual =
DepthFirst.prototype.visitRelNodesNotIn =
DepthFirst.prototype.visitRelNodesNotRegexp =
DepthFirst.prototype.visitRelNodesOr =
DepthFirst.prototype.visitRelNodesOuterJoin =
DepthFirst.prototype.visitRelNodesRegexp =
DepthFirst.prototype.visitRelNodesRightOuterJoin =
DepthFirst.prototype.visitRelNodesTableAlias =
DepthFirst.prototype.visitRelNodesValues =
DepthFirst.prototype.visitRelNodesUnion = function(o) {
  this.visit(o.left);
  this.visit(o.right);
};

DepthFirst.prototype.visitRelNodesStringJoin = function(o) {
  this.visit(o.left);
};

DepthFirst.prototype.visitRelNodesTable = function(o) {
  this.visit(o.name);
};

DepthFirst.prototype.visitRelNodesString = function() {};

DepthFirst.prototype.visitRelNodesInsertStatement = function(o) {
  this.visit(o.relation);
  this.visit(o.columns);
  this.visit(o.values);
};

DepthFirst.prototype.visitRelNodesSelectCore = function(o) {
  this.visit(o.projections);
  this.visit(o.source);
  this.visit(o.wheres);
  this.visit(o.groups);
  this.visit(o.windows);
  this.visit(o.having);
};

DepthFirst.prototype.visitRelNodesSelectStatement = function(o) {
  this.visit(o.cores);
  this.visit(o.orders);
  this.visit(o.limit);
  this.visit(o.lock);
  this.visit(o.offset);
};

DepthFirst.prototype.visitRelNodesUpdateStatement = function(o) {
  this.visit(o.relation);
  this.visit(o.values);
  this.visit(o.wheres);
  this.visit(o.orders);
  this.visit(o.limit);
};

DepthFirst.prototype.visitRelNodesArray = function(o) {
  u.each(o, this.visit, this);
};
