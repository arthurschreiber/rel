"use strict";

var util = require('util');

var ToSql = require('./to-sql');

util.inherits(WhereSql, ToSql);

function WhereSql() {
  return WhereSql.super_.apply(this, arguments);
}

WhereSql.prototype.visitRelNodesSelectCore = function(o, collector) {
  collector.append("WHERE ");
  return this.injectJoin(o.wheres, collector, " AND ");
};
