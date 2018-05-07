cat << EOF > ./start.rb
# [snippets]
# beg tab
# def tab 
# cla tab <2> <enter>
# mod tab <enter>
# dawwP for word swap
# or df<space>f<space>p
# easy matches: 
#   - ""

def find_logfiles
  require 'json'
  filepaths = Dir['**/*.log']
  File.write('C:/logfiles',JSON.pretty_generate(filepaths))
end

EOF

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -e "$DIR/local/cheatsheet.ruby" ]; then
  cat $DIR/local/cheatsheet.ruby >> ./start.rb
fi
