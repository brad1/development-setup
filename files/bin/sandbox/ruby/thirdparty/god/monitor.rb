require 'god'

$path_to_this_dir = File.expand_path(File.dirname(__FILE__))
$path_to_process = "#{$path_to_this_dir}/process.rb"


God.watch do |w|
  w.name = "simple"
  w.start = "ruby #{$path_to_process}"
  w.keepalive
end
