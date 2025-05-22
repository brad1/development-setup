# Python Cheatsheet

# OS
HOST = os.getenv('HOST', 'http://localhost')
val = os.getenv(key).lower() == 'true'
exit(0) # no 'os' or 'sys' for this


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

# String Encodings:
# --> Convert string to bytes
"Hello, World!".encode("utf-8")   # b'Hello, World!'
"你好".encode("utf-8")             # b'\xe4\xbd\xa0\xe5\xa5\xbd'

# --> Convert bytes to string
b"Hello, World!".decode("utf-8")  # 'Hello, World!'
b'\xe4\xbd\xa0\xe5\xa5\xbd'.decode("utf-8")  # '你好'

# --> ASCII representation of bytes
b"Hello".hex()                    # '48656c6c6f'
bytes.fromhex('48656c6c6f')        # b'Hello'

# --> Manual byte sequence creation
bytes([72, 101, 108, 108, 111])    # b'Hello'

# --> Encoding differences
b'\x48\x65\x6C\x6C\x6F\x2C\x20\x57\x6F\x72\x6C\x64\x21'
# is equivalent to:
"Hello, World!"
# ---
"Hello".encode("ascii")            # b'Hello'
"Hello".encode("utf-16")           # b'\xff\xfeH\x00e\x00l\x00l\x00o\x00'
"Hello".encode("utf-32")           # b'\xff\xfe\x00\x00H\x00\x00\x00e\x00\x00\x00l\x00\x00\x00l\x00\x00\x00o\x00\x00\x00'

# ---> Check if bytes object
isinstance(b"Hello", bytes)        # True

# --> Convert bytes to list of ASCII values
list(b"Hello")                     # [72, 101, 108, 108, 111]

# End of Strings Encodings

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

# Checksums, digest
data = b"Hello, World!"
import hashlib
hashlib.md5(data).hexdigest()      # MD5 checksum  
hashlib.sha1(data).hexdigest()     # SHA-1 checksum  
hashlib.sha256(data).hexdigest()   # SHA-256 checksum  
hashlib.sha512(data).hexdigest()   # SHA-512 checksum  
import zlib
zlib.crc32(data)                   # CRC32 checksum



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
