users = 'home'
users = 'Users' if node['platform_family'].eql? 'mac_os_x'

homedir = "/#{users}/#{node['development-setup']['user']['name']}"

#link "#{homedir}/bin" do
#  to "/opt/chef/cookbooks/development-setup/files/bin"
#end
