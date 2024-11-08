# Python Cheatsheet

# String Operations
"Hello, World!".upper()                      # Uppercase
"Hello" + " World!"                           # Concatenate
"Hello"[:5]                                   # Slice
"Hello".replace("l", "L")                    # Replace
"Hello".find("lo")                            # Contains?
"Hello\nWorld".splitlines()                   # Split by newline
"   Hello   ".strip()                         # Trim whitespace
list("Hello")                                 # Characters list
import re; re.findall(r'[a-z]', "abc123")    # Scan letters

# List Manipulations
[1, 2, 3].map(lambda x: x * 2)                # Map
[x for x in [1, 2, 3] if x % 2 == 0]          # Select evens
[x for x in [1, 2, 3] if x <= 2]              # Reject >2
sum([1, 2, 3])                                 # Sum
list(set([1, 2, 3]))                          # Unique
lst = [1, 2, 3]; lst.append(4)                # Append
lst.pop()                                     # Remove last
lst.pop(0)                                    # Remove first
lst[0]                                        # First element
lst[-1]                                       # Last element

# Dictionary Operations
{'a': 1, 'b': 2}['a']                        # Access
dict1 = {'a': 1, 'b': 2}; dict1.update({'c': 3}) # Merge
list(dict1.keys())                           # Keys list
list(dict1.values())                         # Values list
dict1.get('a')                               # Fetch value
dict1.pop('b')                               # Delete key

# Control Structures
x = 5; result = "Greater" if x > 5 else "Smaller"  # Ternary
for i in range(1, 6): print(i)              # Loop
list(map(str, range(1, 6)))                  # Range to strings
while condition: action()                     # While loop
for i in range(6): print(i)                   # For loop
if x == 1: print("One")                       # If statement

# Function Definitions
def greet(name): return f"Hello, {name}!"    # Simple function
def add(a, b=1): return a + b                 # Default param
def optional_args(*args): return args         # Var args
def named_args(a, b): return (a, b)          # Named args
@staticmethod                                   # Static method decorator
def class_method(cls): return "Class Method"  # Class method

# File Handling
with open('file.txt', 'r') as f: content = f.read()  # Read file
with open('file.txt', 'w') as f: f.write('Hello')     # Write file
with open('file.txt', 'r') as f: lines = f.readlines() # Read lines
import os; os.rename('old.txt', 'new.txt')            # Rename
os.remove('file.txt')                                 # Delete file
os.path.exists('file.txt')                            # Check existence
os.path.getsize('file.txt')                           # File size

# Exception Handling
try: risky_action() 
except Exception as e: print(e)                       # Rescue
raise Exception("Error")                              # Raise error
finally: print("Cleanup")                             # Ensure block
try: 1/0
except ZeroDivisionError: pass                         # Handle division error

# Object Instantiation
obj = MyClass()                                      # Instantiate
list()                                               # Empty list
str("Hello")                                        # New string
dict()                                              # Empty dict
import datetime; now = datetime.datetime.now()      # Current time

# Regex Operations
re.search(r'\d', "abc123") is not None            # Contains digit?
re.findall(r'\d', "abc123")                        # Find all digits
re.sub(r'\d', 'X', "abc123")                       # Replace digits
re.split(r'\d+', "abc123")                         # Split by digits
re.match(r'\d', "abc123") is not None              # Match regex

# Miscellaneous
any(x > 2 for x in [1, 2, 3])                     # Any
all(x < 4 for x in [1, 2, 3])                     # All
x is None                                          # Check None
True and False                                     # Logical and
2 in [1, 2, 3]                                     # Include?
list(range(1, 6))                                  # Range to list
lst.insert(1, 4)                                   # Insert at index
[1, 2, 3].extend([4, 5])                           # Extend list

# Symbol Operations
hello = "hello"                                    # String representation
hello_id = id(hello)                               # ID of string
print(hello)                                       # Print symbol



# List Comprehensions
squared = [x**2 for x in range(10)]             # Squares of numbers
even_numbers = [x for x in range(10) if x % 2 == 0]  # Even numbers
cubes = [x**3 for x in range(1, 6)]              # Cubes of 1 to 5
filtered = [x for x in [1, 2, 3, 4] if x > 2]   # Filter greater than 2

# Dictionary Comprehensions
squared_dict = {x: x**2 for x in range(5)}      # {0:0, 1:1, 2:4, 3:9, 4:16}
even_dict = {x: x**2 for x in range(10) if x % 2 == 0}  # Even squares
names = ['Alice', 'Bob', 'Charlie']
length_dict = {name: len(name) for name in names}  # Length of names

# Set Comprehensions
unique_squares = {x**2 for x in [1, 2, 2, 3]}    # {1, 4, 9}
odd_numbers = {x for x in range(10) if x % 2 != 0}  # Odd numbers
chars = {char for char in "hello" if char not in 'ol'}  # Unique chars excluding 'o' and 'l'

# Nested Comprehensions
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flattened = [num for row in matrix for num in row]  # Flatten a matrix
pairs = [(x, y) for x in range(3) for y in range(2)]  # Cartesian product
