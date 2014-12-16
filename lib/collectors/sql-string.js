"use strict";

module.exports = SQLString;

function SQLString() {
  this.value = "";
  this.bindIndex = 1;
}

SQLString.prototype.append = function(str) {
  this.value += str;
  return this;
};

SQLString.prototype.addBind = function(bv, callback) {
  return this.append(callback(this.bindIndex++));
};

SQLString.prototype.compile = function(bvs) {
  return this.value;
};
