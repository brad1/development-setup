#next, guarantee correct encoding when reading and writing for the purpose of base64 encoding
$filename = '/tmp/nosuch'
$cached_content = ''

def create_file
  begin
    File.open($filename, "w+") do |f|
      f.print $cached_content
    end 
    file_stats
  rescue Errno::EACCES => e
    puts "Failure! Cannot access file #{$filename}"
  end
end

def file_stats
  filesize = File.size $filename
  f = File.open $filename
  encoding = f.external_encoding.name
  puts "Success! Filesize is #{filesize}, encoding is #{encoding}"
end

create_file
