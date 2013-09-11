#%w(rvm postgresql npm).each do |n|
#  node[n] ||= {}
#end

#node[:rvm][:default_ruby] = "ruby-1.9.3-p448"
#node[:postgresql][:password] ||= {}
#node[:postgresql][:password][:postgres] = 'password123'

default[:mharris717] = {}
default[:mharris717][:sites_dir] = "/var/sites"

#node[:npm][:version] = "1.3.4"

if true
node.default[:unicorn][:worker_timeout] = 60
node.default[:unicorn][:preload_app] = false
node.default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
node.default[:unicorn][:preload_app] = false
node.default[:unicorn][:before_fork] = 'sleep 1'
node.default[:unicorn][:port] = '8081'
node.set[:unicorn][:options] = { :tcp_nodelay => true, :backlog => 100 }
end

node.default[:bundle_path] = "/home/vagrant/.rbenv/shims/bundle"
node.default[:unicorn_path] = "/home/vagrant/.rbenv/shims/unicorn_rails"
node.default[:ruby_bin_path] = "/home/vagrant/.rbenv/shims"

#node[:languages][:ruby][:default_version] = '1.9'