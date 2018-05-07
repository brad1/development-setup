require 'httparty'

class Special
  def initialize(target, method)
    @target = target
    @method = method
    @body = ''
  end
  def go
    case @method
    when :post
      HTTParty.post(@target, body: @body)
    end
  end
  def with_body(body)
    @body = body 
    self
  end
end

class String
  def get
    rval = Special.new(self, __method__)
    # proc to add headers
    HTTParty.get(self)
    puts "posted to #{self}!"
    return rval
  end
  def post
    rval = Special.new(self, __method__)
    return rval
  end
end 

"http://localhost".post
                  .with_body('jkdf')
                  .go
