package_list = %w{ xorg-server xorg-xinit xorg-server-utils mesa ttf-liberation}

package_list |= %w{ gpicview lxappearance lxappearance-obconf lxde-common lxde-icon-theme lxdm lxinput lxlauncher lxmenu-data lxmusic lxpanel lxrandr lxsession lxtask lxterminal openbox pcmanfm }

file "/root/.xinitrc" do
  content <<-EOH
exec startlxde
  EOH
end

package_list |= %w{firefox icu}

package_list |= %w{xorg-twm xorg-xclock xterm}

package_list.each do |pkgname|
  package pkgname do
    action :install
  end
end

enable_services = %w{ lxdm dhcpcd }

enable_services.each do |svcname|
  service svcname do
    action :enable
  end
end

directory "/root/Desktop" do
  action :create
end
