require 'optparse'
require 'json'

input = ENV.to_hash
File.write('ENV.json', JSON.pretty_generate(input))

hash = ENV.dup.freeze

class NoConstructor
  def import(hash)
    hash.each do |k,v|
      instance_variable_set("@#{k.downcase}".to_sym, v)
    end
  end

  def go
    puts @path
  end
end


nc = NoConstructor.new
nc.import(input)

nc.go
