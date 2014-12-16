"use strict";

module.exports = WithRecursive;

var util = require('util');

var With = require('./with');

util.inherits(WithRecursive, With);

function WithRecursive() {
  return WithRecursive.super_.apply(this, arguments);
}
