-- basic sql demo, runnable snippets
-- [Wed Mar  1 06:31:11 2017] 

-- advanced type info
-- https://dev.mysql.com/doc/refman/5.7/en/numeric-type-overview.html
-- https://dev.mysql.com/doc/refman/5.7/en/date-and-time-type-overview.html
-- https://dev.mysql.com/doc/refman/5.7/en/string-type-overview.html

-- ubuntu 16.0.4 complains about date 0000-00-00, arch doesn't 
-- auto_start_id added, works on ubuntu
-- Thu Jul 13 22:26:46 EDT 2017

CREATE DATABASE IF NOT EXISTS example;
use example;

DROP TABLE IF EXISTS sep;
CREATE TABLE sep (
  comment VARCHAR(30)
);

INSERT INTO sep VALUES ('--------------');

DROP TABLE IF EXISTS my_table; 
CREATE TABLE my_table (
  id MEDIUMINT NOT NULL AUTO_INCREMENT,
  row_comment VARCHAR(20) NOT NULL,
  string VARCHAR(20), 
  ch CHAR(1), 
  day DATE,
  b  BIT,
  t TINYINT UNSIGNED ZEROFILL,
  boo BOOL,                                -- same as BOOLEAN, TINYINT(1)
  ts TIMESTAMP,
  PRIMARY KEY (id)
);
insert into my_table values (null, 'auto_start_id', 'as', 'a', DATE(0), 1, 2, TRUE, TIMESTAMP('1970-01-01 00:00:01.000000'));
insert into my_table values (5, 'custom_start_id', 'as', 'a', DATE(0), 1, 2, TRUE, TIMESTAMP('1970-01-01 00:00:01.000000'));
insert into my_table (row_comment, string, ch, day) values ('non-null ', 'as', 'a', DATE(0) );
insert into my_table (row_comment, string, ch, day) values ('today    ', NULL, 'b', CURDATE() );
insert into my_table (row_comment, string, ch, day) values ('time now ', NULL, 'c', CURTIME() ); -- "same thing, converts to date"
insert into my_table (row_comment, string, ch, day) values ('hardcoded', NULL, 'd', DATE('2005-01-01') );
insert into my_table (row_comment, string, ch, day) values ('hardcoded', NULL, 'e', DATE('2006-01-01') );
insert into my_table (row_comment, string, ch, day) values ('hardcoded', NULL, 'f', DATE('2007-01-01') );


select * from my_table;
select * from separater;

-- select * from my_table where string IS NOT NULL;
-- select * from my_table where day < DATE('2007-01-01');
-- select * from my_table where ch > 'd';
