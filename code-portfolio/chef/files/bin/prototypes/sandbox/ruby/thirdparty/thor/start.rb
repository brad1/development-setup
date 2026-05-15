# ruby start.rb hello -o 'asdf'

require 'thor'

class ThorTest < Thor
  include Thor::Actions

  desc "test", "tests stuff"
  method_option :output, :type => :string, :aliases => '-o', :required => false

  def hello(*args)
    puts "I am a method"
  end
  
  map 'h' => :hello
end

ThorTest.start(ARGV)
