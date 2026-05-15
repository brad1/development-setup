package_list = %w{jre8-openjdk jenkins}

package_list.each do |pkgname|
  package pkgname do
    action :install
    only_if { node['development-setup']['build_system']['enabled'] }
  end
end

services = %w{jenkins}

services.each do |service_name|
  service service_name do
    action [:enable, :start]
    only_if { node['development-setup']['build_system']['enabled'] }
  end
end
