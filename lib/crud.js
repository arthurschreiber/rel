"use strict";

var u = require('underscore');

var InsertManager = require('./insert-manager');
var UpdateManager = require('./update-manager');
var DeleteManager = require('./delete-manager');

var SqlLiteral = require('./nodes/sql-literal');

u.extend(module.exports, {
  compileInsert: function(values) {
    var im = this.createInsert();
    im.insert(values);
    return im;
  },

  createInsert: function() {
    return new InsertManager();
  },

  compileDelete: function() {
    var dm = new DeleteManager();
    dm.wheres(this.ctx.wheres);
    dm.from(this.ctx.froms);
    return dm;
  },

  compileUpdate: function(values) {
    var um = new UpdateManager();
    var relation = values.constructor === SqlLiteral ? this.ctx.from : values[0][0].relation;
    um.table(relation);
    um.set(values);
    if (this.ast.limit != null) {
      um.take(this.ast.limit.expr);
    }
    um.order(this.ast.orders);
    um.wheres = this.ctx.wheres;
    return um;
  }
});
