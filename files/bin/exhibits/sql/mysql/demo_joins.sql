CREATE DATABASE IF NOT EXISTS example;
use example;

DROP TABLE IF EXISTS sep;
CREATE TABLE sep (
  comment VARCHAR(30)
);

INSERT INTO sep VALUES ('left join a to b');
INSERT INTO sep VALUES ('left join a to c');
INSERT INTO sep VALUES ('right join a to b');
INSERT INTO sep VALUES ('right join a to c');
INSERT INTO sep VALUES ('left join b to a');
INSERT INTO sep VALUES ('left join c to a');
INSERT INTO sep VALUES ('inner join a to b');
INSERT INTO sep VALUES ('inner join a to c');
INSERT INTO sep VALUES ('inner join a to b AND a to c');

-- left join setup
DROP TABLE IF EXISTS a1;
DROP TABLE IF EXISTS a2;
CREATE TABLE a1 (
  a VARCHAR(20)
);
CREATE TABLE a2 (
  b VARCHAR(20),
  c VARCHAR(20)
);
INSERT INTO a1 values ('match'), ('asdf');
INSERT INTO a2 values ('match', 'match'), ('nomatch', 'match'), ('match', 'nomatch'), ('match', NULL), (NULL, 'match');
-- ---------------------------------


--   shows all entries from a1 at least once, alongside each match from a2
SELECT * from sep where comment = 'left join a to b';
SELECT * FROM a1 LEFT JOIN (a2) ON (a1.a = a2.b);

SELECT * from sep where comment = 'left join a to c';
SELECT * FROM a1 LEFT JOIN (a2) ON (a1.a = a2.c);

--   shows all entries from a2 at least once, alongside each match from a1
SELECT * from sep where comment = 'right join a to b';
SELECT * FROM a1 RIGHT JOIN (a2) ON (a1.a = a2.b);

SELECT * from sep where comment = 'right join a to c';
SELECT * FROM a1 RIGHT JOIN (a2) ON (a1.a = a2.c);

-- equivalent join example
--  query is identical to the right join above, but displays columns from a2 first 
SELECT * from sep where comment = 'left join b to a';
SELECT * FROM a2 LEFT JOIN (a1) ON (a1.a = a2.b);

SELECT * from sep where comment = 'left join c to a';
SELECT * FROM a2 LEFT JOIN (a1) ON (a1.a = a2.c);

-- SELECT <column_list> just slices columns out of the query above

select * from sep where comment = 'inner join a to b';
SELECT * FROM a1 INNER JOIN (a2) ON (a1.a = a2.b); -- notice that NULL for the columns in 'ON' clause not returned 

select * from sep where comment = 'inner join a to c';
SELECT * FROM a1 INNER JOIN (a2) ON (a1.a = a2.c);

select * from sep where comment = 'inner join a to b AND a to c';
SELECT * FROM a1 INNER JOIN (a2) ON (a1.a = a2.b AND a1.a = a2.c); -- notice that if no row exists such that a2.b = a2.c, you get no results.

-- select * from (values ('asdf')) separator
















