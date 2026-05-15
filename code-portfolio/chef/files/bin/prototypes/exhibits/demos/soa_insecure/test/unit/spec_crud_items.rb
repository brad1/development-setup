require 'minitest/autorun'
require 'minitest/mock'
require 'services/crud_items'
require 'components/mysql'

module Minitest::Assertions
  def assert_nothing_raised(*)
    yield
  end
end

class SpecCrudItems < MiniTest::Test

  def test_crud_items_new
    crud_items = Services::CrudItems.new     
    refute_nil crud_items
  end

  def test_get_one
    mock_orm = Minitest::Mock.new
    mock_orm.expect(:get, "field\nvalue", ['id'] )
    Components::MySql.stub(:new, mock_orm) do
      crud_items = Services::CrudItems.new    
      assert_equal("{\"field\":\"value\"}", crud_items.get('id').gsub(/\s+/, ""))
    end
  end

  def test_list_empty
    mock_orm = Minitest::Mock.new
    mock_orm.expect(:list, "", [0,0] )
    Components::MySql.stub(:new, mock_orm) do
      crud_items = Services::CrudItems.new    
      assert_equal("[]", crud_items.list.gsub(/\s+/, ""))
    end
  end

  def test_list_all
    mock_orm = Minitest::Mock.new
    mock_orm.expect(:list_all, "", [] )
    Components::MySql.stub(:new, mock_orm) do
      crud_items = Services::CrudItems.new    
      assert_equal("[]", crud_items.list_all.gsub(/\s+/, ""))
    end
  end

  def test_no_crash
    mock_orm = Minitest::Mock.new
    mock_orm.expect(:put, "", [0,0,0] )
    mock_orm.expect(:post, "", [0,0,0] )
    mock_orm.expect(:delete, "", [0] )
    mock_orm.expect(:test, "", [0])
    Components::MySql.stub(:new, mock_orm) do
      crud_items = Services::CrudItems.new    
      assert_nothing_raised do
        crud_items.put(0,0,0)
        crud_items.post(0,0,0)
        crud_items.delete(0)
        crud_items.test(0)
      end
    end
  end

  def test_crud_items_stub
    Services::CrudItems.stub(:new, nil) do
      crud_items = Services::CrudItems.new     
# TODO does stubbing work if we call outside code?
      assert_nil crud_items
    end
  end

end
