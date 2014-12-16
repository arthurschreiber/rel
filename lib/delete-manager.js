"use strict";

module.exports = DeleteManager;

var util = require('util');

var TreeManager = require('./tree-manager');
var DeleteStatement = require('./nodes/delete-statement');

function DeleteManager() {
  DeleteManager.super_.call(this);
  this.ast = new DeleteStatement();
  this.ctx = this.ast;
}

util.inherits(DeleteManager, TreeManager);

DeleteManager.prototype.from = function(relation) {
  this.ast.relation = relation;
  return this;
};

DeleteManager.prototype.wheres = function(list) {
  return (this.ast.wheres = list);
};
