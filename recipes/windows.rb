ruby_block "log_platform" do
  block do
    Chef::Log.info("node['platform']: #{node['platform']}")
  end
end

if File.exist?('C:/Users/Brad') 
  node.override['developer-setup']['user'] = 'Brad'
  node.override['developer-setup']['homedir'] = 'C:/Users/Brad'
  
elsif  File.exist?('C:/Users/Administrator')
  node.override['developer-setup']['user'] = 'Administrator'
  node.override['developer-setup']['homedir'] = 'C:/Users/Administrator'
else
  raise "No recognized user is present."
end

homedir = "C:/Users/#{node['developer-setup']['user']}"

registry_key "HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\Environment " do
  values [{
    :name => "Path",
    :type => :expand_string,
    :data => "#{`echo %PATH%`.strip};#{node['developer-setup']['homedir'].gsub('/',"\\")}\\bin\\"
  }]
  action :create
end
