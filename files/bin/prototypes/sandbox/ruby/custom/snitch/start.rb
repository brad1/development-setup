require 'bunny'

require_relative 'time_provider.rb'
require_relative 'snitch_listener.rb'

$sl = SnitchListener.new( 
  TimeProvider.new([
    "2014-11-21T21:13:01Z",
    "2014-11-21T21:13:01Z",
    "2014-11-21T21:15:01Z",
    "2014-11-21T21:15:01Z",
    "2014-11-21T21:17:01Z",
    "2014-11-21T21:17:01Z",
    "2014-11-21T21:19:01Z",
    "2014-11-21T21:19:01Z",
    "2014-11-21T21:21:01Z",
    "2014-11-21T21:21:01Z",
    "2014-11-21T21:23:01Z",
    "2014-11-21T21:23:01Z",
    "2014-11-21T21:25:01Z",
    "2014-11-21T21:25:01Z",
    "2014-11-21T21:27:01Z",
    "2014-11-21T21:27:01Z",
    "2014-11-21T21:29:01Z",
    "2014-11-21T21:29:01Z",
    "2014-11-21T21:30:01Z",
    "2014-11-21T21:30:01Z",
    "2014-11-21T21:30:01Z",
    "2014-11-21T21:30:01Z"
  ]), 
  60*7, 
  ['m1','m2','m3'],
  "first_monitoring_exchange"
)
$sl.start_listening()

conn = Bunny.new
conn.start
ch = conn.create_channel
$x  = ch.fanout('first_monitoring_exchange')

def go(list = [])
  list.each do |item|
    $x.publish(item)
  end
  sleep 0.5 
  puts $sl.get_dead_publishers().inspect()
end

go(['m1','m2','m3'])
go(['m1','m2'])
go(['m1'])
5.times do
  go()
end

