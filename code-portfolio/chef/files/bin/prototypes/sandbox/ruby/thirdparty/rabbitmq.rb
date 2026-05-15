begin
  require 'bunny'
rescue LoadError
  puts "Skipping, bunny not installed."
  exit 0
end

$lines = []

conn = Bunny.new

begin
  conn.start
rescue Bunny::TCPConnectionFailed
  puts "Couldn't connect to rabbitmq, skipping send."
  exit 0
end

ch = conn.create_channel


############################################################
#  Sending single message to single listener               #
############################################################
#                                                          #
q  = ch.queue('sandbox_amqp_single')
x  = ch.default_exchange
q.subscribe do |di, md, pl| 
  $lines << "#{q.name} Received #{pl}"
end
$lines << "Sending single_message..."
x.publish('single_message', :routing_key => q.name)
#                                                          #
############################################################



############################################################
#  Sending 2 single messages to multiple listeners         #
############################################################
#                                                          #
x  = ch.fanout('sandbox_amqp_fanout')

def listen_to_fanout(channel, exchange, name)
  channel.queue( name, :auto_delete => true).bind(exchange).subscribe do |d,m,p|
    $lines << "#{name} received #{p}"
  end
end

listen_to_fanout(ch, x, 'sandbox_amqp_fanout_listener_001')
listen_to_fanout(ch, x, 'sandbox_amqp_fanout_listener_002')
listen_to_fanout(ch, x, 'sandbox_amqp_fanout_listener_003')

x.publish("message01")
 .publish("message02")
#                                                          #
############################################################



############################################################
#  Sending single messages to N listeners in M regions     #
############################################################
#                                                          #
x  = ch.topic('sandbox_amqp_topic')

def listen_to_topic(channel, exchange, name, region)
  channel.queue(name).bind(exchange, :routing_key => region).subscribe do |d,m,p|
    $lines << "#{name} received #{p} with region #{d.routing_key}"
  end
end

listen_to_topic(ch, x, 'sandbox_amqp_topic_listener_001', 'RegionA')
listen_to_topic(ch, x, 'sandbox_amqp_topic_listener_002', 'RegionB')
listen_to_topic(ch, x, 'sandbox_amqp_topic_listener_003', 'RegionB')

x.publish("message01", :routing_key => 'RegionA')
 .publish("message02", :routing_key => 'RegionB')
 .publish("message03", :routing_key => 'RegionA')
 .publish("message04", :routing_key => 'RegionB')
#                                                          #
############################################################



############################################################
#  Sending messages round robin to two listeners           #
############################################################
#                                                          #
q  = ch.queue('sandbox_amqp_round_robin')

q.subscribe do |d,p,b|
  $lines << "RR listener 1 got #{b}"
end

q.subscribe do |d,p,b|
  $lines << "RR listener 2 got #{b}"
end

ch.default_exchange.publish("message 1", :routing_key => q.name)
ch.default_exchange.publish("message 2", :routing_key => q.name)
ch.default_exchange.publish("message 3", :routing_key => q.name)
ch.default_exchange.publish("message 4", :routing_key => q.name)
ch.default_exchange.publish("message 5", :routing_key => q.name)
ch.default_exchange.publish("message 6", :routing_key => q.name)
#                                                          #
############################################################



############################################################
#  Sending messages with acks                              #
############################################################
#                                                          #
class BooleanSet

  def initialize
    @flags = {} 
  end

  def satisfied?
    @flags.each do |k,v|
      unless v
        return false
      end
    end

    true
  end

  def set(value)
    @flags[value] = true
  end

  def unset(value)
    @flags[value] = false
  end
end

q  = ch.queue('sandbox_amqp_ack')

$bs = BooleanSet.new

q.subscribe(:manual_ack => true) do |d,p,b|
  $lines << "ACK listener 1 got #{b}"
  ch.ack(d.delivery_tag)
  $bs.set b
  sleep 0.1
end

q.subscribe(:manual_ack => true) do |d,p,b|
  $lines << "ACK listener 2 got #{b}"
  ch.ack(d.delivery_tag)
  $bs.set b
  sleep 0.1
end

def msg_send(msg, q, ch)
  ch.default_exchange.publish(msg, :routing_key => q.name)
  sleep 0.1
end

message_list = [
 "message 1",
 "message 2",
 "message 3",
 "message 4",
 "message 5",
 "message 6"
]

message_list.each do |item|
  $bs.unset item
end

message_list.each do |item|
  msg_send(item, q, ch)
end

while !$bs.satisfied?
  sleep 0.1
end

#                                                          #
############################################################



############################################################
#  Sending messages replicated to two listeners            #
############################################################
#                                                          #
x  = ch.fanout('sandbox_amqp_fanout_with_ack')

def listen_to_fanout(channel, exchange, name)
  channel.queue(name, :manual_ack => true).bind(exchange).subscribe do |d,m,p|
    $lines << "#{name} received #{p}"
    channel.ack(d.delivery_tag)
  end
end

listen_to_fanout(ch, x, 'sandbox_amqp_fanout_with_ack_listener_001')
listen_to_fanout(ch, x, 'sandbox_amqp_fanout_with_ack_listener_002')

x.publish("message01")
 .publish("message02")
#                                                          #
############################################################




sleep 1
conn.close
$lines << "done!"

if $lines.size.eql? 31
  puts "Success! all rabbitmq steps executed."
else
  puts "Failed! #{$lines.size} steps executed."
end
