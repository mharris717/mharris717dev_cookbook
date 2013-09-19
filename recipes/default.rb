#include_recipe "mharris717::ssh"

include_recipe "apt"
include_recipe "git"
include_recipe 'postgresql::server'

include_recipe 'mharris717::gems'
#include_recipe "mharris717::node"
include_recipe 'mharris717::mongodb'
#include_recipe 'mharris717::redis'

include_recipe 'mharris717::web_simple'
include_recipe 'mharris717::playoff_odds'

nginx_for_hosted_sites do

end