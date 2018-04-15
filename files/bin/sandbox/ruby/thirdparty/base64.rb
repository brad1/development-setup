require 'base64'

enco = Base64.encode64("asdf")
asdf = Base64.decode64("YXNkZg==\n")

if enco.eql? "YXNkZg==\n" and asdf.eql? 'asdf'
  puts "Success! base64 works."
else
  puts "Failed! base64 with asdf='#{asdf}' and enco = '#{enco}'"
end
