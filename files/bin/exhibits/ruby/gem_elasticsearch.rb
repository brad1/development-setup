require 'elasticsearch'

settings = {
  port: '20079',
  user: 'kibana',
  password: 'secure',
  scheme: 'https'
}

begin
  $client = Elasticsearch::Client.new hosts:[ 
        settings.merge(host: 'iad1.objectrocket.com')
      ], log: true, retry_on_failure: true
rescue => e
  puts "Error: #{e}"
end

response = $client.search q: 'booting'
response = $client.search type: 'stats'
puts response['hits']['hits']
