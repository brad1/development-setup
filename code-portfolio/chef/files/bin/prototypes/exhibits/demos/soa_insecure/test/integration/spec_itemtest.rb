require 'minitest/autorun'
require 'services/crud_items'
require 'components/mysql'
require 'httparty'

module Minitest::Assertions
  def assert_nothing_raised(*)
    yield
  end
end

class SpecItemTest < MiniTest::Test

  def setup
    data = Components::MySql.new
    data.drop_database
  end

  def teardown
    data = Components::MySql.new
    data.drop_database
  end

  def test_itemtest
    # moveme
    code = ''
    while !code.eql? 200
      response = HTTParty.get('http://localhost:4567/items')
      code = response.code
      sleep 1
    end

    HTTParty.post('http://localhost:4567/itemtest', :body => '', :headers => {'Content-Type' => 'application/json'})

    # wait for item to show completed in the database

    crud_items = Services::CrudItems.new 
    items = JSON.parse(crud_items.list_all)

    assert(items.size > 0, 'mymessage')

    seen = false
    completed = false
    tries = 0

    # repeat
    while (!seen or !completed) and tries < 5 do
      items = JSON.parse(crud_items.list_all)
      completed = items.first['completed']
      seen = items.first['seen']
      tries += 1
      sleep 3
    end

    assert seen
    assert completed

  end

end
