# testlab requirements:
#- on start, describe the system its running on, like in tracer.rb
#- know how to install dependencies automatically when possible.
#- automate simplest possible ruby setup, +gem install bundler +bundle
#- probably ought to have a jenkins build

def scan_filesystem

  results = []

  known_native_libraries = [
    'libxml'
  ]

  file_extensions = [
    '.h',
    '.c',
    '.lib',
  ]

  # maybe locate is better here...
  known_native_libraries.each do |keyword|
    file_extensions.each do |ext|
      results << system("find / -type f -iname \\*#{keyword}\\*#{ext} 2> /dev/null")
    end
  end

  results.each do |r|
    puts r
  end

end

scan_filesystem
