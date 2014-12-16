"use strict";

var u = require('underscore');
var util = require('util');

var Attribute = require('./attribute');

function AttrString() {
  return AttrString.super_.apply(this, arguments);
}
util.inherits(AttrString, Attribute);

function AttrTime() {
  return AttrTime.super_.apply(this, arguments);
}
util.inherits(AttrTime, Attribute);

function AttrBoolean() {
  return AttrBoolean.super_.apply(this, arguments);
}
util.inherits(AttrBoolean, Attribute);

function AttrDecimal() {
  return AttrDecimal.super_.apply(this, arguments);
}
util.inherits(AttrDecimal, Attribute);

function AttrFloat() {
  return AttrFloat.super_.apply(this, arguments);
}
util.inherits(AttrFloat, Attribute);

function AttrInteger() {
  return AttrInteger.super_.apply(this, arguments);
}
util.inherits(AttrInteger, Attribute);

function AttrUndefined() {
  return AttrUndefined.super_.apply(this, arguments);
}
util.inherits(AttrUndefined, Attribute);

u.extend(module.exports, {
  Attribute: Attribute,
  AttrString: AttrString,
  AttrTime: AttrTime,
  AttrBoolean: AttrBoolean,
  AttrDecimal: AttrDecimal,
  AttrFloat: AttrFloat,
  AttrInteger: AttrInteger,
  AttrUndefined: AttrUndefined
});
