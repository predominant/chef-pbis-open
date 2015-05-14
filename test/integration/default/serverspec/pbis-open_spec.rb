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
