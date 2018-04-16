package "zsh"

users = 'home'
users = 'Users' if node['platform_family'].eql? 'mac_os_x'

homedir = "/#{users}/#{node['development-setup']['user']['name']}"

git "#{homedir}/.oh-my-zsh" do
  repository 'https://github.com/robbyrussell/oh-my-zsh.git'
  user node['development-setup']['user']['name']
  reference "master"
  action :sync
end

link "#{homedir}/.zshrc" do
  to "/opt/chef/cookbooks/development-setup/files/zsh/zshrc"
end

case node['platform_family']
when 'windows'
when 'osx'
when 'arch'
  user node['development-setup']['user']['name'] do
    action :modify
    shell '/bin/zsh'
  end
when 'fedora'
  user node['development-setup']['user']['name'] do
    action :modify
    shell '/usr/bin/zsh'
  end
else
end

