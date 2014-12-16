"use strict";

module.exports = SelectManager;

var __slice = [].slice;

var u = require('underscore');
var util = require('util');

var Nodes = require('./nodes');
var TreeManager = require('./tree-manager');
var Predications = require('./predications');

util.inherits(SelectManager, TreeManager);
u.extend(SelectManager.prototype, Predications);

function SelectManager(table) {
  SelectManager.super_.call(this);
  this.ast = new Nodes.SelectStatement();
  this.ctx = u(this.ast.cores).last();
  this.from(table);
}

SelectManager.prototype.project = function() {
  var projections = this.ctx.projections;

  for (var i = 0; i < arguments.length; i++) {
    projections.push(arguments[i]);
  }

  return this;
};

SelectManager.prototype.order = function() {
  var orders = this.ast.orders, order;

  for (var i = 0; i < arguments.length; i++) {
    order = arguments[i];

    if (order.constructor === String) {
      orders.push(new Nodes.SqlLiteral(order.toString()));
    } else {
      orders.push(order);
    }
  }

  return this;
};

SelectManager.prototype.orders = function() {
  return this.ast.orders;
};

SelectManager.prototype.from = function(table) {
  if ((table != null) && table.constructor === String) {
    table = new Nodes.SqlLiteral(table);
  }

  if (table != null) {
    switch (table.constructor) {
      case Nodes.Join:
        this.ctx.source.right.push(table);
      break;
      case Nodes.InnerJoin:
        this.ctx.source.right.push(table);
      break;
      case Nodes.OuterJoin:
        this.ctx.source.right.push(table);
      break;
      case Nodes.RightOuterJoin:
        this.ctx.source.right.push(table);
      break;
      case Nodes.FullOuterJoin:
        this.ctx.source.right.push(table);
      break;
      case Nodes.StringJoin:
        this.ctx.source.right.push(table);
      break;
      default:
        this.ctx.source.left = table;
    }
  } else {
    this.ctx.source.left = null;
  }

  return this;
};

SelectManager.prototype.froms = function() {
  return u.compact(u.map(this.ast.cores, function(x) {
    return x.from();
  }));
};

SelectManager.prototype.group = function() {
  var groups = this.ctx.groups, grouping;

  for (var i = 0; i < arguments.length; i++) {
    grouping = arguments[i];

    if (grouping.constructor === String) {
      grouping = new Nodes.SqlLiteral(grouping);
    }

    groups.push(new Nodes.Group(grouping));
  }

  return this;
};

SelectManager.prototype.as = function(other) {
  return this.createTableAlias(this.grouping(this.ast), new Nodes.SqlLiteral(other));
};

SelectManager.prototype.having = function() {
  var exprs;
  exprs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  this.ctx.having = new Nodes.Having(this.collapse(exprs, this.ctx.having));
  return this;
};

SelectManager.prototype.collapse = function(exprs, existing) {
  if (existing == null) {
    existing = null;
  }
  if (existing != null) {
    exprs = exprs.unshift(existing.expr);
  }
  exprs = u(exprs).compact().map((function(_this) {
    return function(expr) {
      if (expr.constructor === String) {
        return new Nodes.SqlLiteral(expr);
      } else {
        return expr;
      }
    };
  })(this));
  if (exprs.length === 1) {
    return exprs[0];
  } else {
    return this.createAnd(exprs);
  }
};

SelectManager.prototype.join = function(relation, klass) {
  if (klass == null) {
    klass = Nodes.InnerJoin;
  }
  if (relation == null) {
    return this;
  }
  switch (relation.constructor) {
    case String:
    case Nodes.SqlLiteral:
      klass = Nodes.StringJoin;
  }
  this.ctx.source.right.push(this.createJoin(relation, null, klass));
  return this;
};

SelectManager.prototype.on = function() {
  var exprs;
  exprs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  u(this.ctx.source.right).last().right = new Nodes.On(this.collapse(exprs));
  return this;
};

SelectManager.prototype.skip = function(amount) {
  if (amount != null) {
    this.ast.offset = new Nodes.Offset(amount);
  } else {
    this.ast.offset = null;
  }
  return this;
};

SelectManager.prototype.offset = function(amount) {
  return this.skip(amount);
};

SelectManager.prototype.exists = function() {
  return new Nodes.Exists(this.ast);
};

SelectManager.prototype.capitalize = function(string) {
  var op;
  op = string.toString();
  return op[0].toUpperCase() + op.slice(1, op.length);
};

SelectManager.prototype.union = function(operation, other) {
  var nodeClass;
  if (other == null) {
    other = null;
  }
  nodeClass = other != null ? Nodes["Union" + (this.capitalize(operation))] : (other = operation, Nodes.Union);
  return new nodeClass(this.ast, other.ast);
};

SelectManager.prototype.except = function(other) {
  return new Nodes.Except(this.ast, other.ast);
};

SelectManager.prototype.minus = function(other) {
  return this.except(other);
};

SelectManager.prototype.intersect = function(other) {
  return new Nodes.Intersect(this.ast, other.ast);
};

SelectManager.prototype["with"] = function() {
  var nodeClass, subqueries;
  subqueries = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  nodeClass = u(subqueries).first().constructor === String ? Nodes["With" + (this.capitalize(subqueries.shift()))] : Nodes.With;
  this.ast["with"] = new nodeClass(u(subqueries).flatten());
  return this;
};

SelectManager.prototype.take = function(limit) {
  if (limit != null) {
    this.ast.limit = new Nodes.Limit(limit);
    this.ctx.top = new Nodes.Top(limit);
  } else {
    this.ast.limit = null;
    this.ctx.top = null;
  }
  return this;
};

SelectManager.prototype.limit = function(limit) {
  if (limit != null) {
    return this.take(limit);
  } else {
    return this.ast.limit.expr;
  }
};

SelectManager.prototype.taken = function() {
  return this.limit();
};

SelectManager.prototype.lock = function(locking) {
  if (locking == null) {
    locking = new Nodes.SqlLiteral('FOR UPDATE');
  }
  this.ast.lock = new Nodes.Lock(locking);
  return this;
};

SelectManager.prototype.locked = function() {
  return this.ast.lock;
};
