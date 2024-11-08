# BASH CHEATSHEET

## NAVIGATION
pwd                          # Print working directory
cd /path/to/dir              # Change directory
cd ~                         # Go to home directory
cd -                         # Switch to the last directory
ls                           # List directory contents
ls -l                        # Detailed list
ls -a                        # Show hidden files

## FILE OPERATIONS
touch filename.txt           # Create an empty file
cp source dest               # Copy file
mv source dest               # Move/rename file
rm filename.txt              # Remove a file
rm -r dir/                   # Remove directory recursively
mkdir dirname                # Make directory
rmdir dirname                # Remove directory (only if empty)

## REDIRECTION
command > file               # Redirect standard output to file
command >> file              # Append standard output to file
command 2> file              # Redirect standard error to file
command 2>&1                 # Redirect standard error to standard output
command < file               # Take input from file

## PIPING
command1 | command2          # Pipe command1 output to command2 input

## VARIABLES
VARNAME=value                # Declare a variable
echo $VARNAME                # Use a variable
export VARNAME=value         # Export variable as environment variable

## COMMAND EXECUTION
$(command)                   # Command substitution
`command`                    # Alternative command substitution

## CONDITIONALS
[ $VAR -eq 10 ]              # Integer comparison, equal
[ $VAR -ne 10 ]              # Integer comparison, not equal
[ $VAR -lt 10 ]              # Less than
[ $VAR -le 10 ]              # Less than or equal
[ $VAR -gt 10 ]              # Greater than
[ $VAR -ge 10 ]              # Greater than or equal
[ -z "$STRING" ]             # String is null
[ -n "$STRING" ]             # String is not null
[ "$STRING1" = "$STRING2" ] # String comparison
[ -f "$FILE" ]               # Check if FILE exists and is a regular file
[ -d "$DIRECTORY" ]          # Check if DIRECTORY exists and is a directory

### CONDITIONAL EXPRESSIONS IN DOUBLE BRACKETS
[[ $STRING =~ regex ]]       # Regular expression match
[[ $VAR -lt 10 && $VAR -gt 5 ]]  # Logical AND
[[ $VAR -lt 5 || $VAR -gt 10 ]]  # Logical OR

## TEST COMMANDS
test -f "$FILE"               # Check if FILE exists and is a regular file
test -d "$DIRECTORY"          # Check if DIRECTORY exists and is a directory
test -e "$ITEM"               # Check if ITEM exists (any type)
test -r "$FILE"               # Check if FILE is readable
test -w "$FILE"               # Check if FILE is writable
test -x "$FILE"               # Check if FILE is executable
test -z "$STRING"             # Check if STRING is null (length 0)
test -n "$STRING"             # Check if STRING is not null (length > 0)
test "$STRING1" = "$STRING2"  # Check if STRING1 is equal to STRING2

## CONDITIONALS II

### Test Command (`test` or `[ ... ]`)
[ -f "$FILE" ]                 # Check if FILE exists and is a regular file
[ -d "$DIRECTORY" ]            # Check if DIRECTORY exists and is a directory
[ -z "$STRING" ]               # Check if STRING is null (length 0)
[ "$STRING1" = "$STRING2" ]    # Check if STRING1 equals STRING2

### Double Brackets (`[[ ... ]]`)
[[ "$var" =~ regex ]]          # Regex match (only in double brackets)
[[ -n "$STRING" && "$var" -gt 5 ]]  # Combined logical conditions

### Arithmetic Expressions (`(( ... ))`)
(( var > 5 ))                  # Arithmetic comparison
(( var++ ))                    # Increment variable

### Case Statement (`case ... esac`)
case "$var" in
  pattern1) command1 ;;        # Execute command1 if matches pattern1
  pattern2) command2 ;;        # Execute command2 if matches pattern2
  *) default_command ;;        # Default case
esac


## LOOPS
for i in {1..10}; do
    echo $i                  # For loop
done

while [ $VAR -lt 10 ]; do
    echo $VAR
    VAR=$((VAR+1))           # While loop
done

## FUNCTIONS
function_name() {
    echo "This is a function" # Define a function
}

## ARITHMETIC
result=$((5 + 5))            # Arithmetic operation
result=$(expr 5 + 5)         # Alternative arithmetic

## INPUT/OUTPUT
read VARNAME                 # Read input from user
echo "Hello, World!"         # Print to standard output
printf "%s\n" "Hello"        # Formatted output

## BACKGROUND PROCESSES
command &                    # Run command in the background
jobs                         # List background jobs
fg %1                        # Bring job number 1 to foreground
bg %1                        # Send job number 1 to background
kill %1                      # Kill job number 1

## ALIASES
alias ls="ls -la"            # Create alias for ls

## NETWORKING
ping host                    # Ping a host
netstat -tuln                # List all listening ports
ifconfig                     # Display network interfaces (deprecated in some systems, use 'ip a')

## HISTORY
history                      # Show command history
!!                           # Execute the last command
!n                          # Execute the nth command from history

## OTHER USEFUL COMMANDS
grep pattern files           # Search for pattern in files
find /path -name "pattern"   # Find files with name pattern
man command                  # Display the manual page for command
which command                # Show path to command
type command                 # Describe a command
ps                           # List processes
top                          # Display dynamic real-time view of running processes
df                           # Display disk usage
du                           # Estimate file space usage
tar czf file.tar.gz dir      # Tar and gzip a directory
tar xzf file.tar.gz          # Extract a gzipped tarball
chmod 755 file               # Change file permissions (rwxr-xr-x)
chown user:group file        # Change file owner

## ADVANCED BASH CHEATSHEET

### BRACE EXPANSION
echo {A,B,C}{1,2,3}          # Results in A1 A2 A3 B1 B2 B3 C1 C2 C3

### TILDE EXPANSION
echo ~                       # Home directory
echo ~username               # Home directory of 'username'

### PROCESS SUBSTITUTION
diff <(command1) <(command2) # Compare outputs of two commands

### ARRAY OPERATIONS
ARRAY=(item1 item2 item3)    # Define an array
echo ${ARRAY[0]}             # Access the first item
echo ${ARRAY[*]}             # Access all items
echo ${#ARRAY[@]}            # Get array length
ARRAY+=(item4)               # Append to array

### ASSOCIATIVE ARRAY (DICTIONARY)
declare -A DICT
DICT[key1]=value1
DICT[key2]=value2
echo ${DICT[key1]}           # Access value by key
echo ${!DICT[@]}             # Get all keys

### STRING MANIPULATION
STRING="Hello, World!"
echo ${#STRING}              # Get string length
echo ${STRING:7}             # Substring, starting from position 7
echo ${STRING:7:5}           # Substring, starting from position 7, length 5
echo ${STRING/H/h}           # Replace first 'H' with 'h'
echo ${STRING//o/O}          # Replace all 'o' with 'O'

### PARAMETER EXPANSION
: ${VAR:=default}            # Set VAR to default if it's unset or empty
: ${VAR:-default}            # Use default if VAR is unset or empty, but don't change VAR
: ${VAR:+alt_value}          # Use alt_value if VAR is set and not empty
: ${VAR:?message}            # Display error message and exit if VAR is unset or empty

### ARITHMETIC IN DOUBLE PARENTHESIS
result=$(( $VAR1 + $VAR2 ))  # Arithmetic with double parentheses
(( result = VAR1 * VAR2 ))   # Another arithmetic example
(( VAR++ ))                   # Increment VAR
(( VAR-- ))                   # Decrement VAR

### HEREDOCS
cat << EOF
This is a here document.
It can span multiple lines.
EOF

### DEBUGGING
set -x                       # Print commands before executing
set +x                       # Stop printing commands
set -e                       # Exit on any command error
set -u                       # Treat unset variables as an error
trap 'echo Error at about line $LINENO' ERR  # Catch errors

### SCRIPT ARGUMENTS
$0                           # Script name
$1, $2, ...                  # Script arguments
$#                           # Number of arguments
$@                           # All arguments as a list
$*                           # All arguments as a single string

### COMMAND TIMING
time command                 # Measure time taken by a command

### LOOPING OVER FILES SAFELY
find . -type f | while IFS= read -r file; do
    echo "$file"             # Safe loop over files
done

### TERMINAL COLORS
echo -e "\e[31mRed Text\e[0m"     # Print in red
echo -e "\e[32mGreen Text\e[0m"   # Print in green

### SED AND AWK
sed 's/pattern/replace/' file      # Replace pattern in file using sed
sed -i '/delete/d' example.txt     # Delete in place
awk '{print $2}' file              # Print the second column of a file using awk

## MISCELLANEOUS COMMANDS
# Include the miscellaneous commands here as needed.

