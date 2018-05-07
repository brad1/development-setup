#!/bin/bash

output=$(cat test_file)
while read -r line; do
  echo $line
done <<< "$output"
