# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'init class' do
  context 'applying graylog server class works' do
    let(:pp) do
      <<-CODE
        class { 'cni_plugins': }
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

    describe file('/opt/cni/1.6.2') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    #
    # Dummy acts as a proxy for all the other binaries in the directory, I don't
    # want to have to write a test for each one.
    #
    describe file('/opt/cni/1.6.2/dummy') do
      it { is_expected.to be_file }
      it { is_expected.to be_executable }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe file('/opt/cni/bin') do
      it { is_expected.to be_linked_to '/opt/cni/1.6.2' }
    end
  end
end
