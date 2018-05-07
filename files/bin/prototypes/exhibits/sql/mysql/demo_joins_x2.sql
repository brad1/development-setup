CREATE DATABASE IF NOT EXISTS example;
use example;

DROP TABLE IF EXISTS sep;
CREATE TABLE sep (
  comment VARCHAR(30)
);

INSERT INTO sep VALUES ('left join a to b');

DROP TABLE IF EXISTS a1;
DROP TABLE IF EXISTS a2;
DROP TABLE IF EXISTS a3;
CREATE TABLE a1 (
  a VARCHAR(20)
);
CREATE TABLE a2 (
  b VARCHAR(20),
  c VARCHAR(20)
);
CREATE TABLE a3 (
  d VARCHAR(20),
  e VARCHAR(20)
);
INSERT INTO a1 values ('match'), ('asdf');
INSERT INTO a2 values ('match',''); 
INSERT INTO a3 values ('match','');
-- ---------------------------------


--   shows all entries from a1 at least once, alongside each match from a2
SELECT * from sep where comment = 'left join a to b';
SELECT * FROM a1 LEFT JOIN (a2,a3) ON (a1.a = a2.b AND a1.a = a3.d);
-- expand on these


-- TODO explain this one
-- SELECT * FROM a1 LEFT JOIN (a2,a3) ON (a1.a = a2.b);

