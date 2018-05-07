require 'sqlite3'
require_relative 'builder.rb'

# Example
#db = Database.new('builder')

#db.execute_raw('create table test_table (c1 varchar(32), c2 varchar(32) )')

#db.execute(%Q{insert into test_table (c1,c2) values ('some_string',_z_)})
#  .with_variable('_z_')
#  .for(["'1'","'2'"])
#  .finish

#rows = db.execute_raw('select * from test_table')
#rows.each do |row|
#  puts row.inspect
#end


def database_setup_001
  db = Database.new 'test.sqlite3'
  db.execute_raw("create table t1 (id integer primary key autoincrement not null unique, t1_col1 varchar(32), t1_col2 varchar(32))")

  db.execute("insert into  t1 (t1_col1,t1_col2) values ('t1_col1_entry_z_','t1_col2_entry_z_')")
    .for('_z_' => [1,2,3])
    .finish

  db.execute_raw("create table t2 (id integer primary key autoincrement not null unique, t2_col1 varchar(32), t2_col2 varchar(32))")
  db.execute_raw("insert into  t2 (t2_col1,t2_col2) values ('t2_col1_entry1','t2_col2_entry1')")

  return db
end

def database_setup_002
  db = Database.new 'test.sqlite3'
  db.execute_raw("create table t1 (id integer primary key autoincrement not null unique, t1_col1 varchar(32), t1_col2 varchar(32))")
  db.execute_raw("insert into  t1 (t1_col1,t1_col2) values ('t1_col1_entry1','t1_col2_entry1')")

  db.execute_raw("create table t2 (id integer primary key autoincrement not null unique, t2_col1 varchar(32), t2_col2 varchar(32))")
  db.execute("insert into  t2 (t2_col1,t2_col2) values ('t2_col1_entry_z_','t2_col2_entry_z_')")
    .for('_z_' => [1,2,3])
    .finish

  return db
end

def database_setup_003
  db = Database.new 'test.sqlite3'
  db.execute_raw("create table t1 (id integer primary key autoincrement not null unique, t1_col1 varchar(32), t1_col2 varchar(32), t1_col3 int)")
  db.execute_raw("create table t2 (id integer primary key autoincrement not null unique, t2_col1 varchar(32), t2_col2 varchar(32))")

  db.execute("insert into  t1 (t1_col1,t1_col2,t1_col3) values ('t1_col1_entry_z_','t1_col2_entry_y_',_x_)")
    .for({
      '_z_' => [1,2,3,4,5],
      '_y_' => [1,2,3,4,1],
      '_x_' => [5,6,7,8,9]
    })
    .finish

  db.execute("insert into  t2 (t2_col1,t2_col2) values ('t2_col1_entry_z_','t2_col2_entry_z_')")
    .for('_z_' => [1,2,3])
    .finish

  return db
end

def main2

  db = database_setup_001()

  puts "Left join shows each row from first table with a match or null row"
  query(db, "select * from t1 left  join t2 on t1.id = t2.id")

  puts "Inner join shows matches only"
  query(db, "select * from t1 inner join t2 on t1.id = t2.id ")

  # Right joins are not currently supported in sqlite :(
  # puts "Right join shows each row from second table with a match or null row"
  # query(db, "select * from t1 right join t2 on t1.id = t2.id")

  puts "Shows only record with id 5 since it is the only id in col3" 
  db = database_setup_003()
  query(db, "select * from t1 as tee_one left join t2 on tee_one.id = t2.id where exists(select 1 from t1 as tee_one2 where tee_one2.t1_col3 = tee_one.id)")
end

main2()
