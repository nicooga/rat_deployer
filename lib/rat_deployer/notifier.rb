require 'slack-notifier'

module RatDeployer
  module Notifier
    def self.notify(msg)
      self.slack_notifier.ping msg
    end

    def self.slack_notifier
      @slack_notifier ||=
        begin
          webhook_url = RatDeployer::Config.all.fetch("slack_webhook_url")

          Slack::Notifier.new(
            webhook_url,
            channel: '#general',
            username: 'rat-deployer'
          )
        end
    end
  end
end
