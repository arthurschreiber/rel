"use strict";

module.exports = InsertManager

var u = require('underscore');
var util = require('util');

var TreeManager = require('./tree-manager');
var InsertStatement = require('./nodes/insert-statement');
var Nodes = require('./nodes');

function InsertManager() {
  InsertManager.super_.call(this);
  this.ast = new InsertStatement();
}

util.inherits(InsertManager, TreeManager);

InsertManager.prototype.createValues = function(values, columns) {
  return new Nodes.Values(values, columns);
};

InsertManager.prototype.columns = function() {
  return this.ast.columns;
};

InsertManager.prototype.values = function(values) {
  if (values != null) {
    this.ast.values = values;
  }

  return this.ast.values;
};

InsertManager.prototype.insert = function(fields) {
  if (u.isEmpty(fields)) {
    return;
  }

  if (fields.constructor === String) {
    this.ast.values = new Nodes.SqlLiteral(fields);
  } else {
    if (!this.ast.relation) {
      this.ast.relation = fields[0][0].relation;
    }

    var values = u.map(fields, function(field) {
      var column = field[0], value = field[1];

      this.ast.columns.push(column);

      return value;
    }.bind(this));

    this.ast.values = this.createValues(values, this.ast.columns);
  }

  return this.ast.values;
};

InsertManager.prototype.into = function(table) {
  this.ast.relation = table;
  return this;
};
