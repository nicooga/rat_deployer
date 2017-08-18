require 'active_support/concern'

require 'rat_deployer/command'
require 'rat_deployer/config'

module RatDeployer
  module Commands
    # This command proxies to the `docker` binary
    # adding remote flags if configuration for
    # remote machine is present
    module Docker
      extend Command

      def self.perform(cmd, *cmd_flags)
        flags = []
        flags.unshift(Config.remote_machine_flags) if Config.remote
        cmd = run "docker #{flags.join(' ')} #{cmd} #{cmd_flags.join(' ')}"
        cmd.fetch(:output)
      end

      # Meant to be included in RatDeployer::Cli
      module Extension
        extend ActiveSupport::Concern

        included do
          desc 'docker ARGS...', 'runs docker command with default flags'
          def docker(cmd, *cmd_flags)
            Commands::Docker.perform(cmd, *cmd_flags)
          end
        end
      end
    end
  end
end
