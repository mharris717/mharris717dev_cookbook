gem_package "sinatra" do
  action :install
end

gem_package "daemons" do
  action :install
end

directory "/opt/pids" do
  mode "0755"
  owner "www-data"
end

directory "/opt/pids/sinatra" do
  mode "0755"
  owner "www-data"
end

directory "/var/sites/basic_site" do
  mode "0755"
  owner "www-data"
end

template "/var/sites/basic_site/main.rb" do
  source "sinatra/sinatra.rb.erb"
  mode "0755"
end

template "/var/sites/basic_site/daemon.rb" do
  source "sinatra/daemon.rb.erb"
  mode "0755"
end

template "/etc/init.d/sinatra" do
  source "sinatra/sinatra.init.erb"
  mode "0700"
  owner "root"
  group "root"
end

template "/etc/nginx/conf.d/default.conf" do
  source "sinatra/nginx.conf.erb"
end

service "sinatra" do
  action [:enable,:start]
end