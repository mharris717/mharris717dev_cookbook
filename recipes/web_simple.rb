include_recipe "nginx"
include_recipe "mharris717::sinatra"

##UNICORN
hosted_site 'empty_site' do
  subdomain "empty"
  port 8081
  checkout "https://github.com/mharris717/empty_site.git"
end

hosted_site 'empty_site2' do
  port 8082
end

hosted_site 'empty_site3' do
  port 8083
  checkout "https://github.com/mharris717/empty_site.git"
end

hosted_site 'ember-auth-easy_sample-rails-app' do
  port 8084
  checkout "https://github.com/mharris717/ember-auth-easy_sample-rails-app.git"
  subdomain "eaerails"
  setup_command "rake db:migrate db:seed"
end

nginx_for_hosted_sites do

end

#sudo rm /etc/init.d/unicorn_empty_site /etc/nginx/conf.d/empty_site.conf /etc/unicorn/empty_site.rb
# sudo /etc/init.d/unicorn_empty_site start && sudo /etc/init.d/unicorn_empty_site2 start


  