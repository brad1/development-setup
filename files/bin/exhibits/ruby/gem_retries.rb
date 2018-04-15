require 'retries'

DEFAULT_RETRIES = { max_tries: 10,
                    base_sleep_seconds: 1,
                    max_sleep_seconds: 100 }
DEFAULT_WAITER = { max_attempts: 60, delay: 1 }

$hash = {'a'=>1}
def asdf
  $hash['a'] += 1
  $hash
end
with_retries(DEFAULT_RETRIES) do
     asdf 
      .wait_until(DEFAULT_WAITER) { |i| puts i.inspect }
end
