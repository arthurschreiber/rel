"use strict";

module.exports = ToSql;

var u = require('underscore');
var util = require('util');

var Reduce = require('./reduce');
var Nodes = require('../nodes');
var SqlLiteral = require('../nodes/sql-literal');
var Attributes = require('../attributes');

function ToSql(engine) {
  ToSql.super_.constructor.call(this);
  this.engine = engine;
}

util.inherits(ToSql, Reduce);

ToSql.prototype.visitRelNodesDeleteStatement = function(o, collector) {
  collector.append("DELETE FROM ");
  collector = this.visit(o.relation, collector);

  if (o.wheres && o.wheres.length) {
    collector.append(" WHERE ");
    collector = this.injectJoin(o.wheres, collector, " AND ");
  }

  return collector;
};

ToSql.prototype.buildSubselect = function(key, o) {
  var core, stmt;
  stmt = new Nodes.SelectStatement();
  core = stmt.cores[0];
  core.froms = o.relation;
  core.wheres = o.wheres;
  core.projections = [key];
  stmt.limit = o.limit;
  stmt.orders = o.orders;
  return stmt;
};

ToSql.prototype.visitRelNodesUpdateStatement = function(o, collector) {
  var wheres;

  if (!(o.orders && o.orders.length) && o.limit == null) {
    wheres = o.wheres;
  } else {
    wheres = [ new Nodes.In(o.key, [ this.buildSubselect(o.key, o) ]) ];
  }

  collector.append("UPDATE ");
  collector = this.visit(o.relation, collector);

  if (o.values && o.values.length) {
    collector.append(" SET ");
    collector = this.injectJoin(o.values, collector, ", ");
  }

  if (wheres.length) {
    collector.append(" WHERE ");
    collector = this.injectJoin(wheres, collector, " AND ");
  }

  return collector;
};

ToSql.prototype.visitRelNodesInsertStatement = function(o, collector) {
  collector.append("INSERT INTO ");
  collector = this.visit(o.relation, collector);

  if (o.columns && o.columns.length) {
    collector.append(" (");
    collector.append(u.map(o.columns, function(x) {
      return this.quoteColumnName(x.name);
    }.bind(this)).join(', '));
    collector.append(")");
  }

  if (o.values) {
    collector.append(" ");
    collector = this.visit(o.values, collector);
  } else if (o.select) {
    collector.append(" ");
    collector = this.visit(o.select, collector);
  }

  return collector;
};

ToSql.prototype.visitRelNodesExists = function(o, collector) {
  collector.append("EXISTS (");
  collector = this.visit(o.expressions, collector);
  collector.append(")");

  if (o.alias) {
    collector.append(" AS ");
    collector = this.visit(o.alias, collector);
  }

  return collector;
};

ToSql.prototype.columnFor = function(attr) {
  if (attr == null) {
    return;
  }

  var name = attr.name.toString();
  var table = attr.relation.name;

  return this.engine.columnFor(table, name);
};

ToSql.prototype.visitRelNodesValues = function(o, collector) {
  collector.append("VALUES (");

  var expressions = o.expressions;
  var columns = o.columns;

  var last = expressions.length - 1;

  for (var i = 0, len = expressions.length, expr, attr; i < len; i++) {
    expr = expressions[i];
    attr = columns[i];

    if (expr && (expr.constructor === SqlLiteral || expr.constructor === Nodes.BindParam)) {
      collector = this.visit(expr, collector);
    } else {
      collector.append(this.quote(expr, attr && this.columnFor(attr)));
    }

    if (i !== last) {
      collector.append(", ");
    }
  }

  return collector.append(")");
};

ToSql.prototype.visitRelNodesSelectStatement = function(o, collector) {
  if (o.with != null) {
    collector = this.visit(o.with, collector);
    collector.append(" ");
  }

  for (var i = 0, len = o.cores.length; i < len; i++) {
    collector = this.visit(o.cores[i], collector);
  }

  if (o.orders && o.orders.length) {
    collector.append(" ORDER BY ");
    collector = this.injectJoin(o.orders, collector, ", ");
  }

  collector = this.maybeVisit(o.limit, collector);
  collector = this.maybeVisit(o.offset, collector);
  collector = this.maybeVisit(o.lock, collector);

  return collector;
};

ToSql.prototype.visitRelNodesSelectCore = function(o, collector) {
  collector.append("SELECT");

  collector = this.maybeVisit(o.top, collector);
  collector = this.maybeVisit(o.setQuantifier, collector);

  if (o.projections && o.projections.length) {
    collector.append(" ");
    collector = this.injectJoin(o.projections, collector, ', ');
  }

  if (!o.source.isEmpty()) {
    collector.append(" FROM ");
    collector = this.visit(o.source, collector);
  }

  if (o.wheres && o.wheres.length) {
    collector.append(" WHERE ");
    collector = this.injectJoin(o.wheres, collector, " AND ");
  }

  if (o.groups && o.groups.length) {
    collector.append(" GROUP BY ");
    collector = this.injectJoin(o.groups, collector, ", ");
  }

  collector = this.maybeVisit(o.having, collector);

  return collector;
};

ToSql.prototype.visitRelNodesWith = function(o, collector) {
  collector.append("WITH ");
  return this.injectJoin(o.children, collector, ', ');
};

ToSql.prototype.visitRelNodesWithRecursive = function(o, collector) {
  collector.append("WITH RECURSIVE ");
  return this.injectJoin(o.children, collector, ', ');
};

ToSql.prototype.visitRelNodesUnion = function(o, collector) {
  collector.append("(");
  collector = this.visit(o.left, collector);
  collector.append(" UNION ");
  collector = this.visit(o.right, collector);
  return collector.append(")");
};

ToSql.prototype.visitRelNodesUnionAll = function(o, collector) {
  collector.append("(");
  collector = this.visit(o.left, collector);
  collector.append(" UNION ALL ");
  collector = this.visit(o.right, collector);
  return collector.append(")");
};

ToSql.prototype.visitRelNodesIntersect = function(o, collector) {
  collector.append("(");
  collector = this.visit(o.left, collector);
  collector.append(" INTERSECT ");
  collector = this.visit(o.right, collector);
  return collector.append(")");
};

ToSql.prototype.visitRelNodesExcept = function(o, collector) {
  collector.append("(");
  collector = this.visit(o.left, collector);
  collector.append(" EXCEPT ");
  collector = this.visit(o.right, collector);
  return collector.append(")");
};

ToSql.prototype.visitRelNodesHaving = function(o, collector) {
  collector.append("HAVING ");
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesOffset = function(o, collector) {
  collector.append("OFFSET ");
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesLimit = function(o, collector) {
  collector.append("LIMIT ");
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesTop = function(o, collector) {
  return collector;
};

ToSql.prototype.visitRelNodesLock = function(o, collector) {
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesGrouping = function(o, collector) {
  if (o.expr instanceof Nodes.Grouping) {
    return this.visit(o.expr, collector);
  } else {
    collector.append("(");
    collector = this.visit(o.expr, collector);
    return collector.append(")");
  }
};

ToSql.prototype.visitRelNodesSelectManager = function(o, collector) {
  collector.append("(");
  collector = this.visit(o.ast, collector);
  return collector.append(")");
};

ToSql.prototype.visitRelNodesAscending = function(o, collector) {
  collector = this.visit(o.expr, collector);
  return collector.append(" ASC");
};

ToSql.prototype.visitRelNodesDescending = function(o, collector) {
  collector = this.visit(o.expr, collector);
  return collector.append(" DESC");
};

ToSql.prototype.visitRelNodesGroup = function(o, collector) {
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesNamedFunction = function(o, collector) {
  return this.aggregate(o.name, o, collector);
};

ToSql.prototype.visitRelNodesCount = function(o, collector) {
  return this.aggregate("COUNT", o, collector);
};

ToSql.prototype.visitRelNodesSum = function(o, collector) {
  return this.aggregate("SUM", o, collector);
};

ToSql.prototype.visitRelNodesMax = function(o, collector) {
  return this.aggregate("MAX", o, collector);
};

ToSql.prototype.visitRelNodesMin = function(o, collector) {
  return this.aggregate("MIN", o, collector);
};

ToSql.prototype.visitRelNodesAvg = function(o, collector) {
  return this.aggregate("AVG", o, collector);
};

ToSql.prototype.visitRelNodesTableAlias = function(o, collector) {
  collector = this.visit(o.relation, collector);
  return collector.append(" " + this.quoteTableName(o.name.toString()));
};

ToSql.prototype.visitRelNodesBetween = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" BETWEEN ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesGreaterThan = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" > ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesGreaterThanOrEqual = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" >= ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesLessThan = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" < ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesLessThanOrEqual = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" <= ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesMatches = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" LIKE ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesDoesNotMatch = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" NOT LIKE ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesJoinSource = function(o, collector) {
  if (o.left != null) {
    collector = this.visit(o.left, collector);
  }

  if (o.right && o.right.length) {
    if (o.left != null) {
      collector.append(" ");
    }
    collector = this.injectJoin(o.right, collector, " ");
  }

  return collector;
};

ToSql.prototype.visitRelNodesStringJoin = function(o, collector) {
  return this.visit(o.left, collector);
};

ToSql.prototype.visitRelNodesFullOuterJoin = function(o, collector) {
  return this._visitOuterJoin(o, collector, 'FULL');
};

ToSql.prototype.visitRelNodesOuterJoin = function(o, collector) {
  return this._visitOuterJoin(o, collector, 'LEFT');
};

ToSql.prototype.visitRelNodesRightOuterJoin = function(o, collector) {
  return this._visitOuterJoin(o, collector, 'RIGHT');
};

ToSql.prototype.visitRelNodesInnerJoin = function(o, collector) {
  collector.append("INNER JOIN ");
  collector = this.visit(o.left, collector);
  if (o.right != null) {
    collector.append(" ");
    return this.visit(o.right, collector);
  }
};

ToSql.prototype.visitRelNodesOn = function(o, collector) {
  collector.append("ON ");
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesNot = function(o, collector) {
  collector.append("NOT (");
  collector = this.visit(o.expr, collector);
  return collector.append(")");
};

ToSql.prototype.visitRelNodesTable = function(o, collector) {
  if (o.tableAlias != null) {
    return collector.append(this.quoteTableName(o.name) + " " + this.quoteTableName(o.tableAlias));
  } else {
    return collector.append(this.quoteTableName(o.name));
  }
};

ToSql.prototype.visitRelNodesIn = function(o, collector) {
  if (u.isArray(o.right) && !o.right.length) {
    return collector.append("1=0");
  } else {
    collector = this.visit(o.left, collector);
    collector.append(" IN (");
    collector = this.visit(o.right, collector);
    return collector.append(")");
  }
};

ToSql.prototype.visitRelNodesNotIn = function(o, collector) {
  if (u.isArray(o.right) && !o.right.length) {
    return collector.append("1=1");
  } else {
    collector = this.visit(o.left, collector);
    collector.append(" NOT IN (");
    collector = this.visit(o.right, collector);
    return collector.append(")");
  }
};

ToSql.prototype.visitRelNodesAnd = function(o, collector) {
  return this.injectJoin(o.children, collector, ' AND ');
};

ToSql.prototype.visitRelNodesOr = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" OR ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesAssignment = function(o, collector) {
  var constructor = o.right != null ? o.right.constructor : undefined;
  if (constructor === Nodes.UnqualifiedColumn || constructor === Attributes.Attribute || constructor === Nodes.BindParam) {
    collector = this.visit(o.left, collector);
    collector.append(" = ");
    return this.visit(o.right, collector);
  } else {
    collector = this.visit(o.left, collector);
    return collector.append(" = " + (this.quote(o.right, this.columnFor(o.left))));
  }
};

ToSql.prototype.visitRelNodesEquality = function(o, collector) {
  if (o.right != null) {
    collector = this.visit(o.left, collector);
    collector.append(" = ");
    return this.visit(o.right, collector);
  } else {
    collector = this.visit(o.left, collector);
    return collector.append(" IS NULL");
  }
};

ToSql.prototype.visitRelNodesNotEqual = function(o, collector) {
  if (o.right != null) {
    collector = this.visit(o.left, collector);
    collector.append(" != ");
    return this.visit(o.right, collector);
  } else {
    collector = this.visit(o.left, collector);
    return collector.append(" IS NOT NULL");
  }
};

ToSql.prototype.visitRelNodesAs = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" AS ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesUnqualifiedColumn = function(o, collector) {
  return collector.append(this.quoteColumnName(o.name));
};

ToSql.prototype.visitRelNodesAttribute = function(o, collector) {
  var joinName = (o.relation.tableAlias || o.relation.name).toString();
  return collector.append(this.quoteTableName(joinName) + "." + this.quoteColumnName(o.name));
};

ToSql.prototype.visitRelNodesAttrInteger = function(o, collector) {
  return this.visitRelNodesAttribute(o, collector);
};

ToSql.prototype.visitRelNodesAttrFloat = function(o, collector) {
  return this.visitRelNodesAttribute(o, collector);
};

ToSql.prototype.visitRelNodesAttrString = function(o, collector) {
  return this.visitRelNodesAttribute(o, collector);
};

ToSql.prototype.visitRelNodesAttrTime = function(o, collector) {
  return this.visitRelNodesAttribute(o, collector);
};

ToSql.prototype.visitRelNodesAttrBoolean = function(o, collector) {
  return this.visitRelNodesAttribute(o, collector);
};

ToSql.prototype.literal = function(o, collector) {
  return collector.append(o);
};

ToSql.prototype.visitRelNodesBindParam = function(o, collector) {
  return collector.addBind(o, function() { return "?"; });
};

ToSql.prototype.visitRelNodesSqlLiteral = function(o, collector) {
  return this.literal(o, collector);
};

ToSql.prototype.visitRelNodesNumber = function(o, collector) {
  return this.literal(o, collector);
};

ToSql.prototype.quoted = function(o) {
  return this.quote(o, this.last_column);
};

ToSql.prototype.unsupported = function(o, collector) {
  throw new Error("unsupported " + o);
};

ToSql.prototype.visitRelNodesString = function(o, collector) {
  return collector.append(this.quoted(o));
};

ToSql.prototype.visitRelNodesDate = function(o, collector) {
  return collector.append(this.quoted(o));
};

ToSql.prototype.visitRelNodesBoolean = function(o, collector) {
  return collector.append(this.quoted(o));
};

ToSql.prototype.visitRelNodesArray = function(o, collector) {
  return this.injectJoin(o, collector, ', ');
};

ToSql.prototype.quote = function(value, column) {
  if (value != null && value.constructor === Nodes.SqlLiteral) {
    return value;
  } else {
    return this.engine.quote(value, column);
  }
};

ToSql.prototype.quoteTableName = function(name) {
  if (name != null && name.constructor === Nodes.SqlLiteral) {
    return name;
  } else {
    return this.engine.quoteTableName(name);
  }
};

ToSql.prototype.quoteColumnName = function(name) {
  if (name != null && name.constructor === Nodes.SqlLiteral) {
    return name;
  } else {
    return this.engine.quoteColumnName(name);
  }
};

ToSql.prototype.maybeVisit = function(thing, collector) {
  if (thing != null) {
    collector.append(" ");
    collector = this.visit(thing, collector);
  }

  return collector;
};

ToSql.prototype.injectJoin = function(list, collector, joinStr) {
  for (var i = 0, len = list.length, last = len - 1; i < len; i++) {
    collector = this.visit(list[i], collector);
    if (i !== last) {
      collector.append(joinStr);
    }
  }

  return collector;
};

ToSql.prototype.aggregate = function(name, o, collector) {
  collector.append("" + name + "(");
  if (o.distinct) {
    collector.append('DISTINCT ');
  }
  collector = this.injectJoin(o.expressions, collector, ", ");
  if (o.alias) {
    collector.append(" AS ");
    collector = this.visit(o.alias, collector);
  }
  return collector.append(")");
};

ToSql.prototype.visitRelNodesConstLit = function(o, collector) {
  return this.visit(o.expr, collector);
};

ToSql.prototype.visitRelNodesLike = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" LIKE ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesILike = function(o, collector) {
  collector = this.visit(o.left, collector);
  collector.append(" ILIKE ");
  return this.visit(o.right, collector);
};

ToSql.prototype._visitOuterJoin = function(o, collector, joinType) {
  collector.append("" + joinType + " OUTER JOIN ");
  collector = this.visit(o.left, collector);
  collector.append(" ");
  return this.visit(o.right, collector);
};

ToSql.prototype.visitRelNodesFunctionNode = function(o, collector) {
  collector = this.visit(o.alias, collector);
  collector.append("(");
  for (var i = 0, len = o.expressions.length; i < len; i++) {
    collector = this.visit(o.expressions[i], collector);
  }
  return collector.append(")");
};

ToSql.prototype.visitRelNodesNull = function(o, collector) {
  return collector.append('NULL');
};

ToSql.prototype.visitRelNodesIsNull = function(o, collector) {
  collector = this.visit(o.expr, collector);
  return collector.append(" IS NULL");
};

ToSql.prototype.visitRelNodesNotNull = function(o, collector) {
  collector = this.visit(o.expr, collector);
  return collector.append(" IS NOT NULL");
};
