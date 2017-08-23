package_list = %w{vim}

package_list.each do |pkgname|
  package pkgname do
    action :install
  end
end

homedir = "/home/#{node['development-setup']['user']['name']}"
dir = "#{homedir}/.vim/bundle"

execute "mkdir -p #{homedir}/.vim/autoload #{dir} && curl -LSso #{homedir}/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim"


["https://github.com/kien/ctrlp.vim.git",
 "https://github.com/scrooloose/syntastic.git",
 "https://github.com/scrooloose/nerdtree.git",
 "https://github.com/tomtom/tlib_vim.git",
 "https://github.com/MarcWeber/vim-addon-mw-utils.git",
 "https://github.com/garbas/vim-snipmate.git",
 "https://github.com/honza/vim-snippets.git"].each do |repo_url|
  
  repo_name = repo_url.split('/').last.split('.')
  repo_name.pop
  repo_name = repo_name.join('.')

  git "#{dir}/#{repo_name}" do
    repository repo_url 
  end

end

link "#{homedir}/.vimrc" do
  to "#{homedir}/etc/vimrc"
  only_if { File.exists?("#{homedir}/etc/vimrc") }
end
