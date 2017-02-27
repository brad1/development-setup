package "zsh"

homedir = "/home/#{node['development-setup']['user']['name']}"

git "#{homedir}/.oh-my-zsh" do
  repository 'https://github.com/robbyrussell/oh-my-zsh.git'
  user node['development-setup']['user']['name']
  reference "master"
  action :sync
end

template "#{homedir}/.zshrc" do
  source "zshrc.erb"
  owner node['development-setup']['user']['name']
  mode "644"
  action :create_if_missing
  variables({
    :user           => node['development-setup']['user']['name'],
    :theme          => 'robbyrussell',
    :case_sensitive => false,
    :plugins        => %w{git}
  })
end

user node['development-setup']['user']['name'] do
  action :modify
  shell '/bin/zsh'
end
