include_recipe "nginx"

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

##UNICORN

include_recipe "unicorn"

$sites = []
setup_site = lambda do |vars|
  site = vars[:site]
  vars[:site_dir] ||= "/var/sites/#{vars[:site]}"
  vars[:config_file] ||= "/etc/unicorn/#{vars[:site]}.rb"
  vars[:subdomain] ||= vars[:site]
  $sites << vars

  template "/etc/init.d/unicorn_#{site}" do
    source "unicorn/init.erb"
    mode "0700"
    owner "root"
    group "root"

    variables vars
  end

  template "/etc/nginx/conf.d/#{site}.conf" do
    source "unicorn/nginx.conf.erb"
    variables vars
  end

  unicorn_config vars[:config_file] do
    listen({ vars[:port] => node[:unicorn][:options] })
    working_directory vars[:site_dir]
    worker_timeout node[:unicorn][:worker_timeout]
    preload_app node[:unicorn][:preload_app]
    worker_processes node[:unicorn][:worker_processes]
    before_fork node[:unicorn][:before_fork]
  end

  service "unicorn_#{site}" do
    action [:enable]
  end
end

setup_site[{:site => "empty_site", :subdomain => "empty", :port => 8081}]
setup_site[{:site => "empty_site2", :port => 8082}]

#sudo rm /etc/init.d/unicorn_empty_site /etc/nginx/conf.d/empty_site.conf /etc/unicorn/empty_site.rb
# sudo /etc/init.d/unicorn_empty_site start && sudo /etc/init.d/unicorn_empty_site2 start

template "/etc/nginx/conf.d/zzz_server.conf" do
  source "nginx/server.conf.erb"
  variables :sites => $sites
end
  