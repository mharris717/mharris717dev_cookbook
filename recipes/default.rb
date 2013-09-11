include_recipe "apt"
include_recipe "git"
#include_recipe "rvm::system"
#include_recipe "rvm::vagrant"
#include_recipe "ruby1.9"
#include_recipe 'postgresql::server'

#include_recipe 'mharris717::gems'
#include_recipe "mharris717::node"




directory node[:mharris717][:sites_dir] do
  owner "root"
  mode "0755"
  action :create
end

git "#{node[:mharris717][:sites_dir]}/ember-auth-testapp" do
  repository "https://github.com/mharris717/ember-auth-testapp.git"
  action :sync
end

git "#{node[:mharris717][:sites_dir]}/ember-auth-easy" do
  repository "https://github.com/mharris717/ember-auth-easy.git"
  action :sync
end



include_recipe 'mharris717::web_simple'