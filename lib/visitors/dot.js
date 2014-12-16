"use strict";

module.exports = Dot;

var u = require('underscore');
var util = require('util');

var Visitor = require('./visitor');

function Node(name, id, fields) {
  this.name = name;
  this.id = id;
  this.fields = fields != null ? fields : [];
}

function Edge(name, from, to) {
  this.name = name;
  this.from = from;
  this.to = to;
}

function Dot() {
  this.nodes = [];
  this.edges = [];
  this.nodeStack = [];
  this.edgeStack = [];
  this.seen = {};
}

util.inherits(Dot, Visitor);

Dot.prototype.accept = function(object) {
  Dot.super_.prototype.accept.call(this, object);
  return this.toDot();
};

Dot.prototype.visitRelNodesOrdering = function(o) {
  this.visitEdge(o, 'expr');
};

Dot.prototype.visitRelNodesTableAlias = function(o) {
  this.visitEdge(o, 'name');
  this.visitEdge(o, 'relation');
};

Dot.prototype.visitRelNodesCount = function(o) {
  this.visitEdge(o, 'expressions');
  this.visitEdge(o, 'distinct');
};

Dot.prototype.visitRelNodesValues = function(o) {
  this.visitEdge(o, 'expressions');
};

Dot.prototype.visitRelNodesStringJoin = function(o) {
  this.visitEdge(o, 'left');
};

Dot.prototype.visitRelNodesInnerJoin =
Dot.prototype.visitRelNodesFullOuterJoin =
Dot.prototype.visitRelNodesOuterJoin =
Dot.prototype.visitRelNodesRightOuterJoin = function(o) {
  this.visitEdge(o, 'left');
  this.visitEdge(o, 'right');
};

Dot.prototype.visitRelNodesDeleteStatement = function(o) {
  this.visitEdge(o, 'relation');
  this.visitEdge(o, 'wheres');
};

Dot.prototype.visitRelNodesGroup = 
Dot.prototype.visitRelNodesGrouping = 
Dot.prototype.visitRelNodesHaving = 
Dot.prototype.visitRelNodesLimit = 
Dot.prototype.visitRelNodesNot = 
Dot.prototype.visitRelNodesOffset = 
Dot.prototype.visitRelNodesOn = 
Dot.prototype.visitRelNodesTop = 
Dot.prototype.visitRelNodesUnqualifiedColumn =
Dot.prototype.visitRelNodesPreceding =
Dot.prototype.visitRelNodesFollowing =
Dot.prototype.visitRelNodesRows =
Dot.prototype.visitRelNodesRange = function(o) {
  return this.visitEdge(o, 'expr');
};

Dot.prototype.visitRelNodesWindow = function(o) {
  this.visitEdge(o, 'partitions');
  this.visitEdge(o, 'orders');
  this.visitEdge(o, 'framing');
};

Dot.prototype.visitRelNodesNamedWindow = function(o) {
  this.visitEdge(o, 'partitions');
  this.visitEdge(o, 'orders');
  this.visitEdge(o, 'framing');
  this.visitEdge(o, 'name');
};

Dot.prototype.visitRelNodesExists = 
Dot.prototype.visitRelNodesMin = 
Dot.prototype.visitRelNodesMax = 
Dot.prototype.visitRelNodesAvg = 
Dot.prototype.visitRelNodesSum = function(o) {
  this.visitEdge(o, 'expressions');
  this.visitEdge(o, 'distinct');
  this.visitEdge(o, 'alias');
};

Dot.prototype.visitRelNodesExtract = function(o) {
  this.visitEdge(o, 'expressions');
  this.visitEdge(o, 'alias');
};

Dot.prototype.visitRelNamedFunction = function(o) {
  this.visitEdge(o, 'name');
  this.visitEdge(o, 'expressions');
  this.visitEdge(o, 'distinct');
  this.visitEdge(o, 'alias');
};

Dot.prototype.visitRelNodesInsertStatement = function(o) {
  this.visitEdge(o, 'relation');
  this.visitEdge(o, 'columns');
  this.visitEdge(o, 'values');
};

Dot.prototype.visitRelNodesSelectCore = function(o) {
  this.visitEdge(o, 'source');
  this.visitEdge(o, 'projections');
  this.visitEdge(o, 'wheres');
  this.visitEdge(o, 'windows');
};

Dot.prototype.visitRelNodesSelectStatement = function(o) {
  this.visitEdge(o, 'cores');
  this.visitEdge(o, 'limit');
  this.visitEdge(o, 'orders');
  this.visitEdge(o, 'offset');
};

Dot.prototype.visitRelNodesUpdateStatement = function(o) {
  this.visitEdge(o, 'relation');
  this.visitEdge(o, 'wheres');
  this.visitEdge(o, 'values');
};

Dot.prototype.visitRelTable = function(o) {
  this.visitEdge(o, 'name');
};

Dot.prototype.visitRelAttribute =
Dot.prototype.visitRelAttributesInteger =
Dot.prototype.visitRelAttributesFloat =
Dot.prototype.visitRelAttributesString =
Dot.prototype.visitRelAttributesTime =
Dot.prototype.visitRelAttributesBoolean =
Dot.prototype.visitRelAttributesAttribute = function(o) {
  this.visitEdge(o, 'relation');
  this.visitEdge(o, 'name');
};

Dot.prototype.visitRelNodesAnd = function(o) {
  return u.each(o.children, function(x, i) {
    return this.edge(i, this.visit.bind(this));
  }, this);
};

Dot.prototype.visitRelNodesAs =
Dot.prototype.visitRelNodesAssignment =
Dot.prototype.visitRelNodesBetween =
Dot.prototype.visitRelNodesDoesNotMatch =
Dot.prototype.visitRelNodesEquality =
Dot.prototype.visitRelNodesGreaterThan =
Dot.prototype.visitRelNodesGreaterThanOrEqual =
Dot.prototype.visitRelNodesIn =
Dot.prototype.visitRelNodesJoinSource =
Dot.prototype.visitRelNodesLessThan =
Dot.prototype.visitRelNodesLessThanOrEqual =
Dot.prototype.visitRelNodesMatches =
Dot.prototype.visitRelNodesNotEqual =
Dot.prototype.visitRelNodesNotIn =
Dot.prototype.visitRelNodesOr =
Dot.prototype.visitRelNodesOver = function(o) {
  this.visitEdge(o, 'left');
  this.visitEdge(o, 'right');
};

Dot.prototype.visitString = function(o) {
  u.last(this.nodeStack).fields.push(o);
};

Dot.prototype.visitTime = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitDate = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitDateTime = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitNullClass = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitTrueClass = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitFalseClass = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitRelSqlLiteral = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitInteger = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitFloat = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitRelNodesSqlLiteral = function(o) {
  return this.visitString(o);
};

Dot.prototype.visitHash = function(o) {
  return u(o).each((function(_this) {
    return function(value, key, index) {
      return _this.edge({
        key: value
      }, function() {
        return _this.visit({
          key: value
        });
      });
    };
  })(this));
};

Dot.prototype.visitArray = function(o) {
  return u(o).each((function(_this) {
    return function(x, i) {
      return _this.edge(i, function(x) {
        return visit(x);
      });
    };
  })(this));
};

Dot.prototype.visitEdge = function(o, method) {
  return this.edge(method, (function(_this) {
    return function() {
      return _this.visit(o[method]);
    };
  })(this));
};

Dot.prototype.visit = function(o) {
  var node = this.seen[o.object];
  if (node) {
    this.edgeStack.last.to = node;
    return;
  }
  
  node = new Node(o.constructor.name, o);
  this.seen[node.id] = node;
  this.nodes.push(node);
  return withNode((function(_this) {
    return function(node) {
      return _this["super"](o);
    };
  })(this));
};

Dot.prototype.edge = function(name, callback) {
  var edge;
  edge = new Edge(name, u(this.nodeStack).last());
  this.edgeStack.push(edge);
  this.edges.push(edge);
  callback();
  return this.edgeStack.pop();
};

Dot.prototype.withNode = function(node, callback) {
  var edge;
  if (edge = u(this.edgeStack).last()) {
    edge.to = node;
  }
  this.nodeStack.push(node);
  callback();
  return this.nodeStack.pop();
};

Dot.prototype.quote = function(string) {
  return string.toString().replace(/\"/g, "\"");
};

Dot.prototype.toDot = function() {
  return "digraph \"ARel\" {\nnode [width=0.375,height=0.25,shape=record];\n" + (u(this.nodes).map((function(_this) {
    return function(node) {
      var label;
      label = "<f0>" + node.name;
      u(node.fields).each(function(field, i) {
        return label.push("|<f" + (i + 1) + ">" + (_this.quote(field)));
      });
      return "" + node.id + " [label=\"" + label + "\"];";
    };
  })(this))).join("\n") + "\n" + u(this.edges).map((function(edge) {
    return "" + edge.from.id + " -> " + edge.to.id + " [label=\"" + edge.name + "\"];";
  }).join("\n") + "\n}");
};
