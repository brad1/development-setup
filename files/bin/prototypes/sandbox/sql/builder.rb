require 'sqlite3'

def database_create(name)
  db = nil
  begin
    `rm #{name}`
    `echo ".tables\n.exit\n" | sqlite3 #{name}`
    db = SQLite3::Database.new name
  rescue SQLite3::Exception => e
    raise e
  end
  return db
end

def query(db,search_string)
  puts " --------- #{search_string} ------------ "
  stm = db.prepare(search_string)
  rows = stm.execute
  rows.each do |row|
    puts row.to_s
  end
  puts ''
  puts ''
end


class Database

  def initialize(name)
    @db_actual = database_create(name)
  end

  def execute(statement)
    return DbExecution.new(self, statement)
  end

  def execute_raw(statement)
    @db_actual.execute(statement)
  end

  def prepare(statement)
    @db_actual.prepare(statement)
  end
end

class DbExecution
 
  def initialize(db, statement)
    @original_statement = statement
    @statements = []
    @var_name = 'null' 
    @database = db
  end

  def for(values_by_var_name)
    keys = values_by_var_name.keys

    size1 = values_by_var_name[keys[0]].size

    keys.each do |key|
      raise "wrong size" unless values_by_var_name[key].size.eql? size1
    end

    # queue up queries for each item in list
    # execute one at a time until rollback is supported.
    values_by_var_name[keys[0]].size.times do |index|
      new_statement = @original_statement
      values_by_var_name.each do |var_name,values|
        new_statement.gsub!(var_name, values[index].to_s) 
      end
      @statements << new_statement
    end
    return self
  end

  def finish
    @statements.each do |statement|
      @database.execute_raw(statement)
    end
  end
end
