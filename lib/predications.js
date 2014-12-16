"use strict";

var u = require('underscore');

var SelectManager;
var Range;
var Nodes;

u.extend(module.exports, {
  as: function(other) {
    return new Nodes.As(this, new Nodes.SqlLiteral(other));
  },

  notEq: function(other) {
    return new Nodes.NotEqual(this, other);
  },

  notEqAny: function(others) {
    return this.groupingAny('notEq', others);
  },

  notEqAll: function(others) {
    return this.groupingAll('notEq', others);
  },

  isNull: function() {
    return new Nodes.IsNull(this);
  },

  notNull: function() {
    return new Nodes.NotNull(this);
  },

  eq: function(other) {
    return new Nodes.Equality(this, other);
  },

  eqAny: function(others) {
    return this.groupingAny('eq', others);
  },

  eqAll: function(others) {
    return this.groupingAll('eq', others);
  },

  "in": function(other) {
    switch (other.constructor) {
      case SelectManager:
        return new Nodes.In(this, other.ast);
      case Range:
        return new Nodes.Between(this, new Nodes.And([other.start, other.finish]));
      default:
        return new Nodes.In(this, other);
    }
  },

  inAny: function(others) {
    return this.groupingAny('in', others);
  },

  inAll: function(others) {
    return this.groupingAll('in', others);
  },

  notIn: function(other) {
    if (other.constructor === SelectManager) {
      return new Nodes.NotIn(this, other.ast);
    } else {
      return new Nodes.NotIn(this, other);
    }
  },

  notInAny: function(others) {
    return this.groupingAny('notIn', others);
  },

  notInAll: function(others) {
    return this.groupingAll('notIn', others);
  },

  matches: function(other) {
    return new Nodes.Matches(this, other);
  },

  matchesAny: function(others) {
    return this.groupingAny('matches', others);
  },

  matchesAll: function(others) {
    return this.groupingAll('matches', others);
  },

  doesNotMatch: function(other) {
    return new Nodes.DoesNotMatch(this, other);
  },

  doesNotMatchAny: function(others) {
    return this.groupingAny('doesNotMatch', others);
  },

  doesNotMatchAll: function(others) {
    return this.groupingAll('doesNotMatch', others);
  },

  gteq: function(right) {
    return new Nodes.GreaterThanOrEqual(this, right);
  },

  gteqAny: function(others) {
    return this.groupingAny('gteq', others);
  },

  gteqAll: function(others) {
    return this.groupingAll('gteq', others);
  },

  gt: function(right) {
    return new Nodes.GreaterThan(this, right);
  },

  gtAny: function(others) {
    return this.groupingAny('gt', others);
  },

  gtAll: function(others) {
    return this.groupingAll('gt', others);
  },

  lteq: function(right) {
    return new Nodes.LessThanOrEqual(this, right);
  },

  lteqAny: function(others) {
    return this.groupingAny('lteq', others);
  },

  lteqAll: function(others) {
    return this.groupingAll('lteq', others);
  },

  lt: function(right) {
    return new Nodes.LessThan(this, right);
  },

  ltAny: function(others) {
    return this.groupingAny('lt', others);
  },

  ltAll: function(others) {
    return this.groupingAll('lt', others);
  },

  like: function(right) {
    return new Nodes.Like(this, right);
  },

  ilike: function(right) {
    return new Nodes.ILike(this, right);
  },

  asc: function() {
    return new Nodes.Ascending(this);
  },

  desc: function() {
    return new Nodes.Descending(this);
  },

  groupingAny: function(methodId, others) {
    var nodes = u.map(others, function(expr) {
      return this[methodId](expr);
    }.bind(this));

    return new Nodes.Grouping(u.reduce(nodes, function(memo, node) {
      return new Nodes.Or(memo, node);
    }));
  },

  groupingAll: function(methodId, others) {
    var nodes = u.map(others, function(expr) {
      return this[methodId](expr);
    }.bind(this));

    return new Nodes.Grouping(u.reduce(nodes, function(memo, node) {
      return new Nodes.And(memo, node);
    }));
  }
});

SelectManager = require('./select-manager');
Range = require('./range');
Nodes = require('./nodes');
