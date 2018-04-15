$exceptions_frozen = [
  Exception,
  RuntimeError,
  StandardError # expect library exceptions to inherit from this
].freeze

$exceptions_frozen.each do |to_catch|
  $exceptions_frozen.each do |to_raise|
    next if to_catch.eql? to_raise
    begin
      raise to_raise
    rescue to_catch 
      puts "Success! #{to_catch} catches #{to_raise}"
    rescue to_raise
      puts "Success! #{to_catch} does not catch #{to_raise}"
    else
      puts "Failed, no exception raised"
    ensure
    end
  end
end
