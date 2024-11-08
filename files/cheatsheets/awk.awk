# AWK Cheatsheet

## Basics I
- $1 Reference first column
- $2 Reference second column
- $0 Reference current record line
- print Print current record line
- FS Field separator of input file (default whitespace)
- NF Number of fields in current record
- NR Line number of the current record

## Basics II
- ^ Match beginning of field
- ~ Match operator
- !~ Do not match operator
- -F Command line option to specify input field delimiter
- BEGIN Denotes block executed once at start
- END Denotes block executed once at end
- str1 str2 Concatenate str1 and str2

## Variables I
- FILENAME Reference current input file
- FNR Reference number of the current record relative to current input file
- OFS Field separator of the outputted data (default whitespace)
- ORS Record separator of the outputted data (default newline)
- RS Record separator of input file (default newline)

## Variables II
- CONVFMT Conversion format for numbers (default %.6g)
- SUBSEP Separates multiple subscripts (default 034)
- OFMT Output format for numbers (default %.6g)
- ARGC Argument count, assignable
- ARGV Argument array, assignable
- ENVIRON Array of environment variables

## Functions I
- index(s,t) Position in string s where string t occurs, 0 if not found
- length(s) Length of string s (or $0 if no arg)
- rand Random number between 0 and 1
- substr(s,index,len) Return len-char substring of s that begins at index (counted from 1)
- srand Set seed for rand and return previous seed
- int(x) Truncate x to integer value

## Functions II
- split(s,a,fs) Split string s into array a split by fs, returning length of a
- match(s,r) Position in string s where regex r occurs, or 0 if not found
- sub(r,t,s) Substitute t for first occurrence of regex r in string s (or $0 if s not given)
- gsub(r,t,s) Substitute t for all occurrences of regex r in string s

## Functions III
- system(cmd) Execute cmd and return exit status
- tolower(s) Convert string s to lowercase
- toupper(s) Convert string s to uppercase
- getline Set $0 to next input record from current input file.

## One-Line Exercises I
- awk '{print $1}' file                               # Print first field for each record in file
- awk '/regex/' file                                  # Print only lines that match regex in file
- awk '!/regex/' file                                  # Print only lines that do not match regex in file
- awk '$2 == "foo"' file                               # Print any line where field 2 is equal to "foo"
- awk '$2 != "foo"' file                               # Print lines where field 2 is NOT equal to "foo"
- awk '$1 ~ /regex/' file                              # Print line if field 1 matches regex
- awk '$1 !~ /regex/' file                             # Print line if field 1 does NOT match regex

## One-Line Exercises II
- awk 'NR!=1{print $1}' file                          # Print first field for each record excluding the first record
- awk 'END{print NR}' file                             # Count lines in file
- awk '/foo/{n++}; END {print n+0}' file              # Print total number of lines that contain "foo"
- awk '{total=total+NF};END{print total}' file        # Print total number of fields in all lines
- awk '/regex/{getline;print}' file                    # Print line immediately after regex, but not line containing regex
- awk 'length > 32' file                               # Print lines with more than 32 characters
- awk 'NR==12' file                                    # Print line number 12 of file

## Examples
### Context: Sanitize Before Printing
- ip -o link | awk '{gsub(/:/,"")} {print $2}'       # Remove colons

### Context: Print Lines After Match
- awk 'should_print==1 && /^   / { print "     "$1 } /main\(\)/ {should_print=1}' 

### Context: Multiple Patterns
- awk '/^function/ && ! /util-printme/ { print "  " substr($2, 1, length($2)-2)}' /share/lib/helpers.sh

### Context: Special Words: RSTART, match
- awk 'match($0, /o/) {print $0 " has o at " RSTART}'

### Context: Either or
- awk '$1 ~ /^[b,c]/ {print $0}' file.txt 

### Context: For Loop
- awk 'BEGIN { for(i=1; i <=10; i++) print "The square of", i, "is", i*i;}'

### Context: Last Field
- ps -ef | awk '{ if($NF == "/bin/fish") print $0 }'

### Context: Filter by Line Length
- awk 'length($0) > 7' /etc/shells

### Context: Replace head -n10
- awk '(NR>=0 && NR<=10){print} (NR==10){exit}' file.txt

### Context: Partial Line Print
- awk '$5 ~ "restore" {$1=$2=$3=$4=$5=""; print $0}' /var/log/application.log

### Context: Special Variables
- awk 'NF { print $0 "\n" }' filname.ext                   # NF is a coefficient for number of fields, meaning blank lines get skipped.
- awk '{print NF}' file.txt                                  # Print number of fields in each row
- awk '{print FNR}' file.txt                                 # Print current line number!

### Context: Join
- awk 'BEGIN { ORS="\n\n" }; 1' filname.ext                # Double space input lines
- awk 'BEGIN { ORS=":" }; 1' filname.ext                   # Join lines with :
- awk 'BEGIN { ORS=":" }; {print}' filname.ext             # Join lines with :
- awk 'BEGIN { ORS=":" }; {print $0}' filname.ext          # Join lines with :

# Note
# Consider combining with:
# pip install reindent
# To auto inject trace logging into Python code
