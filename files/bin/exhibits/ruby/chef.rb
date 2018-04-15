require 'chef'
require 'chef/knife'
require 'chef/knife/cookbook_show'
server = "http://localhost/organizations/default"
::Chef::Config.chef_server_url = server
::Chef::Config.node_name = 'pivotal'
::Chef::Config.client_key = '/etc/opscode/pivotal.pem'
::Chef::Config.ssl_verify_mode = :verify_none
show = ::Chef::Knife::CookbookShow.new
show.name_args = ['thermomix_dedicated']
show.run
