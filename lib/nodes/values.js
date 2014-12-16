"use strict";

var util = require('util');

var Binary = require('./binary');

util.inherits(Values, Binary);

function Values(exprs, columns) {
  if (columns == null) {
    columns = [];
  }

  Values.super_.call(this, exprs, columns);
}

Object.defineProperty(Values.prototype, 'expressions', {
  get: function() {
    return this.left;
  },

  set: function(value) {
    this.left = value;
  }
});

Object.defineProperty(Values.prototype, 'columns', {
  get: function() {
    return this.right;
  },

  set: function(value) {
    this.right = value;
  }
});

module.exports = Values;
