# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe '`compose` command' do
  context 'when RAT_ENV was especified and RAT_REMOTE is not true' do
    it 'should add config files for the current env' do
      run_cmd('RAT_ENV=production rat compose up -d')

      expect(proxied_cmds.length).to eq 1

      expect(proxied_cmd).to eq(
        %w[
          docker-compose
          -f config/default.yml
          -f config/production.yml
          -p dummy_app_production
          up -d
        ].join(' ')
      )
    end
  end

  context 'when RAT_ENV was especified and RAT_REMOTE is true' do
    it 'should add config flags for the current env and remote flags' do
      run_cmd('RAT_ENV=staging RAT_REMOTE=true rat compose up -d')

      expect(proxied_cmds.length).to eq 1

      expect(proxied_cmd).to eq(
        %w[
          docker-compose
          --tlsverify
          -H=tcp://123.123.123:1231
          --tlscacert=certs/staging/ca.pem
          --tlscert=certs/staging/cert.pem
          --tlskey=certs/staging/key.pem
          -f config/default.yml
          -f config/staging.yml
          -p dummy_app_staging
          up -d
        ].join(' ')
      )
    end
  end

  context 'when RAT_ENV was not especified and RAT_REMOTE is not true' do
    it 'should add config flags for the default env' do
      run_cmd('rat compose up -d')

      expect(proxied_cmds.length).to eq 1

      expect(proxied_cmd).to eq(
        %w[
          docker-compose
          -f config/default.yml
          -f config/default.yml
          -p dummy_app_default
          up -d
        ].join(' ')
      )
    end
  end

  context 'when using custom config files' do
    it 'should use the config files especified in rat_config.yml' do
      run_cmd('RAT_ENV=testing rat compose up -d')

      expect(proxied_cmds.length).to eq 1

      expect(proxied_cmd).to eq(
        %w[
          docker-compose
          -f config/production.yml
          -f config/testing.yml
          -p dummy_app_testing
          up -d
        ].join(' ')
      )
    end
  end
end
