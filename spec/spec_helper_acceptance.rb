require 'beaker-pe'
require 'beaker-puppet'
require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
configure_type_defaults_on(hosts)
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)


RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
  end
end

def return_puppet_version
  (on default, puppet('--version')).output.chomp
end

RSpec.shared_context 'with faked facts' do
  let(:facts_d) do
    puppet_version = return_puppet_version
    if fact('osfamily') =~ %r{windows}i
      if fact('kernelmajversion').to_f < 6.0
        'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/facts.d'
      else
        'C:/ProgramData/PuppetLabs/facter/facts.d'
      end
    elsif Puppet::Util::Package.versioncmp(puppet_version, '4.0.0') < 0 && fact('is_pe', '--puppet') == 'true'
      '/etc/puppetlabs/facter/facts.d'
    else
      '/etc/facter/facts.d'
    end
  end

  before :each do
    # No need to create on windows, PE creates by default
    if fact('osfamily') !~ %r{windows}i
      shell("mkdir -p '#{facts_d}'")
    end
  end

  after :each do
    shell("rm -f '#{facts_d}/fqdn.txt'", :acceptable_exit_codes => [0, 1])
  end

  def fake_fact(name, value)
    shell("echo #{name}=#{value} > '#{facts_d}/#{name}.txt'")
  end
end

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f)))
  rescue => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
  end
end
