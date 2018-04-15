require 'bunny'

class SnitchListener 

  def initialize(time_provider, timeout, messages_to_listen_for, exchange)
    @time_provider          = time_provider
    @last_checked_time      = time_provider.get_time()
    @timeout                = timeout
    @messages_to_listen_for = messages_to_listen_for
    @exchange               = exchange
    @last_time_heard = {}
  end

  def start_listening 
    @conn = Bunny.new
    @conn.start
    @ch = @conn.create_channel
    @x  = @ch.fanout(@exchange)
    listen_to_fanout(@ch, @x, "snitch_backend_queue_for_#{@exchange}")
  end

  def get_dead_publishers
    rval = []
    check_time()
    @last_time_heard.each do |msg,time|
      if @messages_to_listen_for.include? msg
        if (Time.iso8601(@last_checked_time) - Time.iso8601(time)) > @timeout
          rval << msg
        end
      end
    end
    return rval
  end

  protected
  def check_time
    @last_checked_time = @time_provider.get_time()
  end

  def report_heard(message_content)
    message = translate(message_content)
    @last_time_heard[message] = @last_checked_time
  end

  def translate(message_content)
    message_content
  end
  
  private
  def listen_to_fanout(channel, exchange, name)
    channel.queue(name, :manual_ack => true).bind(exchange).subscribe do |d,m,p|
      check_time()
      # puts translate(p)
      report_heard(p)
      channel.ack(d.delivery_tag)
    end
  end
end
