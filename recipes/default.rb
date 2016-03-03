#
# Cookbook Name:: pbis-open
# Recipe:: default
#
# Copyright 2015, Biola University
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
install_script_name = ::File.basename(node['pbis-open']['installation_script_url'])

remote_file "#{Chef::Config['file_cache_path']}/#{install_script_name}" do
  source node['pbis-open']['installation_script_url']
  owner 'root'
  group 'root'
  mode '0744'
  action :create_if_missing
end

bash 'install-pbis-open' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    ./#{install_script_name} install
  EOH
  creates '/opt/pbis/bin/config'
end

# Get AD authentication info using chef-vault or provided encrypted databag
begin
  if node['pbis-open']['use_vault']
    log 'Using Chef-Vault for AD credentials'
    bind_credentials = chef_vault_item(node['pbis-open']['chef_vault'], node['pbis-open']['chef_vault_item'])
  else
    log 'Using Encrypted data bag for AD credentials'
    secret = Chef::EncryptedDataBagItem.load_secret
    bind_credentials = Chef::EncryptedDataBagItem.load(node['pbis-open']['data_bag'], node['pbis-open']['data_bagitem'], secret)
  end
rescue
  log 'Unable to load AD credentials. Skipping domain join.'
end

# Determine if the computer is joined to the domain
query = shell_out "domainjoin-cli query | grep -ic 'Domain = #{node['pbis-open']['ad_domain'].upcase}'"
domain_member = query.status.success? && query.stdout.to_i == 1

# Disable the Ohai passwd plugin to avoid pulling LDAP information
# https://tickets.opscode.com/browse/OHAI-165
directory '/etc/chef/client.d' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

template '/etc/chef/client.d/disable-passwd.rb' do
  source 'disable-passwd.rb.erb'
end

# Join the computer to the domain if needed
if bind_credentials
  reboot 'now' do
    action :nothing
    reason 'Reboot for pbis installation.'
    delay_mins 1
    only_if { node['pbis-open']['perform_reboot'] }
  end

  join_cmd =
    ['domainjoin-cli join'].tap do |o|
      o << '--notimesync' if node['pbis-open']['join']['time_sync']
      o << '--disable hostname' if node['pbis-open']['join']['hostname']
      o << node['pbis-open']['ad_domain'].upcase
      o << format("'%s'", bind_credentials['username'])
      o << format("'%s'", bind_credentials['password'])
    end.join(' ')

  execute 'join-domain' do
    sensitive true
    command join_cmd
    action :run
    notifies :reboot_now, 'reboot[now]', :immediately
  end
end

# Set configuration options if joined
execute 'reload-config' do
  command "/opt/pbis/bin/config --file #{node['pbis-open']['config_file']}"
  action :nothing
  only_if File.exist?('/usr/bin/domainjoin-cli') && domain_member
end

template node['pbis-open']['config_file'] do
  source 'pbis.conf.erb'
  notifies :run, 'execute[reload-config]'
end
