include_recipe "nginx"
include_recipe "mharris717::sinatra"

directory node[:mharris717][:sites_dir] do
  owner "root"
  mode "0755"
  action :create
end

directory node[:mharris717][:site_libs_dir] do
  owner "root"
  mode "0755"
  action :create
end

directory node[:mharris717][:pids_dir] do
  owner "root"
  mode "0755"
  action :create
end

##UNICORN
hosted_site 'empty_site' do
  subdomain "empty"
  port 8081
  checkout "https://github.com/mharris717/empty_site.git"
end

hosted_site 'ember-auth-easy_sample-rails-app' do
  port 8084
  checkout "https://github.com/mharris717/ember-auth-easy_sample-rails-app.git"
  subdomain "eaerails"
  setup_command "rake db:migrate db:seed"
end

hosted_static_site "ember-auth-testapp" do
  checkout "https://github.com/mharris717/ember-auth-testapp.git"
  subdomain "eae"
  #setup_command "npm install && grunt build:dist"
  static_subdir "dist"
end

hosted_rack_site "ascension_ws" do
  checkout "https://github.com/mharris717/ascension_ws.git"
  port 8085
end

hosted_static_site "ascension_web" do
  checkout "https://github.com/mharris717/ascension_web.git"
  subdomain "ascension"
  static_subdir "build"
end

hosted_rack_site "scores" do
  checkout "https://github.com/mharris717/espn_scores.git"
  port 8087
end


#sudo rm /etc/init.d/unicorn_empty_site /etc/nginx/conf.d/empty_site.conf /etc/unicorn/empty_site.rb
# sudo /etc/init.d/unicorn_empty_site start && sudo /etc/init.d/unicorn_empty_site2 start


  