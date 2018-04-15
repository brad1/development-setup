CREATE DATABASE IF NOT EXISTS example;
use example;

DROP TABLE IF EXISTS sep;
CREATE TABLE sep (
  comment VARCHAR(30)
);

-- left join setup
DROP TABLE IF EXISTS a1;
CREATE TABLE a1 (
  a VARCHAR(20)
);
INSERT INTO a1 values ('BAD'), 
                      ('ASTERISK'),
                      ('dfkj');
-- ---------------------------------


SELECT * FROM a1 where a LIKE '%A%'; 
SELECT * FROM a1 where a LIKE 'A%'; 
SELECT * FROM a1 where a NOT LIKE 'A%'; 
