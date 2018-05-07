# readme
#
# this api should be responsible for: 
# create, read, update items in datastore
# 
# consumes: mysql
# consumed by:
# - agent: updates items
# - FE: creates and reads

# readme
# datastore
# google mysql passwordless auth: mysql_config_editor set --login-path....

require 'securerandom'
require 'sinatra'
require 'services/crud_items'

get '/' do
  'hello'
end

delete '/items/:id' do
  crud = Services::CrudItems.new
  crud.delete params[:id]
end

get '/items/:id' do
  crud = Services::CrudItems.new
  crud.get params[:id]
end

get '/items' do
  crud = Services::CrudItems.new
  crud.list
end

post '/items/:id' do
  text = request.body.read.to_s.downcase
  obj = JSON.parse text
  crud = Services::CrudItems.new
  crud.post params[:id], obj['type'], obj['data']
end

put '/items/:id' do
  text = request.body.read.to_s.downcase
  obj = JSON.parse text
  #  mysql doesn't understand 'nil'
  obj.each do |k,v| 
    obj[k] = {nil=>'null'}[v] || v
  end
  completed = 'NULL'
  completed = 'curtime()' if obj['completed'].to_s.eql? '1'

  crud = Services::CrudItems.new
  crud.put params[:id], obj['seen'], completed
end

post '/itemtest' do 
  crud = Services::CrudItems.new
  crud.test(SecureRandom.uuid)
end

