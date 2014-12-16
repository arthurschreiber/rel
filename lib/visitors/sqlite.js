"use strict";

module.exports = Sqlite;

var util = require("util");

var ToSql = require('./to-sql');

util.inherits(Sqlite, ToSql);

function Sqlite() {
  Sqlite.super_.constructor.apply(this, arguments);
}
