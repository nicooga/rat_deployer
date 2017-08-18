require 'rat_deployer/command'
require 'rat_deployer/config'
require 'active_support/concern'

module RatDeployer
  module Commands
    # This command proxies to `docker-compose` binary,
    # adding the following flags:
    #
    # - -f for each config file.
    #
    # Defaults to current_env.config_files or
    # config/default.yml and config/<current_env>.yml
    #
    # - -p with the configured project_name
    #
    # It is possible to include the current_env in the
    # prohect name by using the token `{env}`, E.g.: project_name_{env}
    module Compose
      extend Command

      def self.perform(cmd, *cmd_flags, silent: false)
        run(
          [
            'docker-compose',
            flags,
            cmd,
            cmd_flags
          ].flatten.join(' '),
          silent: silent
        )
          .fetch(:output)
      end

      def self.flags
        config_files =
          Config.for_env['config_files'] || %W[
            config/default.yml
            config/#{Config.env}.yml
          ]

        flags = [
          config_files.map { |cf| "-f #{cf}" },
          "-p #{Config.project_name}"
        ]

        flags.unshift(Config.remote_machine_flags) if Config.remote

        flags
      end

      # Meant to be included in RatDeployer::Cli
      module Extension
        extend ActiveSupport::Concern

        included do
          desc \
            'compose ARGS...',
            'runs docker-compose command with default flags'
          def compose(cmd, *cmd_flags, silent: false)
            Commands::Compose.perform(cmd, *cmd_flags, silent: silent)
          end
        end
      end
    end
  end
end
