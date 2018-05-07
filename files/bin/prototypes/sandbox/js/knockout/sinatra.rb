require 'sinatra'

set :bind, '0.0.0.0'
set :timeout, 120
set :public_folder, File.expand_path("#{File.dirname(__FILE__)}/public")
