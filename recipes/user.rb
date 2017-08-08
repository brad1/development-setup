include_recipe 'development-setup::vim'

user node['development-setup']['user']['name'] do
  action :create
  # requires ruby-shadow, openssl and is generally a bad idea
  # password `openssl passwd -1 #{node['development-setup']['user']['password']}`.strip 
end

homedir = "/home/#{node['development-setup']['user']['name']}"

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

execute "chown -R #{node['development-setup']['user']['name']}:#{node['development-setup']['user']['name']} #{homedir}"

link "/etc/vpnc.conf" do
  to "#{homedir}/etc/vpnc.conf"
  only_if { File.exists? "#{homedir}/etc/vpnc.conf" }
end

link "#{homedir}/.vimrc" do
  to "#{homedir}/etc/vimrc"
  only_if { File.exists? "#{homedir}/etc/vimrc" }
end

link "#{homedir}/.oh-my-zsh/custom/variables.zsh" do
  to "#{homedir}/etc/variables.zsh"
  only_if { File.exists? "#{homedir}/etc/variables.zsh" }
end

link "#{homedir}/.oh-my-zsh/custom/functions.zsh" do
  to "#{homedir}/etc/functions.zsh"
  only_if { File.exists? "#{homedir}/etc/functions.zsh" }
end
