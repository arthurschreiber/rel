"use strict";

var Nodes = require('./nodes');
var Range = require('./range');
var Table = require('./table');
var Visitors = require('./visitors');
var Collectors = require('./collectors');
var SelectManager = require('./select-manager');
var InsertManager = require('./insert-manager');
var UpdateManager = require('./update-manager');

module.exports.VERSION = require("../package.json").version;

module.exports.sql = function(rawSql) {
  return new Nodes.SqlLiteral(rawSql);
};

module.exports.star = function() {
  return this.sql("*");
};

module.exports.range = function(start, finish) {
  return new Range(start, finish);
};

module.exports.Range = Range;
module.exports.Nodes = Nodes;
module.exports.Table = Table;
module.exports.Visitors = Visitors;
module.exports.Collectors = Collectors;
module.exports.SelectManager = SelectManager;
module.exports.InsertManager = InsertManager;
module.exports.UpdateManager = UpdateManager;
