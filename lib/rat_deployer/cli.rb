require 'thor'
require 'fileutils'
require 'active_support/core_ext/string/strip'

require 'rat_deployer/command'
require 'rat_deployer/notifier'

module RatDeployer
  # The main Thor subclass
  class Cli < Thor
    include RatDeployer::Command

    desc 'deploy', 'deploys current environment'
    def deploy(*services)
      RatDeployer::Notifier.notify_deploy_start
      do_deploy(*services)
      RatDeployer::Notifier.notify_deploy_end
    rescue StandardError => e
      RatDeployer::Notifier.notify <<-STR.strip_heredoc
        Failed deploy on #{RatDeployer::Config.env}
        Reason:
          #{e.message}
      STR
      raise e
    end

    desc 'compose ARGS...', 'runs docker-compose command with default flags'
    def compose(cmd, *cmd_flags, silent: false)
      run(
        [
          'docker-compose',
          compose_flags,
          cmd,
          cmd_flags
        ].flatten.join(' '),
        silent: silent
      )
        .fetch(:output)
    end

    desc 'docker ARGS...', 'runs docker command with default flags'
    def docker(cmd, *cmd_flags)
      flags = []

      if RatDeployer::Config.remote
        flags.unshift(RatDeployer::Config.remote_machine_flags)
      end

      cmd = run "docker #{flags.join(' ')} #{cmd} #{cmd_flags.join(' ')}"
      cmd.fetch(:output)
    end

    private

    def do_deploy(*services)
      if services.any?
        services_str = services.join(' ')
        compose("pull #{services_str}")
        compose("up -d --no-deps --force-recreate #{services_str}")
      else
        compose('pull')
        compose('up -d')
      end
    end

    def compose_flags
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      config_files =
        RatDeployer::Config.for_env['config_files'] || %W[
          config/default.yml
          config/#{env}.yml
        ]

      flags = [
        config_files.map { |cf| "-f #{cf}" },
        "-p #{project_name}_#{env}"
      ]

      if RatDeployer::Config.remote
        flags.unshift(RatDeployer::Config.remote_machine_flags)
      end

      flags
    end
  end
end
