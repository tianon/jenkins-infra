require 'spec_helper'

describe 'profile::puppetmaster' do
  let(:pre_condition) do
    # Define our jenkins_keys class in our catalog, since it's provided by a
    # private module
    ['class jenkins_keys { }']
  end

  it { should contain_class 'jenkins_keys' }

  it { should contain_file('/etc/puppetlabs/puppet/hiera.yaml') }
  it { should contain_firewall('010 allow dashboard traffic').with_action('accept').with_port(443) }
  it { should contain_firewall('011 allow r10k webhooks').with_action('accept').with_port(9013) }
  it { should contain_firewall('012 allow puppet agents').with_action('accept').with_port(8140) }
  it { should contain_firewall('013 allow mcollective').with_action('accept').with_port(61613) }

  context 'setting up the irc reporter' do
    let(:facts) do
      {
        :is_pe => true,
        :pe_version => '3.7.2',
      }
    end
    it { should contain_class 'irc' }

    context 'the puppet-irc module' do
      # https://issues.jenkins-ci.org/browse/INFRA-502
      it 'should use the appropriate $gem_provider' do
        expect(subject).to contain_package('carrier-pigeon').with({
          :provider => 'pe_puppetserver_gem',
        })
      end
    end
  end

  it { should contain_class 'datadog_agent' }
end
