#user "www" do
#  action :create
#end

include_recipe "nginx"
include_recipe "unicorn"

template "/etc/nginx/conf.d/default.conf" do
  source "default.conf.erb"
end

rvm_shell "install site bundle" do
  ruby_string node[:rvm][:default_ruby]
  #user "vagrant"
  cwd "/var/sites/empty_site"
  code "bundle install "
end

rvm_shell "install redis" do
  ruby_string node[:rvm][:default_ruby]
  #user "vagrant"
  cwd "/var/sites/empty_site"
  code "gem install redis mharris_ext"
end

template "/etc/init.d/unicorn" do
  source "unicorn.init.erb"
end

if true
  unicorn_config "/etc/unicorn/default.rb" do
    listen({ node[:unicorn][:port] => node[:unicorn][:options] })
    working_directory "#{node[:mharris717][:sites_dir]}/empty_site"
    worker_timeout node[:unicorn][:worker_timeout]
    preload_app node[:unicorn][:preload_app]
    worker_processes node[:unicorn][:worker_processes]
    before_fork node[:unicorn][:before_fork]
  end
end

