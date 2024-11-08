
# Useful `sed` and `grep` Commands

## General `sed` and `grep` Commands

### Count Non-Empty Lines
```bash
grep -c '.' file
```

### Replace a Line Based on a Pattern
```bash
sed -i "/^IFACE=/ c IFACE=$IFACE" $FN
```

### Duplicate a Line and Modify the Next Line (Pattern Match)
```bash
sed -n 'p; s/thing1/thing2/p'
```

### Grep with Group Capture and Replacement
```bash
grep -oP 'foo \K\w+(?= bar)' test.txt
# \K serves as an anchor to exclude everything before it from the match
```

### Replace a Line
```bash
sed -i '/TEXT_TO_BE_REPLACED/c\This line is removed by the admin.' /tmp/foo
```

### Add a Line at a Specific Position
```bash
sed -i '9i text' FILE
```

### Remove Specific Lines by Line Number
```bash
if [ "$checksum" = "e3e846d113b32a09d979534472a0f833" ] ; then
  sed -i '279,281d;286d' $ifupeth
fi
```

## Specialized `sed` Use Cases

### Increment Log Statements in a Script
```bash
FN=get_network_info.sh
for i in $(seq 1 100); do
  sed -i "0,/0000/ s/0000/$i/g" $FN
  grep -q "echo '0000'" $FN || break
done
```

### Extract File Name from a Path (Alternative to `basename`)
```bash
find /path/to/files -type f | grep bin | sed 's!.*/!!'
```

### Add a New Line After a Pattern
```bash
sed '/unix/ a "Add a new line"' file.txt
```

### Idempotent Inplace File Editing
```bash
# Safely edit a file and restore it from backup if needed
sed -i 's/a/aa/g ; s/b/bb/g' target.txt && cat target.txt && cp target.txt.bak target.txt
```

### Replace a File Path in a Script
```bash
sed -i 's|/a/path|/another/path|g'
```

### Wrap a Matched String in Quotes
```bash
sed 's/string/"&"/' sed.txt
```

### Replace the line of the first hit, read from file 
```bash
sed -i "0,/^pattern/s|.*|$(<.replacement)" file
```

## Warnings:
- **Be cautious with symlinks:**  
  `sed -i` **will overwrite a symlink!**

## Example Deletion Commands:
```bash
sed '/^u/d' file
```

```bash
# just the first match 
sed -i '/0,/pattern/{//d;}' file
# test first like so, basically a grep
sed -n '/0,/pattern/{//p;}' file
```

