require 'spec_helper'

describe '`compose` command' do
  context 'when RAT_ENV was especified and RAT_REMOTE is not true' do
    it 'should add config files for the current env' do
      run_cmd('RAT_ENV=production rat compose up -d')

      expect(last_proxied_cmds.length).to eq 1

      expect(last_proxied_cmd).to eq(
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

      expect(last_proxied_cmds.length).to eq 1

      expect(last_proxied_cmd).to eq(
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

      expect(last_proxied_cmds.length).to eq 1

      expect(last_proxied_cmd).to eq(
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
end
