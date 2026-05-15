module Components
  class MySql

    def initialize(dbname='brad')
      ensure_db_is_present(dbname)
    end

    def get(name)
      # should return id, type, and completed yes/no
      `mysql --login-path=developer_login_path brad -e "select added, itemname, seen, completed from items where itemname = '#{name}'"`
    end

    def list(seen, completed)
      `mysql --login-path=developer_login_path brad -e "select * from items where seen=#{seen} AND completed=#{completed}"` 
    end

    def list_all
      `mysql --login-path=developer_login_path brad -e "select * from items "` 
    end

    def put(name, seen, completed)
      `mysql --login-path=developer_login_path brad -e "update items set seen=#{seen}, completed=#{completed} where itemname='#{name}'"` 
    end

    def delete(name)
      `mysql --login-path=developer_login_path brad -e "delete from items where itemname = '#{name}'"`
    end

    def post(id, type, data)
      `mysql --login-path=developer_login_path brad -e "insert into items values (null, curtime(), '#{id}', '#{type}', '#{data}', 0, null)"` 
    end

    def test(name)
      `mysql --login-path=developer_login_path brad -e "insert into items values (null, curtime(), '#{name}', 'itemtest', 'itemtest', false, NULL)"`
    end

    def drop_database(name='brad')
      `mysql --login-path=developer_login_path #{name} -e "drop database #{name}"`
    end

    private

    def ensure_db_is_present(name)
      #return true
      out = `mysql --login-path=developer_login_path -e "show databases"`
      unless out.to_s.include?(name)
        `mysql --login-path=developer_login_path -e "create database #{name}"`
        `mysql --login-path=developer_login_path #{name} -e "create table items (id mediumint not null auto_increment, added DATE not null, itemname varchar(50), itemtype varchar(20) NOT NULL, data varchar(50) not null, seen BOOL not null, completed DATE, primary key (id) )"`
      end
    end

  end
end
