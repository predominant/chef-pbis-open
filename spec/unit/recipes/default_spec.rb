require 'spec_helper'

describe 'pbis-open::default' do
  include ChefVault::TestFixtures.rspec_shared_context

  context 'centos on x64' do
    let(:install_script) { 'pbis-open-8.3.0.3287.linux.x86_64.rpm.sh' }
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos',
        version: '6.5'

      )
      runner.node.automatic['kernel']['machine'] = 'x86_64'
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the correct install file' do
      # expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/pbis-open-8.3.0.3287.linux.x86_64.rpm.sh")
      expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/#{install_script}")
    end

    it 'executes the install script' do
      expect(chef_run).to run_bash('install-pbis-open').with_code(%r{./#{install_script} install}).with_cwd(Chef::Config['file_cache_path'])
    end

    it 'creates the /etc/chef/client.d' do
      expect(chef_run).to create_directory('/etc/chef/client.d').with(owner: 'root', group: 'root', mode: '0755', recursive: true)
    end

    it 'disables the passwd ohai scan in /etc/chef/client.d' do
      expect(chef_run).to render_file('/etc/chef/client.d/disable-passwd.rb').with_content('Ohai::Config[:disabled_plugins] = [:Passwd]')
    end

    it 'joins the domain with all defaults' do
      expect(chef_run).to run_execute('join-domain').with_command('domainjoin-cli join CORP.CONTOSO.COM \'vagrant\' \'vagrant\'')
    end

    it 'reboots if it joins the domain' do
      expect(chef_run.execute('join-domain')).to notify('reboot[now]').to(:reboot_now)
    end

    it 'creates and populates /etc/pbis/pbis.conf' do
      expect(chef_run).to render_file('/etc/pbis/pbis.conf').with_content('LoginShellTemplate /bin/bash')
    end

    it 'reloads if the config files changes' do
      expect(chef_run.template('/etc/pbis/pbis.conf')).to notify('execute[reload-config]').to(:run)
    end
  end

  context 'centos on x64 with overridden attributes' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos',
        version: '6.5'

      )
      runner.node.automatic['kernel']['machine'] = 'x86_64'
      runner.node.set['pbis-open']['join']['ou'] = 'OU=linux,DC=CORP,DC=CONTOSO,DC-COM'
      runner.node.set['pbis-open']['join']['time_sync'] = true
      runner.node.set['pbis-open']['join']['hostname'] = 'fake_name'
      runner.converge(described_recipe)
    end

    it 'joins the domain with the specified ou, disabled hostname, and notimesync' do
      expect(chef_run).to run_execute('join-domain').with_command('domainjoin-cli join --ou \'OU=linux,DC=CORP,DC=CONTOSO,DC-COM\' --notimesync --disable hostname CORP.CONTOSO.COM \'vagrant\' \'vagrant\'')
    end
  end

  context 'centos on x86' do
    let(:install_script) { 'pbis-open-8.3.0.3287.linux.x86.rpm.sh' }
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos',
        version: '6.5'

      )
      runner.node.automatic['kernel']['machine'] = 'x86'
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the correct install file' do
      # expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/pbis-open-8.3.0.3287.linux.x86_64.rpm.sh")
      expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/#{install_script}")
    end

    it 'executes the install script' do
      expect(chef_run).to run_bash('install-pbis-open').with_code(%r{./#{install_script} install}).with_cwd(Chef::Config['file_cache_path'])
    end
  end

  context 'ubuntu on x64' do
    let(:install_script) { 'pbis-open-8.3.0.3287.linux.x86_64.deb.sh' }
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'ubuntu',
        version: '14.04'

      )
      runner.node.automatic['kernel']['machine'] = 'x86_64'
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the correct install file' do
      # expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/pbis-open-8.3.0.3287.linux.x86_64.rpm.sh")
      expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/#{install_script}")
    end

    it 'executes the install script' do
      expect(chef_run).to run_bash('install-pbis-open').with_code(%r{./#{install_script} install}).with_cwd(Chef::Config['file_cache_path'])
    end
  end

  #
  context 'ubuntu on x86' do
    let(:install_script) { 'pbis-open-8.3.0.3287.linux.x86.deb.sh' }
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'ubuntu',
        version: '14.04'

      )
      runner.node.automatic['kernel']['machine'] = 'x86'
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the correct install file' do
      # expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/pbis-open-8.3.0.3287.linux.x86_64.rpm.sh")
      expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/#{install_script}")
    end

    it 'executes the install script' do
      expect(chef_run).to run_bash('install-pbis-open').with_code(%r{./#{install_script} install}).with_cwd(Chef::Config['file_cache_path'])
    end
  end
end
