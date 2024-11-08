# Ruby Cheatsheet

# String Operations
"Hello, World!".upcase                    # Uppercase
"Hello".concat(" World!")                 # Concatenate
"Hello"[0..4]                             # Slice
"Hello".gsub("l", "L")                    # Replace
"Hello".include?("lo")                    # Contains?
"Hello\nWorld".split                      # Split by newline
"   Hello   ".strip                        # Trim whitespace
"Hello".chars                             # Characters array
"abc123".scan(/[a-z]/)                    # Scan letters

# Array Manipulations
[1, 2, 3].map { |x| x * 2 }                # Map
[1, 2, 3].select { |x| x.even? }           # Select evens
[1, 2, 3].reject { |x| x > 2 }              # Reject >2
[1, 2, 3].reduce(:+)                       # Sum
[1, 2, 3].uniq                             # Unique
[1, 2, 3].push(4)                         # Append
[1, 2, 3].pop                             # Remove last
[1, 2, 3].shift                           # Remove first
[1, 2, 3].first                           # First element
[1, 2, 3].last                            # Last element

# Hash Operations
{ a: 1, b: 2 }[:a]                         # Access
{ a: 1, b: 2 }.merge(c: 3)                 # Merge
{ a: 1, b: 2 }.key(1)                      # Find key
{ a: 1, b: 2 }.transform_values { |v| v * 2 } # Transform
{ a: 1, b: 2 }.to_a                        # Convert to array
{ a: 1, b: 2 }.keys                        # Keys array
{ a: 1, b: 2 }.values                      # Values array
{ a: 1, b: 2 }.fetch(:a)                   # Fetch value
{ a: 1, b: 2 }.delete(:b)                  # Delete key

# Control Structures
if x > 5 then "Greater" else "Smaller" end # Ternary
(1..5).each { |i| puts i }                 # Loop
(1..5).map(&:to_s)                         # Range to strings
while condition; do action; end            # While loop
for i in 0..5; puts i; end                 # For loop
case x                                      # Case statement
when 1 then "One"
when 2 then "Two"
else "Other"
end

# Method Definitions
def greet(name); "Hello, #{name}!"; end    # Simple method
def add(a, b=1); a + b; end                # Default param
def optional_args(*args); args; end        # Var args
def named_args(a:, b:); [a, b]; end        # Named args
def self.class_method; "Class Method"; end # Class method
def private_method; "Private"; end          # Private method
def self.inherited(subclass); puts subclass; end # Inheritance hook

# File Handling
File.open('file.txt', 'r') { |f| f.read }  # Read file
File.write('file.txt', 'Hello')            # Write file
File.foreach('file.txt') { |line| puts line } # Read lines
File.rename('old.txt', 'new.txt')          # Rename
File.delete('file.txt')                     # Delete file
File.exist?('file.txt')                     # Check existence
File.size('file.txt')                       # File size
File.readlines('file.txt')                  # Read all lines
File.truncate('file.txt', 0)                # Clear file

# Exception Handling
begin 
  risky_action 
rescue => e 
  puts e.message 
end                                          # Rescue
raise "Error"                               # Raise error
ensure                                       # Ensure block
retry                                        # Retry block
begin; raise; rescue; end                   # Simple rescue
begin; 1/0; rescue ZeroDivisionError; end   # Handle division error

# Object Instantiation
obj = ClassName.new                         # Instantiate
Array.new(5)                                # Array with size
String.new("Hello")                         # New string
Hash.new                                     # Empty hash
Time.now                                    # Current time
MyClass.new(param)                          # Param constructor
MyClass.new { |x| x + 1 }                   # Block constructor

# Regex Operations
"abc123".match?(/\d/)                      # Contains digit?
"abc123".scan(/\d/)                        # Find all digits
"abc123".gsub(/\d/, 'X')                   # Replace digits
"abc123".split(/\d+/)                      # Split by digits
"abc123" =~ /\d/                           # Match regex
"abc123".sub(/[0-9]+/, 'X')                # Sub first match
"abc123".match(/(?<letters>[a-z]+)/)      # Named capture

# Miscellaneous
[1, 2, 3].any? { |x| x > 2 }                # Any
[1, 2, 3].all? { |x| x < 4 }                # All
nil.nil?                                     # Check nil
true && false                                # Logical and
[1, 2, 3].include?(2)                       # Include?
(1..5).to_a                                  # Range to array
[1, 2, 3].insert(1, 4)                      # Insert at index
[1, 2, 3].flatten                            # Flatten array

# Symbol Operations
:hello.to_s                                  # Symbol to string
:hello.to_sym                                 # String to symbol
:hello.inspect                               # Inspect symbol
:hello.class                                 # Class of symbol
:hello.id                                    # Symbol ID
:hello.to_proc.call("World")                # Convert to proc

