ruby_block "log_platform" do
  block do
    Chef::Log.info("node['platform']: #{node['platform']}")
  end
end
