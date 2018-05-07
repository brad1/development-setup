require 'fileutils'
require 'json'

$channel_id = "#{__FILE__.split('.').first}-#{Time.now.strftime("%Y.%m.%d-%H:%M:%S")}"
FileUtils.mkdir_p($channel_id)

def write(name, content)
  File.write("./#{$channel_id}/#{name}", content)
end

def read(name)
  File.read("./#{$channel_id}/#{name}")
end

properties = {
  job_name:     'azure_sharepoint_2016_large',
  build_number: '140'
}
properties.each do |k,v|
  write(k.to_s, v)
end

# try to get username/password
command = %Q{bash download_creds.sh "#{$channel_id}" creds}
puts command
`#{command}`
content = read('creds')
ip = content.scan(/public_ip="([^"]*)"/).first.first
user = content.scan(/username is:.*/).first.split(' ').last
password = content.scan(/password is:.*/).first.split(' ').last
puts password unless password.to_s.include? 'is:'


# get the private key
command = %Q{bash download_key.sh "#{$channel_id}"}
puts command if password.to_s.include? 'is:' 
`#{command}` if password.to_s.include? 'is:' 
key_name = "id_rsa_#{properties[:job_name]}_#{properties[:build_number]}_orca_scp"

# download and chop up environment
jump = "-J root@10.4.216.44:22"
command = %Q{/usr/local/Cellar/openssh/7.3p1/bin/ssh -i ~/.ssh/#{key_name} #{jump} #{user}@#{ip} 'orca env list' > #{$channel_id}/environments.json} 
puts command
`#{command}`
environments_json = File.read("#{$channel_id}/environments.json")
environments = JSON.parse(environments_json)
environment = environments.first
unless environment.nil?
  pwds  = environment.keys.select {|key| key.include? 'password'}
  names = environment.keys.select {|key| key.include? 'username'}
  ips   = environment.keys.select {|key| key.include? 'dmz_ip'}

  ports = [9999,9998,9997,9996,9995,9994,9993]
  for i in 0...pwds.size
    puts "\##{names[i]}"
    puts "\##{environment[names[i]]}/#{environment[pwds[i]]}"
    puts "/usr/local/Cellar/openssh/7.3p1/bin/ssh -L #{ports.shift}:#{environment[ips[i]]}:3389 -i ~/.ssh/#{key_name} #{jump} #{user}@#{ip}" 
  end
end
