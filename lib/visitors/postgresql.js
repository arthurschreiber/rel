"use strict";

module.exports = Postgresql;

var util = require("util");

var ToSql = require('./to-sql');

function escapeLiteral(str) {
  var hasBackslash = false;
  var escaped = '\'';

  for(var i = 0; i < str.length; i++) {
    var c = str[i];
    if(c === '\'') {
      escaped += c + c;
    } else if (c === '\\') {
      escaped += c + c;
      hasBackslash = true;
    } else {
      escaped += c;
    }
  }

  escaped += '\'';

  if(hasBackslash === true) {
    escaped = ' E' + escaped;
  }

  return escaped;
}

function Postgresql() {
  Postgresql.super_.constructor.apply(this, arguments);
}

util.inherits(Postgresql, ToSql);

Postgresql.prototype.quote = function(value, column) {
  if (column == null) {
    column = null;
  }
  if (value === null) {
    return 'NULL';
  } else if (value.constructor === Boolean) {
    if (value === true) {
      return "true";
    } else {
      return "false";
    }
  } else if (value.constructor === Date) {
    return this.quote(value.toISOString());
  } else if (value.constructor === Number) {
    return value;
  } else {
    return escapeLiteral(value);
  }
};
