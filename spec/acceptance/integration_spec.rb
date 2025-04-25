# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'init class' do
  context 'applying graylog server class works' do
    let(:version) { '1.7.1' }

    let(:pp) do
      <<-CODE
        class { 'cni_plugins':
          version => '#{version}',
        }
      CODE
    end

    it 'behaves idempotently' do
      idempotent_apply(pp)
    end

    describe file('/opt/cni') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    # Use a local variable inside each describe block instead of accessing let(:version)
    describe 'version directory' do
      let(:version_dir) { "/opt/cni/#{version}" }

      it 'has the correct directory structure' do
        expect(file(version_dir)).to be_directory
        expect(file(version_dir)).to be_owned_by 'root'
        expect(file(version_dir)).to be_grouped_into 'root'
      end

      it 'has the correct dummy binary' do
        dummy_path = "#{version_dir}/dummy"
        expect(file(dummy_path)).to be_file
        expect(file(dummy_path)).to be_executable
        expect(file(dummy_path)).to be_owned_by 'root'
        expect(file(dummy_path)).to be_grouped_into 'root'
      end
    end

    describe file('/opt/cni/bin') do
      it { is_expected.to be_linked_to "/opt/cni/#{version}" }
    end

    describe command('/opt/cni/bin/dummy --version') do
      its(:stderr) { is_expected.to match %r{CNI dummy plugin v#{version}} }
    end
  end
end
