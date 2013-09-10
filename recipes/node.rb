include_recipe 'npm'

if false
npm_package "grunt" do
  action :install
end

npm_package "bower" do
  action :install
end
end