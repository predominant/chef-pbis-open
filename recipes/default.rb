#
# Cookbook Name:: pbis-open
# Recipe:: default
#
# Copyright 2014, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'chef-vault'

# Install PBIS Open
remote_file "#{Chef::Config['file_cache_path']}/pbis-open.deb.sh" do
  source node['pbis-open']['installation_script_url']
  owner 'root'
  group 'root'
  mode "0744"
  action :create_if_missing
end

bash 'install-pbis-open' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    ./pbis-open.deb.sh install
  EOH
  creates '/opt/pbis/bin/config'
end

# Get AD authentication info using chef-vault
begin
	bind_credentials = chef_vault_item(node['pbis-open']['chef_vault'], node['pbis-open']['chef_vault_item'])
rescue
	log 'Unable to load chef vault item. Skipping domain join.'
end

# Determine if the computer is joined to the domain
domain_member = `domainjoin-cli query | egrep -ic 'Domain = #{node['pbis-open']['ad_domain'].upcase}'`.to_i

# Set configuration options if joined
if (File.exists?('/usr/bin/domainjoin-cli') && domain_member)
  execute "reload-config" do
    command "/opt/pbis/bin/config --file #{node['pbis-open']['config_file']}"
    action :nothing
  end

  template node['pbis-open']['config_file'] do
    source "pbis.conf.erb"
    notifies :run, resources(:execute => "reload-config")
  end
# Join the computer to the domain if needed
elsif (bind_credentials)
  execute "join-domain" do
    command "domainjoin-cli join #{node['pbis-open']['ad_domain'].upcase} #{bind_credentials['username']} '#{bind_credentials['password']}'"
    action :run
  end
end

# Disable the Ohai passwd plugin to avoid pulling LDAP information
# https://tickets.opscode.com/browse/OHAI-165
template "/etc/chef/client.d/disable-passwd.rb" do
  source "disable-passwd.rb.erb"
end