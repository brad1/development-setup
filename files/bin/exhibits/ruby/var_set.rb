require 'base64'
require 'yaml'
module ConfigSource
  class Simple
    def initialize()
    end
    def convert64(source, dest)
      plaintext = File.read(source)
      File.write(dest, Base64.encode64(plaintext))
    end
    def read(filename)
      content = File.read(filename)
      content = Base64.decode64(content)
      YAML::load(content)
    end
  end
  def self.read(filepath)
    ConfigSource::Simple.new.read(filepath)
  end
  def self.encode(src, dest)
    ConfigSource::Simple.new.convert64(src, dest)
  end
end

# ConfigSource::encode('./var_set.yml', './var_set.config')
vars = ConfigSource::read('./var_set.config')
