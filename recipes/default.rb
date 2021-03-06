case node['platform_family']
when 'arch'
  include_recipe 'development-setup::arch'
when 'debian'
when 'rhel'
  include_recipe 'development-setup::vim'
  include_recipe 'development-setup::zsh'
when 'fedora'
  include_recipe 'development-setup::vim'
  include_recipe 'development-setup::zsh'
  include_recipe 'development-setup::fedora'
when 'mac_os_x'
  include_recipe 'development-setup::osx'
when 'windows'
  include_recipe 'development-setup::windows'
else
  Chef::Log.fatal("Don't know what to do with platform family #{node['platform_family']}")
end

include_recipe 'development-setup::setup'
