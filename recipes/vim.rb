package_list = %w{vim}

package_list.each do |pkgname|
  package pkgname do
    action :install
  end
end

users = 'home'
users = 'Users' if node['platform_family'].eql? 'mac_os_x'

homedir = "/#{users}/#{node['development-setup']['user']['name']}"
dir = "#{homedir}/.vim/bundle"

execute "mkdir -p #{homedir}/.vim/autoload #{dir}"

link "#{homedir}/.vim/autoload/pathogen.vim" do
  to "/opt/chef/cookbooks/development-setup/files/vim/pathogen.vim"
end

["https://github.com/kien/ctrlp.vim.git",
 "https://github.com/scrooloose/syntastic.git",
 "https://github.com/scrooloose/nerdtree.git",
 "https://github.com/tomtom/tlib_vim.git",
 "https://github.com/MarcWeber/vim-addon-mw-utils.git",
 "https://github.com/garbas/vim-snipmate.git",
 "https://github.com/ntpeters/vim-better-whitespace.git",
 "https://github.com/Raimondi/delimitMate.git",
 "https://github.com/honza/vim-snippets.git"].each do |repo_url|

  repo_name = repo_url.split('/').last.split('.')
  repo_name.pop
  repo_name = repo_name.join('.')

  git "#{dir}/#{repo_name}" do
    repository repo_url
  end

end

link "#{homedir}/.vimrc" do
  to "/opt/chef/cookbooks/development-setup/files/vim/vimrc"
end


