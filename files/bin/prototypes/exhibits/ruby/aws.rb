ACCESS_KEY_ID = 'secure'
SECRET_ACCESS_KEY = 'secure'
REGION = 'us-east-1'
WINDOWS_2012_IMAGE = 'ami-c8a9baa2'
WINDOWS_2008_IMAGE = 'ami-b95446d3'
WINDOWS_FLAVOR = 't2.medium'
UBUNTU_IMAGE = 'ami-fce3c696'
UBUNTU_FLAVOR = 't2.medium'
KEY_NAME = 'brad'
require 'base64'
require 'aws-sdk'
Aws.config.update(
  region: REGION,
  credentials: Aws::Credentials.new(ACCESS_KEY_ID, SECRET_ACCESS_KEY)
  )

def self.print_details(instance)
  puts "running instance #{instance.inspect}.  details:"
  puts "private_ip_address: #{instance.private_ip_address}"
  puts "public_ip_address: #{instance.public_ip_address}"
end

def self.boot_instance(options)
  ec2 = Aws::EC2::Resource.new
  puts 'booting instance'
  create_result = ec2.create_instances options
  puts "booted instance.  result: #{create_result.inspect}"
  instance = ec2.instance(create_result.first.id)
  puts 'waiting for instance to reach running state'
  instance.wait_until_running
  print_details instance
  if instance.platform.eql? 'windows'
    password = ''
    until password.length > 0
      begin
        password = instance.decrypt_windows_password('/Users/brad.yohe/.ssh/brad.pem')
      rescue => ex
        puts "exception getting password #{ex.message}"
        sleep 60
      end
    end
    puts "\n\nWINDOWS PASSWORD: #{password}\n\n"
  end
end

boot_instance({
    image_id: WINDOWS_2008_IMAGE,
    min_count: 1,
    max_count: 1,
    instance_type: WINDOWS_FLAVOR,
    key_name: KEY_NAME,
    user_data: Base64.strict_encode64(File.read('/Users/brad.yohe/workspace/aws/windows_2008.xml'))
    })
