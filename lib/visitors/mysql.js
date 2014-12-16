"use strict";

module.exports = Mysql;

var util = require('util');

var ToSql = require('./to-sql');

function Mysql() {
  Mysql.super_.constructor.apply(this, arguments);
}

util.inherits(Mysql, ToSql);
