include_recipe "mongodb"

%w(mongo mongoid).each do |lib|
  #gem_package lib
end