require 'spec_helper'

describe '`compose` command' do
  context 'when run with no arguments' do
    it 'should run `compose pull` and `compose up -d`' do
      run_cmd('rat deploy')

      expect(last_proxied_cmds.length).to be(2)

      expect(last_proxied_cmds.first) .to eq(
         %w|
           docker-compose
           -f config/default.yml
           -f config/default.yml
           -p dummy_app_default
           pull
         |.join(' ')
       )

      expect(last_proxied_cmds[1]) .to eq(
         %w|
           docker-compose
           -f config/default.yml
           -f config/default.yml
           -p dummy_app_default
           up -d
         |.join(' ')
      )
    end
  end

  context 'when run with RAT_REMOTE=true RAT_ENV=env and services' do
    it 'should run `compose pull` and `compose up -d` with passing flags' do
      run_cmd('RAT_ENV=staging RAT_REMOTE=true rat deploy service1 service2')

      expect(last_proxied_cmds.length).to be(2)

      flags = %w[
        --tlsverify
        -H=tcp://123.123.123:1231
        --tlscacert=certs/staging/ca.pem
        --tlscert=certs/staging/cert.pem
        --tlskey=certs/staging/key.pem
        -f config/default.yml
        -f config/staging.yml
        -p dummy_app_staging
      ].join(' ')

      expect(last_proxied_cmds.first).to eq("docker-compose #{flags} pull service1 service2")
      expect(last_proxied_cmds[1]).to eq("docker-compose #{flags} up -d --no-deps --force-recreate service1 service2")
    end
  end
end
