service 'network' do
  action :nothing
end

# disable NetworkManager so it doesnt overwrite resolv.conf (on centos 7+)
service 'NetworkManager' do
  action :stop
end

# add dhcclient hook so it doesnt overwrite resolv.conf (on centos 6)
cookbook_file '/etc/dhcp/dhclient-enter-hooks' do
  source 'dhclient-enter-hooks'
  only_if { node['platform'] =~ /centos/i }
  notifies :reload, 'service[network]', :immediately
  mode '755'
end

timeout = 20
query = 'domain_controller:true'
nodes = []
if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  begin
    timeout(timeout) do
      nodes = search(:node, query)
      until nodes.count > 0 && nodes[0].key?('ipaddress')
        sleep 5
        nodes = search(:node, query)
      end
    end
  rescue Timeout::Error
    Chef::Log.info "search for (:node, #{query}) returned 0 nodes"
    puts "search for (:node, #{query}) returned 0 nodes"
  end
end

dns_server_list = []
nodes.each do |cur_node|
  if cur_node['ipaddress'].is_a?(Array)
    cur_node['ipaddress'].each do |ip_addr|
      dns_server_list << ip_addr unless ip_addr.empty?
    end
  else
    dns_server_list << cur_node['ipaddress']
  end
end

node.set['resolver']['nameservers'] = dns_server_list
include_recipe 'resolver'
