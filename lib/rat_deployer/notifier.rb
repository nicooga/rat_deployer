require 'rat_deployer/config'
require 'active_support/core_ext/string'
require 'slack-notifier'

module RatDeployer
  # RatDeployer::Notifier handles notifications to slack
  module Notifier
    def self.notify_deploy_start
      return unless webhook_url
      notify_deploy "Starting deploy on #{RatDeployer::Config.env}"
    end

    def self.notify_deploy_end
      return unless webhook_url
      notify_deploy "Ended deploy on #{RatDeployer::Config.env}"
    end

    def self.notify(msg)
      return unless webhook_url
      return unless webhook_url
      slack_notifier.ping msg
    end

    def self.notify_deploy(title)
      return unless webhook_url
      props = deploy_properties

      slack_notifier.post(
        text: title,
        attachments: [{
          title:  'Deploy details',
          fields: props.map do |k, v|
            {
              title: k.to_s.titleize,
              value: k == :images ? v.join(' · ') : v,
              short: k != :images
            }
          end
        }]
      )
    end

    def self.slack_notifier
      return unless webhook_url

      @slack_notifier ||=
        begin
          Slack::Notifier.new(
            webhook_url,
            channel: '#alerts',
            username: 'rat-deployer'
          )
        end
    end

    def self.webhook_url
      @webhook_url ||= RatDeployer::Config.all['slack_webhook_url']
    end

    def self.deploy_properties
      require 'socket'

      compose_config = RatDeployer::Cli.new.compose('config', silent: true)
      docker_config = YAML.safe_load(compose_config)
      images = docker_config['services'].map { |_s, c| c['image'] }.uniq.sort

      {
        env:        RatDeployer::Config.env,
        user:       ENV.fetch('USER'),
        hostname:   Socket.gethostname,
        started_at: Time.now.to_s,
        images:     images
      }
    end
  end
end
