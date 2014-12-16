"use strict";

var u = require('underscore');

var Nodes = require('./nodes');

u.extend(module.exports, {
  count: function(distinct) {
    if (distinct == null) {
      distinct = false;
    }
    return new Nodes.Count([this], distinct);
  },
  sum: function() {
    return new Nodes.Sum([this]);
  },
  maximum: function() {
    return new Nodes.Max([this]);
  },
  minimum: function() {
    return new Nodes.Min([this]);
  },
  average: function() {
    return new Nodes.Avg([this]);
  }
});
