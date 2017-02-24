package_list = [ "virtualbox-guest-modules-arch", "virtualbox-guest-utils"]

file "/etc/modules-load.d/virtualbox.conf" do
  content <<-EOH
vboxguest
vboxsf
vboxvideo
  EOH
end

package_list.each do |pkgname|
  package pkgname do
    action :install
  end
end
