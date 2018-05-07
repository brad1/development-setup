require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/lib/components"
end

# do it this way if test data gets big
# require 'webmock'
# WebMock.disable_net_connect!
