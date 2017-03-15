require 'rat_deployer/config'
require 'active_support/core_ext/string'
require 'slack-notifier'

module RatDeployer
  module Notifier
    def self.notify_deploy_start
      notify_deploy "Starting deploy on #{ENV.fetch('RAT_ENV')}"
    end

    def self.notify_deploy_end
      notify_deploy "Ended deploy on #{ENV.fetch('RAT_ENV')}"
    end

    def self.notify_deploy(title)
      props = get_deploy_properties

      slack_notifier.post(
        attachments: [{
          title:  title,
          fields: get_deploy_properties.map do |k,v|
            {
              title: k.to_s.titleize,
              value: k == :images ? v.join(' · ') : v,
              short: k != :images
           }
          end
        }]
      )
    end

    def self.notify(msg)
      return unless webhook_url
      self.slack_notifier.ping msg
    end

    private

    def self.slack_notifier
      @slack_notifier ||=
        begin
          Slack::Notifier.new(
            webhook_url,
            channel: '#general',
            username: 'rat-deployer'
          )
        end
    end

    def self.webhook_url
      @webhook_url ||= RatDeployer::Config.all["slack_webhook_url"]
    end

    def self.get_deploy_properties
      require 'socket'

      docker_config = YAML.load(RatDeployer::Cli.new.compose('config'))
      images = docker_config['services'].map { |s,c| c['image'] }.uniq.sort

      {
        env:        ENV.fetch('RAT_ENV'),
        user:       ENV.fetch('USER'),
        hostname:   Socket.gethostname,
        started_at: Time.now.to_s,
        images:     images
      }
    end
  end
end
