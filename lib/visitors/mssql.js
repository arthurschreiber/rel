"use strict";

module.exports = MSSQL;

var util = require('util');

var Nodes = require('../nodes');
var ToSql = require('./to-sql');

function RowNumber(children) {
  this.children = children;
}

function MSSQL() {
  MSSQL.super_.apply(this, arguments);
}

util.inherits(MSSQL, ToSql);

MSSQL.prototype.visitRelNodesRowNumber = function(o, collector) {
  collector.append("ROW_NUMBER() OVER (ORDER BY ");

  if (o.children && o.children.length) {
    collector = this.injectJoin(o.children, collector, ", ");
  } else {
    collector.append("(SELECT 0)");
  }

  return collector.append(") as _row_num");
};

MSSQL.prototype.visitRelNodesSelectStatement = function(o, collector) {
  if (!o.limit && !o.offset) {
    return MSSQL.super_.prototype.visitRelNodesSelectStatement.call(this, o, collector);
  }

  var i, len, coreOrderBy, isSelectCount = false, core;

  for (i = 0, len = o.cores.length; i < len; i++) {
    core = o.cores[i];
    coreOrderBy = this.rowNumLiteral(this.determineOrderBy(o.orders, core));

    if (this.isSelectCount(core)) {
      core.projections = [coreOrderBy];
      isSelectCount = true;
    } else {
      core.projections.push(coreOrderBy);
    }
  }

  if (isSelectCount) {
    collector.append("SELECT COUNT(1) as count_id FROM (");
  }

  collector.append("SELECT _t.* FROM (");
  for (i = 0, len = o.cores.length; i < len; i++) {
    collector = this.visit(o.cores[i], collector);
  }
  collector.append(") as _t WHERE " + (this.getOffsetLimitClause(o)));

  if (isSelectCount) {
    collector.append(") AS subquery");
  }

  return collector;
};

MSSQL.prototype.getOffsetLimitClause = function(o) {
  var firstRow = o.offset != null ? o.offset.expr + 1 : 1;
  var lastRow = o.limit != null ? o.limit.expr - 1 + firstRow : null;

  if (lastRow != null) {
    return "_row_num BETWEEN " + firstRow + " AND " + lastRow;
  } else {
    return "_row_num >= " + firstRow;
  }
};

MSSQL.prototype.determineOrderBy = function(orders, x) {
  if (orders && orders.length) {
    return orders;
  } else if (x.groups && x.groups.length) {
    return x.groups;
  } else {
    return [];
  }
};

MSSQL.prototype.rowNumLiteral = function(orderBy) {
  return new RowNumber(orderBy);
};

MSSQL.prototype.isSelectCount = function(x) {
  return x.projections.length === 1 && x.projections[0].constructor === Nodes.Count;
};

MSSQL.prototype.visitRelNodesBindParam = function(o, collector) {
  return collector.addBind(o, function(i) { return "@" + i; });
};
