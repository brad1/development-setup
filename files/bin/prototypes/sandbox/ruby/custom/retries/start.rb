#Requires:
#- block to execute
#- max retries
#- overridable logger?
#- overridable exception handler for when retries exceed 


class Wrapper

  def initialize(&block)
    @block = block
    @is_a_success = false
    @tried_once   = false
    @tries_remaining = 10
  end

  def validate
  end

  def execute
    while should_try_executing
      delay_for_try
      note_a_try
      try_executing_block
    end
  end

  private

  def delay_for_try
    return unless @tried_once
    sleep 1.2
  end

  def note_a_try
    @tries_remaining -= 1
    @tried_once  = true
  end

  def should_try_executing
    if @is_a_success or @tries_remaining.eql?(0)
      return false
    end

    true
  end

  def try_executing_block
    begin
      @block.call
      @is_a_success = true
    rescue StandardError => e
      msg 'StandardError', e.class.name 
    end
  end

  def msg(to_catch, caught)
    puts "Real catch of #{caught} using #{to_catch}"
  end

end

Wrapper.new { 
  nil.asdf
}.execute


