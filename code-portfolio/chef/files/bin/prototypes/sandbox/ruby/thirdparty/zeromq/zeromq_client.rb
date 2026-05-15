begin
  require 'ffi-rzmq'
rescue LoadError
  puts ""
  puts "Can't load zeromq library, skipping."
  puts ""
  exit 0
end

context = ZMQ::Context.new(1)

# Socket to talk to server
puts "Connecting to hello world server…"
requester = context.socket(ZMQ::REQ)
requester.connect("tcp://localhost:5555")

puts "Sending request 0"
requester.send_string "Hello"

reply = 'aoeu'
rc = requester.recv_string(reply)

puts "Received reply 0: [#{reply}]"
