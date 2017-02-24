#pacman -Syu
#pacman -Sy ruby git openssh
gem install chef ruby-shadow --no-ri --no-rdoc
#mkdir -p /root/chef/cookbooks
#cd /root/chef/cookbooks
#git clone https://github.com/brad1/developer-setup.git
#cd developer-setup
#cp node.json /root/chef
#cp solo.rb /root/chef
#/root/.gem/ruby/2.2.0/bin/chef-solo -c /root/chef/solo.rb
rvm use 2.4.0
chef-solo -c /home/developer/solo.rb
