#!/usr/bin/env ruby

ENV['A'] = 'A' 

puts ENV['A']
puts ENV['B']

# May or may not always work
puts `which ruby`
puts ''

puts "RUBY_VERSION: #{RUBY_VERSION}"

def print_env(name)
  puts "#{name}: #{ENV[name]}"
end

['RUBYOPT','RUBYPATH','RUBYLIB'].each do |name|
  print_env(name)
end


puts ""
puts "------ Gem.path -------"
puts Gem.path
puts "-- end Gem.path -------"
puts ""

puts ""
puts "------ Load path-------"
$:.each do |path|
  puts path
end
puts "-- end Load path-------"
puts ""


puts ""
puts "------ Loaded Gems -------"
# Shows for (gem 'json'), but not for (require 'json')
Gem.loaded_specs.each do |k,v|
  puts "#{v.name}: #{v.version}"
end
puts "-- end Loaded Gems -------"
puts ""


puts ""
puts "------ Loaded Features ---"
$LOADED_FEATURES.each do |feature|
  puts feature
end
puts "-- end Loaded Features ---"
puts ""

puts "------ Visible installed gems ----------"
Gem::Specification.all = nil    
all = Gem::Specification.map{|a| "#{a.name}: #{a.version}"}  
Gem::Specification.reset
puts all.inspect
puts "-- end Visible installed gems ----------"

