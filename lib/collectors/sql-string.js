"use strict";

module.exports = SQLString;

function SQLString() {
  this.value = "";
}

SQLString.prototype.append = function(str) {
  this.value += str;
  return this;
};

SQLString.prototype.addBind = function(bv) {
  return this.append(bv);
};

SQLString.prototype.compile = function(bvs) {
  return this.value;
};
