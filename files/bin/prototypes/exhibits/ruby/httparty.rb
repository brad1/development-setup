require 'httparty'

class Api
  include HTTParty
  base_uri 'https://site.com:20079'
  basic_auth 'secure', 'secure'

  def test
    body = <<-EOH
    {
      "query": { "match": { "pid": 8668 } }
    }
    EOH
    puts self.class.post("/_search?pretty", :body => body)
  end
end

Api.new.test
