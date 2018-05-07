class PollChefRunCompletion
  def initialize(n)
    @n = n
  end
  def execute
    t = Thread.new do
      id = @n 
      while(true)
        puts id
        sleep 1
      end
    end

    sleep 3
    t.exit()
  end
end


PollChefRunCompletion.new(1).execute
PollChefRunCompletion.new(2).execute
PollChefRunCompletion.new(3).execute

while(true)
  sleep 1
end
