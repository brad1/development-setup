include_recipe 'development-setup::user' if node['user']['enabled']
include_recipe 'development-setup::zsh'
include_recipe 'development-setup::clients'
include_recipe 'development-setup::build_system'
