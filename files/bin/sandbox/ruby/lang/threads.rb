#!/usr/bin/env ruby

require 'thread'
$lock = Mutex.new
THREAD_COUNT = 1000

$global_list = []
$threads = []

THREAD_COUNT.times do |i|
  $threads << Thread.new(i) { |number|
    $lock.synchronize {
      $global_list << "thread #{number}"
    }
  }
end

$threads.each do |thread|
  thread.join()
end

if $global_list.size.eql? THREAD_COUNT
  puts "Success! all #{THREAD_COUNT} threads reported in."
else
  puts "Fail! only #{$global_list.size} threads reported in."
end
