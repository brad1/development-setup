require 'minitest/autorun'
require 'minitest/mock'
require 'services/worker_items'

module Minitest::Assertions
  def assert_nothing_raised(*)
    yield
  end
end

class SpecWorkerItems < MiniTest::Test

  def test_worker_items
    mock_get = Minitest::Mock.new
    mock_get.expect(:get, "", ["http://localhost:4567/items", :body => {'seen'=>1,'completed'=>1}.to_json] )

    # needed because of 5 second worker loop, find a better solution
    mock_get.expect(:parsed_response, '{"itemtype":"itemtest"}')
    mock_get.expect(:parsed_response, '{}')
    mock_get.expect(:parsed_response, '{}')
    mock_get.expect(:parsed_response, '{}')
    mock_get.expect(:parsed_response, '{}')
    mock_get.expect(:parsed_response, '{}')
    mock_get.expect(:parsed_response, '{}')
    # TODO this suck
    HTTParty.stub(:get, mock_get) do
      HTTParty.stub(:put, "") do
        HTTParty.stub(:delete, "") do
          worker_items = Services::WorkerItems.new    
          assert_nothing_raised do
            worker_items.run(5)
          end
        end
      end
    end
  end


end
