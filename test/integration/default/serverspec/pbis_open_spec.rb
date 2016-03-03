require 'serverspec'
# Set backend type
set :backend, :exec
# Don't include Specinfra::Helper::DetectOS

set :path, '/sbin:/usr/sbin:$PATH'

describe 'pbis-open' do
  it 'has a running service of lwsmd' do
    expect(service('lwsmd')).to be_running
  end
end

describe file('/etc/pbis/pbis.conf') do
  it { should exist }
  its(:content) { should match(%r{\s*LoginShellTemplate /bin/bash}) }
end

describe file('/etc/chef/client.d/disable-passwd.rb') do
  it { should exist }
  it { should contain('Ohai::Config[:disabled_plugins] = [:Passwd]') }
end

describe user('CONTOSO\\administrator') do
  it { should exist }
end
