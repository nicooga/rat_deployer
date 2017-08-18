require 'active_support/concern'
require 'active_support/core_ext/string/strip'

require 'rat_deployer/config'
require 'rat_deployer/notifier'
require 'rat_deployer/commands/compose'

module RatDeployer
  module Commands
    # This command runs `compose pull` and
    # `compose up -d` for the given services.
    # Adittionally, notifies to slack if configured to do so.
    module Deploy
      extend Command

      def self.perform(*services)
        Notifier.notify_deploy_start
        deploy(*services)
        Notifier.notify_deploy_end
      rescue StandardError => e
        Notifier.notify <<-STR.strip_heredoc
          Failed deploy on #{Config.env}
          Reason:
            #{e.message}
        STR
        raise e
      end

      def self.deploy(*services)
        if services.any?
          services_str = services.join(' ')
          Compose.perform("pull #{services_str}")
          Compose.perform("up -d --no-deps --force-recreate #{services_str}")
        else
          Compose.perform('pull')
          Compose.perform('up -d')
        end
      end

      # Meant to be included in RatDeployer::Cli
      module Extension
        extend ActiveSupport::Concern

        included do
          desc 'deploy', 'deploys current environment'
          def deploy(*services)
            Commands::Deploy.perform(*services)
          end
        end
      end
    end
  end
end
