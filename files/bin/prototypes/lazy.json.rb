#!/usr/bin/env ruby
result = []
instring = false
content = STDIN.read
content.split('').each do |w|
  if w =~ /[[:alpha:]]/ || w.eql?('_') || (w =~ /[[:digit:]]/ && instring)
    if !instring
      result << '"'
      instring = !instring
    end
  else
    if instring
      result << '"'
      instring = !instring
    end
  end
  result << w
end

json1 = result.join('').strip
json1 = "{#{json1}}" unless json1.start_with? '{'

puts `echo '#{json1}' | format`
