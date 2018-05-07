require 'time'

class TimeProvider

  def initialize(times = nil)
    @times = times
  end

  def get_time

    if @times.nil?
      return Time.now.utc.iso8601
    end

    if @times.empty?
      raise "#{self.class.name} ran out of times!"
    end

    @times.shift
  end
end
