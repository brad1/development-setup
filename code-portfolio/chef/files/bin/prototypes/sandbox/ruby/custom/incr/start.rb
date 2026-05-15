class SteppableOperation

	def initialize
		@operations = []
	end

        def add(op)
		@operations << op
	end

	def step()
		op = @operations.shift
		op.execute()
	end
end

class HelloWorldOp
	def execute
		puts "HelloWorld!"
	end
end

class SOBuilder 
	def initialize()
	end

	def load(filepath_or_id)
		begin
			content = File.read(filepath_or_id)
		rescue
			# locate id
		end

		# for now build default

		so = SteppableOperation.new
		so.add(HelloWorldOp.new)
		so	
	end
end

def main
	sob = SOBuilder.new
        steppable_operations = []
        steppable_operations << sob.load(nil)
	steppable_operations.each do |op|
		op.step()
	end
end
main
