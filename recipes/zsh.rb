package "zsh"

homedir = "/home/#{node['development-setup']['user']}"

git "#{homedir}/.oh-my-zsh" do
  repository 'https://github.com/robbyrussell/oh-my-zsh.git'
  user node['developer-setup']['user']
  reference "master"
  action :sync
end

template "#{homedir}/.zshrc" do
  source "zshrc.erb"
  owner node['developer-setup']['user']
  mode "644"
  action :create_if_missing
  variables({
    :user           => node['developer-setup']['user'],
    :theme          => 'robbyrussell',
    :case_sensitive => false,
    :plugins        => %w{git}
  })
end

user node['development-setup']['user'] do
  action :modify
  shell '/bin/zsh'
end
