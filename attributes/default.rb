#
# Cookbook Name:: pbis-open
# Attributes:: default
#
# Copyright 2014, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE_2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# note - would like to generate the url based on the version numbers, but the download url format is not entirely consistent....
case node['platform_family']
when 'debian'
  default['pbis-open']['installation_script_url'] =
    if node['kernel']['machine'] =~ /x86_64/
      'http://download.beyondtrust.com/PBISO/8.3/pbis-open-8.3.0.3287.linux.x86_64.deb.sh'
    else
      'http://download.beyondtrust.com/PBISO/8.3/pbis-open-8.3.0.3287.linux.x86.deb.sh'
    end
when 'rhel'
  default['pbis-open']['installation_script_url'] =
    if node['kernel']['machine'] =~ /x86_64/
      'http://download.beyondtrust.com/PBISO/8.3/pbis-open-8.3.0.3287.linux.x86_64.rpm.sh'
    else
      'http://download.beyondtrust.com/PBISO/8.3/pbis-open-8.3.0.3287.linux.x86.rpm.sh'
    end
end

default['pbis-open']['config_file'] = '/etc/pbis/pbis.conf'
default['pbis-open']['use_vault'] = true
default['pbis-open']['chef_vault'] = 'ad_credentials'
default['pbis-open']['chef_vault_item'] = 'pbis_bind'
default['pbis-open']['data_bag'] = 'pbis'
default['pbis-open']['data_bagitem'] = 'credentials'
default['pbis-open']['ad_domain'] = 'corp.contoso.com'
default['pbis-open']['options']['LoginShellTemplate'] = '/bin/bash'
default['pbis-open']['perform_reboot'] = false

# Do not synchronize time with the AD server on domain join.
default['pbis-open']['join']['time_sync'] = false

# Do not set the underlying node host name on domain join.
default['pbis-open']['join']['hostname'] = false

# override to join a specific ou.  Default is not-specified ( wich is the default Computers container)
default['pbis-open']['join']['ou'] = nil
