require 'fileutils'
hash = Time.now.to_f.to_s.hash
hash = (hash*hash).to_s.slice(0,8)
FileUtils.mkdir_p("/tmp/#{hash}")
