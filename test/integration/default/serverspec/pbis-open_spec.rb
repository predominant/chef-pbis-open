require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "pbis-open" do
  it "has a running service of lwsmd" do
    expect(service("lwsmd")).to be_running
  end
end