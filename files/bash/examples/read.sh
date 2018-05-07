#!/bin/bash

# read program output one line at a time
output=$(cat test_file)
while read -r line; do
  echo $line
done <<< "$output"

# read user input and branch
read a
if [ "$a" = "yes" ]; then
  echo 'asdf'
fi
