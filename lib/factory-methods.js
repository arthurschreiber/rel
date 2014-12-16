"use strict";

var u = require('underscore');

var Nodes = require('./nodes');

u.extend(module.exports, {
  createTableAlias: function(relation, name) {
    return new Nodes.TableAlias(relation, name);
  },
  createJoin: function(to, constraint, klass) {
    if (constraint == null) {
      constraint = null;
    }
    if (klass == null) {
      klass = Nodes.InnerJoin;
    }
    return new klass(to, constraint);
  },
  createStringJoin: function(to) {
    return this.createJoin(to, null, Nodes.StringJoin);
  },
  createAnd: function(clauses) {
    return new Nodes.And(clauses);
  },
  createOn: function(expr) {
    return new Nodes.On(expr);
  },
  grouping: function(expr) {
    return new Nodes.Grouping(expr);
  }
});