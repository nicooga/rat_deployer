require 'rat_deployer/config'
require 'active_support/core_ext/string'
require 'slack-notifier'

module RatDeployer
  module Notifier
    def self.notify_deploy_start
      return unless webhook_url
      notify_deploy "Starting deploy on #{ENV.fetch('RAT_ENV')}"
    end

    def self.notify_deploy_end
      return unless webhook_url
      notify_deploy "Ended deploy on #{ENV.fetch('RAT_ENV')}"
    end

    def self.notify(msg)
      return unless webhook_url
      return unless webhook_url
      self.slack_notifier.ping msg
    end

    private

    def self.notify_deploy(title)
      return unless webhook_url
      props = get_deploy_properties

      slack_notifier.post(
        text: title,
        attachments: [{
          title:  'Deploy details',
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
      @webhook_url ||= RatDeployer::Config.all["slack_webhook_url"]
    end

    def self.get_deploy_properties
      require 'socket'

      docker_config = YAML.load(RatDeployer::Cli.new.compose('config', silent: true))
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
