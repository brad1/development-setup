begin
  require 'ffi-rzmq'
rescue LoadError
  puts ""
  puts "Can't load zeromq library, skipping."
  puts ""
  exit 0
end

def worker_routine(context)
  # Socket to talk to dispatcher
  receiver = context.socket(ZMQ::REP)
  receiver.connect("inproc://workers")
  
  loop do
    receiver.recv_string(string = '')
    puts "Received request: [#{string}]"
    # Do some 'work'
    sleep(1)
    # Send reply back to client
    receiver.send_string("world")
    sleep(3)
    exit 0
  end
end

context = ZMQ::Context.new

puts "Starting Hello World server…"

# socket to listen for clients
clients = context.socket(ZMQ::ROUTER)
clients.bind("tcp://*:5555")

# socket to talk to workers
workers = context.socket(ZMQ::DEALER)
workers.bind("inproc://workers")

# Launch pool of worker threads
Thread.new{worker_routine(context)}

# Connect work threads to client threads via a queue

# From zeromq.org helloworld, doesn't work here
# ZMQ::Device.new(ZMQ::QUEUE,clients,workers)

# works under ubuntu12.04 vbox w/ rvm ruby 2.2 and zeromq-4.1.0-rc1 compiled from source
# ffi (1.9.6)
# ffi-rzmq (2.0.4)
# ffi-rzmq-core (1.0.3)
ZMQ::Device.new(clients,workers)
