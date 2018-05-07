class CustomObject
  def initialize
  end
  def makearray
    [1,2,3,4,5]
  end
  def makestring
    "asdf"
  end
  def self.build
    CustomObject.new
  end
  def self.null
    rval = build
    ['makearray', 'makestring'].each do |item|
      result = rval.send(item.to_sym)
      return_type = result.class.null
      eval %Q{
      def rval.#{item}
        #{return_type}
      end
      }
    end
    rval
  end
end

class String
  def self.null
    ""
  end
end

class Array
  def self.null
    []
  end
end

puts CustomObject.build.makearray.to_s
puts CustomObject.build.makestring.to_s
puts CustomObject.null.makearray.to_s
puts CustomObject.null.makestring.to_s
