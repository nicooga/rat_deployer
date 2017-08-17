require 'spec_helper'

describe '`docker` command' do
  context 'when no config was specified' do
    it 'should just proxy the command to docker' do
      run_cmd('rat docker ps')
      expect(proxied_cmds.length).to eq 1
      expect(proxied_cmd).to eq('docker ps')
    end
  end

  context 'when config was specified' do
    it 'should proxy adding the remote flags' do
      run_cmd('RAT_ENV=staging RAT_REMOTE=true rat docker ps')
      expect(proxied_cmds.length).to eq 1
      expect(proxied_cmd).to eq(
        %w[
          docker
          --tlsverify
          -H=tcp://123.123.123:1231
          --tlscacert=certs/staging/ca.pem
          --tlscert=certs/staging/cert.pem
          --tlskey=certs/staging/key.pem
          ps
        ].join(' ')
      )
    end
  end
end
