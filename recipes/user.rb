include_recipe 'development-setup::vim'

user node['development-setup']['user'] do
  action :create
  password `openssl passwd -1 #{node['developer-setup']['password']}`.strip 
end

homedir = "/home/#{node['development-setup']['user']}"

directory homedir do
  action :create
end

package 'sudo' do
  action :install
end 

package 'openconnect' do
  action :install
  only_if { File.exists? "#{homedir}/etc/vpnc.conf" }
end

execute "chown -R #{node['development-setup']['user']}:#{node['development-setup']['user']} #{homedir}"

link "/etc/vpnc.conf" do
  to "#{homedir}/etc/vpnc.conf"
  only_if { File.exists? "#{homedir}/etc/vpnc.conf" }
end

link "/home/#{node['development-setup']['user']}/.vimrc" do
  to "#{homedir}/etc/vimrc"
  only_if { File.exists? "#{homedir}/etc/vimrc" }
end

link "/home/#{node['development-setup']['user']}/.oh-my-zsh/custom/variables.zsh" do
  to "#{homedir}/etc/variables.zsh"
  only_if { File.exists? "#{homedir}/etc/variables.zsh" }
end

link "/home/#{node['development-setup']['user']}/.oh-my-zsh/custom/functions.zsh" do
  to "#{homedir}/etc/functionss.zsh"
  only_if { File.exists? "#{homedir}/etc/functions.zsh" }
end
