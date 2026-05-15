package_list = node['developer-setup']['clients'].dup

# set package names for platform
case node['platform']
when 'arch'
  if package_list.include? 'mysql'
    package_list.delete('mysql')
    package_list << 'mariadb'
  end
end

package_list.each do |pkgname|
  package pkgname do
    action :install
    only_if { node['development-setup']['clients']['enabled'] }
  end
end
