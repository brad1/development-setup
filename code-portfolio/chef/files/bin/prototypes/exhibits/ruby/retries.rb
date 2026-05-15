# What are the top level throwable/catchable classes?

class Clamp
  def initialize(lower_limit, upper_limit)
    @lower_limit = lower_limit
    @upper_limit = upper_limit
  end

  def evaluate(value)
    return @lower_limit if !(@lower_limit.nil?) && (value < @lower_limit)
    return @upper_limit if !(@upper_limit.nil?) && (value > @upper_limit)
    return value
  end
end


class Retries

  @@presets = []

  def self.preset_create(name, options)
    @@presets << {
      name: name,
      options: options,
      created: Time.now.to_f
    }
  end

  def self.run(lam, name = 'default')
    finished = false
    preset_to_use = @@presets.detect { |p| p[:name].eql? name }
    opts = preset_to_use[:options]
    tries_remaining = opts[:max_tries]
    begin
      tries_remaining -= 1
      lam.call
      finished = true
    rescue Exception => exception
      puts "Warning: caught '#{exception.to_s}'"
      unless finished || tries_remaining <= 0
        slept_for = sleep_for(opts, tries_remaining)
        puts "Warning: #{tries_remaining} tries remaining."
        retry
      end
    ensure
      unless finished
        puts "Error: 0 tries remaining, stopping."
      end
    end
  end

  def self.sleep_for(opts, tries_remaining)
    round = Clamp.new(1, nil)
    multiplier = 1
    case opts[:delay][:type]
    when :linear
      multiplier = 1
    when :exponential
      count_already_tried = round.evaluate( opts[:max_tries] - tries_remaining )
      multiplier = 2**(count_already_tried - 1)
    end
    delay = opts[:delay][:value] * multiplier
    puts "Warning: sleeping for #{delay} seconds."
    sleep delay
  end

end


Retries.preset_create(
  'default',
  {
    max_tries: 2,
    delay: {
      type: :linear,
      value: 2
      # unit: :seconds
    }
  }
)

Retries.preset_create(
  'expon',
  {
    max_tries: 4,
    delay: {
      type: :exponential,
      value: 2
      # unit: :seconds
    }
  }
)


Retries.run( lambda {
  File.read('/nosuch')
})

Retries.run( lambda {
  File.read('/nosuch2')
}, 'expon')
