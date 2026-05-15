class Reflection
  def singleton_class 
     class << self
       self
     end
  end

  class << self
    def singleton_method 
      'singleton_method'
    end
  end
end 

#puts Reflection
#puts Reflection.class
#puts Reflection.singleton_class
#puts Reflection.singleton_class.class
#puts Reflection.singleton_method


# Monkey patch, does the same thing as attr_accessor
class Class
  def accessors(*attrs)
    attrs.each do |attr|
      class_eval %Q{
      def #{attr} 
        @#{attr}
      end
      def #{attr}=(value)
        @#{attr} = value
      end
      }
    end
  end
end

class Klass
  accessors :a, :b
end

k = Klass.new
k.a = "I was declared automatically and this is my value" 
test = k.a
puts "Success! custom attr_accessor works."

$method_missing_called = false

# Must override both of these
class MethodMissing < String
  private

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with? 'asd'
      # for always responding:
      # true
    end

    def method_missing(method_name, *arguments)
      $method_missing_called = true
      if method_name.to_s.start_with? 'asdf'
        #puts method_name
      else
        super
      end
    end
end

MethodMissing.new.asdf
if $method_missing_called
  puts "Success! method missing called."
else
  puts "Failed! method missing not called."
end

$test_method = false

class Something
  def initialize
    self.class.send(:define_method, 'test') { $test_method = true } 
  end
end

Something.new.test

if $test_method
  puts "Success! test_method called."
else
  puts "Failed! test_method not called."
end





# Other:
# eval
# instance_eval
# class_eval (aka: module_eval)
# class_variable_set
# class_variable_get
# class_variables (Try it out: instance_variables)
# instance_variable_set (Try it out: instance_variable_get)
# define_method
# const_set
# const_get (Try it out: constants)
# Class.new (Try it out: Struct.new)
# binding (Try it out: lambda)
# send (Try it out: method)
# remove_method
# undef_method
# method_missing
