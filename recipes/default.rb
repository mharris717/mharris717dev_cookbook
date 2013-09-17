include_recipe "apt"
include_recipe "git"
include_recipe 'postgresql::server'

include_recipe 'mharris717::gems'
#include_recipe "mharris717::node"
include_recipe 'mharris717::mongodb'
include_recipe 'mharris717::web_simple'