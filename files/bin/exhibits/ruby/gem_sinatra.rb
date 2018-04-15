require 'sinatra'

# curl -L localhost:4567
get '/' do
  '{}'
end
 
post '/:name' do
  resource = params[:name]
  'response_string'
end
