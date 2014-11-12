"use strict";

module.exports = Bind;

var u = require('underscore');
var BindParam = require('../nodes/bind-param');

function Bind() {
  this.value = [];
}

Bind.prototype.append = function(str) {
  this.value.push(str);
  return this;
};

Bind.prototype.addBind = function(bind) {
  this.value.push(bind);
  return this;
};

Bind.prototype.substituteBinds = function(bvs) {
  bvs = bvs.slice(0);
  return u.map(this.value, function(val) {
    if (val.constructor === BindParam) {
      return bvs.shift();
    } else {
      return val;
    }
  });
};

Bind.prototype.compile = function(bvs) {
  return this.substituteBinds(bvs).join('');
};
