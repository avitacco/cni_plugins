# frozen_string_literal: true

require 'spec_helper'

describe 'cni_plugins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_file('/opt/cni').with(
          ensure: 'directory',
          owner: 'root',
          group: 'root',
          mode: '0755',
        )
      }

      #
      # This test is extremely fragile, it will break every time the CNI plugins
      # release is updated, as well as fail on any development platform except
      # for amd64 architecture.
      #
      it {
        is_expected.to contain_file('/opt/cni')
          .with(
            ensure: 'directory',
            owner: 'root',
            group: 'root',
            mode: '0755',
          )

        is_expected.to contain_file('/opt/cni/1.6.2')
          .with(
            ensure: 'directory',
            owner: 'root',
            group: 'root',
            mode: '0755',
          )
          .that_requires(['File[/opt/cni]'])

        is_expected.to contain_archive('cni-plugins-linux-amd64-v1.6.2.tgz')
          .with(
            path: '/tmp/cni-plugins-linux-amd64-v1.6.2.tgz',
            source: 'https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz',
            digest_url: 'https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz.sha512',
            digest_type: 'sha512',
            extract: true,
            extract_path: '/opt/cni/1.6.2',
          )
          .that_requires(['File[/opt/cni/1.6.2]'])

        is_expected.to contain_file('/opt/cni/bin')
          .with(
            ensure: 'link',
            target: '/opt/cni/1.6.2',
          )
          .that_requires(['Archive[cni-plugins-linux-amd64-v1.6.2.tgz]'])
      }
    end

    context "on #{os} with unsupported architecture" do
      let(:facts) do
        # Create a copy of the facts and set an unsupported architecture
        os_facts.merge(
          {
            'os' => {
              'architecture' => 'unsupported_arch',
            },
          },
        )
      end

      it {
        is_expected.to compile.and_raise_error(%r{Unsupported architecture: unsupported_arch})
      }
    end
  end
end
