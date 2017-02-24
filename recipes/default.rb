case node['platform_family']
when 'arch'
  include_recipe 'developer-setup::arch'
when 'rhel'
  Chef::Log.info("no rhel")
when 'mac_os_x'
  include_recipe 'developer-setup::osx'
when 'windows'
  include_recipe 'developer-setup::windows'
else
  Chef::Log.fatal("Don't know what to do with platform family #{node['platform_family']}")
end
